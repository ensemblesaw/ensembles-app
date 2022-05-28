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
        private MidiDevice[] midi_device;
        private List<int> active_devices;
        private Thread device_monitor_thread;
        private bool stream_connected;

        private Gee.HashMap<int, int> note_map;
        private Gee.HashMap<int, int> control_map;
        private Gee.HashMap<int, string> control_label_reverse_map;

        public MidiInputHost () {
            active_devices = new List<int> ();
            note_map = new Gee.HashMap<int, int> ();
            control_map = new Gee.HashMap<int, int> ();
            control_label_reverse_map = new Gee.HashMap<int, string> ();
        }

        public void destroy () {
            stream_connected = false;
            controller_destruct ();
        }



        public signal void receive_note_event (int key, bool is_pressed, int velocity, int layer);
        public signal bool midi_event_received (int channel, int identifier, int type);

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
                    if (controller_poll_device (active_devices.nth_data (i)) > 0) {
                        int message = controller_read_device_stream (active_devices.nth_data (i));
                        int type = message & 0x0000F0;
                        int key = 0x0000FF & (message >> 8);
                        int channel = (message & 0x00000F);
                        double velocity = ((127.0 - 0.0) / (8323072.0 - 65536.0)) *
                                        (double)((0xFF0000 & message) - 65536);
                        debug ("Velocity: %d, Key: %d, Type:%d, Channel:%d, Raw: %x\n",
                                (int)velocity,
                                key,
                                type,
                                channel,
                                message);
                        Idle.add (() => {
                            process_midi_signal (channel, type, key, (int)velocity);
                            return false;
                        });
                    }
                    Thread.yield ();
                    Thread.usleep (200);
                }
            }

            for (int i = 0; i < active_devices.length (); i++) {
                controller_close_connection (active_devices.nth_data (i));
            }

            Thread.exit (0);
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

        private void process_midi_signal (int channel, int type, int value, int velocity) {
            var handled = false;
            if (type == 144 || type == 176) {
                handled = midi_event_received (channel, value, type);
            }

            if (!handled) {
                // Classify MIDI signal type
                if (type == 144 || type == 128) {
                    // Note signal
                    process_note_signal (value, type, velocity, channel);
                } else if (type == 176) {
                    // CC signal
                    process_control_signal (channel, value, velocity);
                }
            }
        }

        private int szudzik_hash (int a, int b) {
            return a >= b ? a * a + a + b : a + b * b;
        }

        private void process_note_signal (int key, int is_pressed_type, int velocity, int channel) {
            int hash = szudzik_hash (channel, key);
            print (hash.to_string () + "\n");
            if (note_map.has_key (hash)) {
                process_control_signal (channel, note_map[hash], is_pressed_type == 144 ? velocity : 0, true);
            } else {
                receive_note_event (key,
                    velocity > 0 ? (is_pressed_type == 144) : false,
                    velocity > 0 ? velocity : 1,
                    channel > 3 ? 3 : channel);
            }
        }

        private void process_control_signal (int channel, int identifier, int value, bool already_hashed = false) {
            int index = 0;
            if (!already_hashed) {
                int hash = szudzik_hash (channel, identifier);
                if (control_map.has_key (hash)) {
                    index = control_map[hash];
                }
            } else {
                index = identifier;
            }

            if (index >= Shell.StyleControllerView.UI_INDEX_STYLE_INTRO_1 && index <= Shell.StyleControllerView.UI_INDEX_STYLE_START_STOP) {
                Application.main_window.style_controller_view.handle_midi_button_event (index, value > 0); // This is an event for style player
            } else if (index >= Shell.RegistryView.UI_INDEX_REG_1 && index <= Shell.RegistryView.UI_INDEX_REG_MEM) {
                Application.main_window.registry_panel.handle_midi_button_event (index, value > 0); // This is an event for registry memory
            }
        }

        public void set_control_map (int channel, int identifier, int type, int ui_control_index) {
            if (type == 144) {
                note_map.set (szudzik_hash (channel, identifier), ui_control_index);
            } else {
                control_map.set (szudzik_hash (channel, identifier), ui_control_index);
            }
            control_label_reverse_map.set (ui_control_index, _("#%d, Channel %d").printf (identifier, channel + 1));
        }

        public string get_assignment_label (int ui_control_index) {
            if (control_label_reverse_map.has_key (ui_control_index)) {
                return control_label_reverse_map[ui_control_index];
            }

            return "";
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
