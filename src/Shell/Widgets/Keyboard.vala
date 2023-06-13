/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Widgets {
    public class Keyboard : Gtk.Widget, Gtk.Accessible {
        public uint8 n_octaves { get; protected set; }
        private Octave[] octaves;
        private bool[] key_pressed;

        private double[] motion_x;
        private double[] motion_y;

        private bool update = true;
        private int width;
        private int height;

        public uint8 motion_x_control = MIDI.Control.EXPLICIT_PITCH;
        public uint8 motion_y_control = MIDI.Control.CUT_OFF;
        public bool motion_control_enabled = false;

        private int control_x = 64;
        private int previous_control_y = 64;
        private int control_y = 40;

        private uint8 _zoom_level;
        public uint8 zoom_level {
            get {
                return _zoom_level;
            }
            set {
                _zoom_level = value.clamp (0, 255);
                if (_zoom_level == 0) {
                    width_request = -1;
                } else {
                    width_request = value * 16 + 1000;
                }
            }
        }

        public int8 octave_offset { get; set; }

        public signal void key_event (Fluid.MIDIEvent midi_event);

        public Keyboard (uint8 n_octaves) {
            Object (
                accessible_role: Gtk.AccessibleRole.TABLE,
                name: "keyboard",
                css_name: "keyboard",
                layout_manager: new Gtk.BoxLayout (Gtk.Orientation.HORIZONTAL),
                height_request: 100,
                n_octaves: n_octaves
            );

            build_ui ();
        }

        ~Keyboard () {
            update = false;
        }

        construct {
            build_events ();
        }

        private void build_ui () {
            octaves = new Octave[n_octaves];
            key_pressed = new bool[n_octaves * 12];
            motion_x = new double[n_octaves];
            motion_y = new double[n_octaves];
            for (uint8 i = 0; i < n_octaves; i++) {
                var octave = new Octave (this, i);
                octave.key_pressed.connect (handle_key_press);
                octave.key_released.connect (handle_key_release);
                octave.key_motion.connect (handle_key_motion);
                octave.set_parent (this);
                octaves[i] = (owned) octave;

                motion_x[i] = 0;
                motion_y[i] = 0;
            }

            Timeout.add (80, () => {
                Idle.add (() => {
                    if (width != get_allocated_width () || height != get_allocated_height ()) {
                        for (uint8 i = 0; i < n_octaves; i++) {
                            octaves[i].draw_keys ();
                        }

                        width = get_allocated_width ();
                        height = get_allocated_height ();
                    }

                    return false;
                }, Priority.LOW);
                return update;
            }, Priority.LOW);
        }

        private void build_events () {
            this.destroy.connect (() => {
                update = false;
            });
        }

        private void handle_key_press (uint8 key_index) {
            var event = new Fluid.MIDIEvent ();
            event.set_channel (17); // Channel 17 handles user key events
            event.set_type (MIDI.EventType.NOTE_ON);
            event.set_key (key_index + 12 * octave_offset);
            event.set_velocity (100);

            key_event (event);

            key_pressed[key_index] = true;
        }

        private void handle_key_release (uint8 key_index) {
            var event = new Fluid.MIDIEvent ();
            event.set_channel (17); // Channel 17 handles user key events
            event.set_type (MIDI.EventType.NOTE_OFF);
            event.set_key (key_index + 12 * octave_offset);

            key_event (event);

            previous_control_y = control_y;
            key_pressed[key_index] = false;

            if (motion_control_enabled) {
                var any_pressed = false;
                for (int i = 0; i < key_pressed.length; i++) {
                    any_pressed = any_pressed || key_pressed[i];
                }

                if (!any_pressed) {
                    var event_x = new Fluid.MIDIEvent ();
                    event_x.set_channel (17);
                    event_x.set_type (MIDI.EventType.CONTROL_CHANGE);
                    event_x.set_control (motion_x_control);
                    event_x.set_value (64);
                    key_event (event_x);
                }
            }
        }

        private void handle_key_motion (uint8 octave_index, double x, double y) {
            if (motion_control_enabled) {
                motion_x[octave_index] = x;
                motion_y[octave_index] = y;

                double avg_x = 0;
                double avg_y = 0;
                uint8 n = (uint8) octaves.length;

                for (uint8 i = 0; i < n; i++) {
                    avg_x += motion_x[i];
                    avg_y += motion_y[i];
                }

                var event_x = new Fluid.MIDIEvent ();
                event_x.set_channel (17); // Channel 17 handles user key events
                event_x.set_type (MIDI.EventType.CONTROL_CHANGE);
                event_x.set_control (motion_x_control);
                control_x = (64 + (int) (127 * avg_x / n));
                event_x.set_value (control_x);
                if (control_x > 127) {
                    control_x = 127;
                } else if (control_x < 0) {
                    control_x = 0;
                }

                key_event (event_x);

                var event_y = new Fluid.MIDIEvent ();
                event_y.set_channel (17); // Channel 17 handles user key events
                event_y.set_type (MIDI.EventType.CONTROL_CHANGE);
                event_y.set_control (motion_y_control);
                control_y = previous_control_y + (int) (127 * avg_y / n);
                if (control_y > 127) {
                    control_y = 127;
                } else if (control_y < 0) {
                    control_y = 0;
                }

                event_y.set_value (control_y);

                key_event (event_y);
            }
        }

        public void set_key_illumination (uint8 key_index, bool active) {
            uint8 octave_index = (key_index / 12) - octave_offset;
            octaves[octave_index].set_key_illumination (key_index - (octave_offset * 12), active);
        }
    }
}
