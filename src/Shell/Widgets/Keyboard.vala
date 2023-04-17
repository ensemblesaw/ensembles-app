/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Widgets {
    public class Keyboard : Gtk.Widget, Gtk.Accessible {
        public uint8 n_octaves { get; protected set; }
        private Octave[] octaves;

        private bool update = true;
        private int width;
        private int height;

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
            for (uint8 i = 0; i < n_octaves; i++) {
                var octave = new Octave (this, i);
                octave.key_pressed.connect (handle_key_press);
                octave.key_released.connect (handle_key_release);
                octave.set_parent (this);
                octaves[i] = (owned) octave;
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
        }

        private void handle_key_release (uint8 key_index) {
            var event = new Fluid.MIDIEvent ();
            event.set_channel (17); // Channel 17 handles user key events
            event.set_type (MIDI.EventType.NOTE_OFF);
            event.set_key (key_index + 12 * octave_offset);

            key_event (event);
        }

        public void set_key_illumination (uint8 key_index, bool active) {
            uint8 octave_index = (key_index / 12) - octave_offset;
            octaves[octave_index].set_key_illumination (key_index - (octave_offset * 12), active);
        }
    }
}
