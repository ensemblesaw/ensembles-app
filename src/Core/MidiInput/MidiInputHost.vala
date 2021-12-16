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
        MidiDevice[] midi_device;

        public void destroy () {
            stream_connected = false;
            controller_destruct ();
        }

        bool stream_connected = false;

        public signal void receive_note_event (int key, int on, int velocity, int channel);

        public Ensembles.Core.MidiDevice[] refresh () {
            stream_connected = false;
            Thread.usleep (200);
            controller_destruct ();
            controller_init ();
            int n = controller_query_input_device_count ();
            debug ("Found %d devices...\n", n);
            midi_device = new MidiDevice[n];
            for (int i = 0; i < n; i++) {
                controller_query_device_info (i);
                midi_device[i].name = controller_input_device_name;
                midi_device[i].available = controller_input_device_available > 0 ? true : false;
                midi_device[i].id = i;
                debug("Found %s device: %s\n", midi_device[i].available ? "input" : "output", midi_device[i].name);
            }
            return midi_device;
        }

        int read_device_stream () {
            while (stream_connected) {
                if (controller_poll_device () > 0) {
                    int message = controller_read_device_stream ();
                    int key = (((0x00FF00 & message) - 9216) / 256) + 36;
                    int type = (message & 0x0000F0);
                    int channel = (message & 0x00000F);
                    double velocity = ((127.0 - 0.0) / (8323072.0 - 65536.0)) *
                                      (double)((0xFF0000 & message) - 65536);
                    print ("Velocity: %d, Key: %d, Type:%d, Channel:%d, Raw: %x\n",
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
            controller_close_connection ();
            return 0;
        }

        public void connect_device (int id) {
            if (!Thread.supported ()) {
                stderr.printf ("Cannot run without thread support.\n");
                return;
            }
            stream_connected = false;
            if (controller_connect_device (id) > 0) {
                stream_connected = true;
                new Thread<int> ("read_device_stream", read_device_stream);
            }
        }
    }
}

extern string controller_input_device_name;
extern int controller_input_device_available;

extern void controller_init ();
extern void controller_destruct ();

extern int controller_query_input_device_count ();
extern void controller_query_device_info (int id);
extern int controller_connect_device (int id);
extern int32 controller_read_device_stream ();
extern void controller_close_connection ();
extern int controller_poll_device ();
