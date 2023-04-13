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
                octaves[i] = new Octave (this, i);
                octaves[i].set_parent (this);
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
    }
}
