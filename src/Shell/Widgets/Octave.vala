/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Widgets {
    public class Octave : Gtk.Widget, Gtk.Accessible {
        public uint8 index { get; protected set; }
        private const uint8[] BLACK_KEYS = { 1, 3, 6, 8, 10 };
        private const uint8[] WHITE_KEYS = { 0, 2, 4, 5, 7, 9, 11 };
        private const uint8[,] WHITE_NS = {
            {1, 1}, {1, 3}, {3, 3}, {6, 6}, {6, 8}, {8, 10}, {10, 10}
        };

        private Gtk.BoxLayout box_layout;
        private Key[] keys = new Key[12];

        private Gtk.EventControllerMotion motion_controller;
        private Gtk.GestureClick click_controller;

        public signal void key_pressed (uint8 index);
        public signal void key_released (uint8 index);

        public Octave (uint8 index) {
            Object (
                index: index,
                name: "octave",
                accessible_role: Gtk.AccessibleRole.TABLE,
                width_request: 200,
                height_request: 100,
                hexpand: true,
                vexpand: true
            );
        }

        construct {
            build_layout ();
            build_ui ();
            build_events ();
        }

        private void build_layout () {
            box_layout = new Gtk.BoxLayout (Gtk.Orientation.VERTICAL);
            set_layout_manager (box_layout);
        }

        private void build_ui () {
            var note_gauge = new Gtk.DrawingArea ();
            note_gauge.set_parent (note_gauge);

            var overlay = new Gtk.Overlay () {
                hexpand = true,
                vexpand = true
            };
            overlay.set_parent (this);

            var white_keys_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true,
                vexpand = true,
                homogeneous = true
            };
            overlay.set_child (white_keys_box);

            var black_keys_box_container = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            overlay.add_overlay (black_keys_box_container);

            var black_keys_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true,
                vexpand = true,
                height_request = 42
            };
            black_keys_box_container.append (black_keys_box);
            black_keys_box_container.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
                vexpand = true,
                can_target = false,
                css_classes = { "spacer" },
            });

            for (uint8 i = 0, j = 0; i < 12; i++) {
                var is_black = BLACK_KEYS[j] == i;
                keys[i] = new Key (i, is_black) {
                    hexpand = true
                };

                if (!is_black) {
                    white_keys_box.append (keys[i]);
                    black_keys_box.append (new Gtk.Separator (Gtk.Orientation.VERTICAL) {
                        css_classes = { "spacer" },
                        hexpand = true,
                        width_request = (
                            i == 4
                         ) ? 10 : (
                            i == 0 || i == 11 ? 6 : -1
                         ),
                        can_target = false
                    });
                } else {
                    black_keys_box.append (keys[i]);
                    j++;
                }
            }

            //  for (uint8 i = 0; i < 7; i++) {
            //      var key = new Key(WHITE_KEYS[i], false);
            //      white_keys_box.append (key);
            //      keys[WHITE_KEYS[i]] = key;
            //  }

            //  for (uint8 i = 0; i < 5; i++) {
            //      var key = new Key(BLACK_KEYS[i], false);
            //      white_keys_box.append (key);
            //      keys[BLACK_KEYS[i]] = key;
            //  }
        }

        private void build_events () {
            motion_controller = new Gtk.EventControllerMotion ();
            motion_controller.motion.connect ((x, y) => {
                for (uint8 i = 0; i < 5; i++) {
                    keys[BLACK_KEYS[i]].hovering = keys[BLACK_KEYS[i]].inside (this, x, y);
                }
                for (uint8 i = 0; i < 7; i++) {
                    if (!(
                        keys[WHITE_NS[i, 0]].hovering ||
                        keys[WHITE_NS[i, 1]].hovering
                    )) {
                        keys[WHITE_KEYS[i]].hovering = keys[WHITE_KEYS[i]].inside (this, x, y);
                    } else {
                        keys[WHITE_KEYS[i]].hovering = false;
                    }
                }
            });
            motion_controller.leave.connect (() => {
                for (uint8 i = 0; i < 12; i++) {
                    keys[i].hovering = false;
                }
            });
            add_controller (motion_controller);

            click_controller = new Gtk.GestureClick ();
            click_controller.pressed.connect ((n, x, y) => {
                for (uint8 i = 0; i < 12; i++) {
                    if (keys[i].inside (this, x, y)) {
                        key_pressed (i);
                    }
                }
            });
            click_controller.released.connect ((n, x, y) => {
                for (uint8 i = 0; i < 12; i++) {
                    if (keys[i].inside (this, x, y)) {
                        key_released (i);
                    }
                }
            });
            add_controller (click_controller);
        }
    }
}
