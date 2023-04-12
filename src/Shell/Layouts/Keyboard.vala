/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Shell.Widgets;

namespace Ensembles.Shell.Layouts {
    public class Keyboard : Gtk.Grid {
        private uint8 _zoom_level;
        public uint8 zoom_level {
            get {
                return _zoom_level;
            }
            set {
                _zoom_level = value.clamp (0, 255);
                keyboard_container.width_request = (int) _zoom_level * 16 + 1000;
            }
        }
        private Gtk.Overlay keyboard_info_bar;
        private Gtk.Box keyboard_container;
        private Octave[] octaves = new Octave[5];

        public Keyboard () {
            Object (
                hexpand: true,
                vexpand: true,
                height_request: 128
            );
        }

        construct {
            add_css_class ("panel");
            add_css_class ("keyboard");
            build_ui ();
        }

        private void build_ui () {
            keyboard_info_bar = new Gtk.Overlay () {
                hexpand = true,
                height_request = 32
            };
            keyboard_info_bar.add_css_class ("keyboard-info-bar");
            attach (keyboard_info_bar, 0, 0);

            var keyboard_button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8) {
                halign = Gtk.Align.END
            };
            keyboard_info_bar.set_child (keyboard_button_box);

            var zoom_in_button = new Gtk.Button.from_icon_name ("zoom-in-symbolic");
            zoom_in_button.clicked.connect (() => {
                zoom_level += 48;
            });
            keyboard_button_box.append (zoom_in_button);

            var zoom_out_button = new Gtk.Button.from_icon_name ("zoom-out-symbolic");
            zoom_out_button.clicked.connect (() => {
                zoom_level -= 48;
            });
            keyboard_button_box.append (zoom_out_button);

            var zoom_reset_button = new Gtk.Button.from_icon_name ("zoom-fit-best-symbolic");
            zoom_reset_button.clicked.connect (() => {
                zoom_level = 0;
            });
            keyboard_button_box.append (zoom_reset_button);

            var keyboard_scrollable = new Gtk.ScrolledWindow () {
                hexpand = true,
                vexpand = true,
                kinetic_scrolling = false,
                has_frame = false,

            };

            keyboard_scrollable.set_placement (Gtk.CornerType.BOTTOM_LEFT);
            attach (keyboard_scrollable, 0, 1);

            keyboard_container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            keyboard_scrollable.set_child (keyboard_container);

            for (uint8 i = 0; i < 5; i++) {
                var octave = new Octave (i);
                keyboard_container.append (octave);
                octave.key_pressed.connect (handle_onscreen_key_press);
                octaves[i] = octave;
            }

        }

        private void handle_onscreen_key_press (uint8 index) {

        }
    }
}
