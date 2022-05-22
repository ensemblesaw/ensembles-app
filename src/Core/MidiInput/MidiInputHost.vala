/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core {
    public struct MidiDevice {
        string name;
        int id;
        bool available;
    }
    public class MidiInputHost : Object {
        public MidiInputHost () {
            active_devices = new List<int> ();
        }

        public void destroy () {
            controller_destruct ();
        }

        MidiDevice[] midi_device;
        List<int> active_devices;
        Thread device_monitor_thread;
        bool stream_connected;

        public signal void receive_note_event (int key, int on, int velocity, int channel);

        public Ensembles.Core.MidiDevice[] refresh () {
            if (Application.raw_midi_input) {
                controller_destruct ();
                controller_init (1);
                return new Ensembles.Core.MidiDevice[0];
            }
            Thread.usleep (200);
            controller_destruct ();
            controller_init (0);
            int n = controller_query_input_device_count ();
            debug ("Found %d devices…\n", n);
            midi_device = new MidiDevice[n];
            for (int i = 0; i < n; i++) {
                controller_query_device_info (i);
                midi_device[i].name = controller_input_device_name;
                midi_device[i].available = controller_input_device_available > 0 ? true : false;
                midi_device[i].id = i;
                debug ("Found %s device: %s\n", midi_device[i].available ? "input" : "output", midi_device[i].name);
            }
            return midi_device;
        }

        int monitor_device_stream () {
            while (stream_connected) {
                for (int i = 0; i < active_devices.length (); i++) {
                    print(active_devices.nth_data (i).to_string () + "\n");
                    if (controller_poll_device (active_devices.nth_data (i)) > 0) {
                        int message = controller_read_device_stream (active_devices.nth_data (i));
                        int key = (((0x00FF00 & message) - 9216) / 256) + 36;
                        int type = (message & 0x0000F0);
                        int channel = (message & 0x00000F);
                        double velocity = ((127.0 - 0.0) / (8323072.0 - 65536.0)) *
                                        (double)((0xFF0000 & message) - 65536);
                        debug ("Velocity: %d, Key: %d, Type:%d, Channel:%d, Raw: %x\n",
                            (int)velocity,
                            key,
                            type,
                            channel,
                            message);
                        if (velocity < 0) {
                            velocity = 1;
                            type = 128;
                        }
                        Idle.add (() => {
                            receive_note_event (key, type, (int)velocity, channel);
                            return false;
                        });
                    }
                    Thread.yield ();
                    Thread.usleep (200);
                }
            }
            Thread.exit(0);
            return 0;
        }

        public void connect_device (int id) {
            if (active_devices.index (id) < 0) {
                active_devices.append (id);
                controller_connect_device (id);
            }
            if (active_devices.length () > 0 && !stream_connected) {
                stream_connected = true;
                device_monitor_thread = new Thread<int> ("mididevmon", monitor_device_stream);
            }
        }

        public void disconnect_device (int id) {
            active_devices.remove (id);
            controller_close_connection (id);
            if (active_devices.length () == 0) {
                stream_connected = false;
            }
        }
    }
}

extern string controller_input_device_name;
extern int controller_input_device_available;

extern void controller_init (int fluid_input);
extern void controller_destruct ();

extern int controller_query_input_device_count ();
extern void controller_query_device_info (int id);
extern int controller_connect_device (int id);
extern int32 controller_read_device_stream (int id);
extern void controller_close_connection (int id);
extern int controller_poll_device (int id);
