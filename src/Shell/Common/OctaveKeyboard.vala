/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class OctaveKeyboard : Gtk.Grid {
        Key[] keys;
        int _index;

        public signal void note_activate (int index, bool on);
        public OctaveKeyboard (int index) {
            _index = index;
            keys = new Key[12];
            for (int i = 0; i < 12; i++) {
                keys[i] = new Key (_index * 12 + i, ((i == 1) || (i == 3) || (i == 6) || (i == 8) || (i == 10))
                ? true
                : false);
            }

            var white_grid = new Gtk.Grid ();
            white_grid.attach (keys[0], 0, 0);
            white_grid.attach (keys[2], 1, 0);
            white_grid.attach (keys[4], 2, 0);
            white_grid.attach (keys[5], 3, 0);
            white_grid.attach (keys[7], 4, 0);
            white_grid.attach (keys[9], 5, 0);
            white_grid.attach (keys[11], 6, 0);

            var black_place_holder_1 = new Gtk.Separator (Gtk.Orientation.VERTICAL) {
                height_request = 0,
                width_request = 15,
                opacity = 0,
                hexpand = true
            };
            var black_place_holder_2 = new Gtk.Separator (Gtk.Orientation.VERTICAL) {
                height_request = 0,
                width_request = 14,
                opacity = 0,
                hexpand = true
            };
            var black_place_holder_3 = new Gtk.Separator (Gtk.Orientation.VERTICAL) {
                height_request = 0,
                width_request = 15,
                opacity = 0,
                hexpand = true
            };
            var black_place_holder_4 = new Gtk.Separator (Gtk.Orientation.VERTICAL) {
                height_request = 0,
                width_request = 15,
                opacity = 0,
                hexpand = true
            };
            var black_place_holder_5 = new Gtk.Separator (Gtk.Orientation.VERTICAL) {
                height_request = 0,
                width_request = 14,
                opacity = 0,
                hexpand = true
            };
            var black_place_holder_6 = new Gtk.Separator (Gtk.Orientation.VERTICAL) {
                height_request = 0,
                width_request = 14,
                opacity = 0,
                hexpand = true
            };
            var black_place_holder_7 = new Gtk.Separator (Gtk.Orientation.VERTICAL) {
                height_request = 0,
                width_request = 15,
                opacity = 0,
                hexpand = true
            };
            var black_place_holder_bottom = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
                height_request = 100,
                halign = Gtk.Align.END
            };

            var black_grid = new Gtk.Grid ();
            black_grid.attach (black_place_holder_1, 0, 0);
            black_grid.attach (keys[1], 1, 0);
            black_grid.attach (black_place_holder_2, 2, 0);
            black_grid.attach (keys[3], 3, 0);
            black_grid.attach (black_place_holder_3, 4, 0);
            black_grid.attach (black_place_holder_4, 5, 0);
            black_grid.attach (keys[6], 6, 0);
            black_grid.attach (black_place_holder_5, 7, 0);
            black_grid.attach (keys[8], 8, 0);
            black_grid.attach (black_place_holder_6, 9, 0);
            black_grid.attach (keys[10], 10, 0);
            black_grid.attach (black_place_holder_7, 11, 0);
            black_grid.attach (black_place_holder_bottom, 11, 1);

            var octave_overlay = new Gtk.Overlay () {
                height_request = 100,
                hexpand = true,
                vexpand = true
            };
            octave_overlay.add_overlay (white_grid);
            octave_overlay.add_overlay (black_grid);
            octave_overlay.set_overlay_pass_through (black_grid, true);

            attach (octave_overlay, 0, 0, 1, 1);

            keys[0].button_press_event.connect ((event) => {
                note_activate (0, true);
                return false;
            });
            keys[0].button_release_event.connect ((event) => {
                note_activate (0, false);
                return false;
            });
            keys[0].touch_event.connect ((event) => {
                if (event.get_event_type () == Gdk.EventType.TOUCH_BEGIN) {
                    note_activate (0, true);
                    set_note_on (0, true);
                }
                if (event.get_event_type () == Gdk.EventType.TOUCH_END) {
                    note_activate (0, false);
                    set_note_on (0, false);
                }
                return false;
            });
            keys[1].button_press_event.connect ((event) => {
                note_activate (1, true);
                return false;
            });
            keys[1].button_release_event.connect ((event) => {
                note_activate (1, false);
                return false;
            });
            keys[1].touch_event.connect ((event) => {
                if (event.get_event_type () == Gdk.EventType.TOUCH_BEGIN) {
                    note_activate (1, true);
                    set_note_on (1, true);
                }
                if (event.get_event_type () == Gdk.EventType.TOUCH_END) {
                    note_activate (1, false);
                    set_note_on (1, false);
                }
                return false;
            });
            keys[2].button_press_event.connect ((event) => {
                note_activate (2, true);
                return false;
            });
            keys[2].button_release_event.connect ((event) => {
                note_activate (2, false);
                return false;
            });
            keys[2].touch_event.connect ((event) => {
                if (event.get_event_type () == Gdk.EventType.TOUCH_BEGIN) {
                    note_activate (2, true);
                    set_note_on (2, true);
                }
                if (event.get_event_type () == Gdk.EventType.TOUCH_END) {
                    note_activate (2, false);
                    set_note_on (2, false);
                }
                return false;
            });
            keys[3].button_press_event.connect ((event) => {
                note_activate (3, true);
                return false;
            });
            keys[3].button_release_event.connect ((event) => {
                note_activate (3, false);
                return false;
            });
            keys[3].touch_event.connect ((event) => {
                if (event.get_event_type () == Gdk.EventType.TOUCH_BEGIN) {
                    note_activate (3, true);
                    set_note_on (3, true);
                }
                if (event.get_event_type () == Gdk.EventType.TOUCH_END) {
                    note_activate (3, false);
                    set_note_on (3, false);
                }
                return false;
            });
            keys[4].button_press_event.connect ((event) => {
                note_activate (4, true);
                return false;
            });
            keys[4].button_release_event.connect ((event) => {
                note_activate (4, false);
                return false;
            });
            keys[4].touch_event.connect ((event) => {
                if (event.get_event_type () == Gdk.EventType.TOUCH_BEGIN) {
                    note_activate (4, true);
                    set_note_on (4, true);
                }
                if (event.get_event_type () == Gdk.EventType.TOUCH_END) {
                    note_activate (4, false);
                    set_note_on (4, false);
                }
                return false;
            });
            keys[5].button_press_event.connect ((event) => {
                note_activate (5, true);
                return false;
            });
            keys[5].button_release_event.connect ((event) => {
                note_activate (5, false);
                return false;
            });
            keys[5].touch_event.connect ((event) => {
                if (event.get_event_type () == Gdk.EventType.TOUCH_BEGIN) {
                    note_activate (5, true);
                    set_note_on (5, true);
                }
                if (event.get_event_type () == Gdk.EventType.TOUCH_END) {
                    note_activate (5, false);
                    set_note_on (5, false);
                }
                return false;
            });
            keys[6].button_press_event.connect ((event) => {
                note_activate (6, true);
                return false;
            });
            keys[6].button_release_event.connect ((event) => {
                note_activate (6, false);
                return false;
            });
            keys[6].touch_event.connect ((event) => {
                if (event.get_event_type () == Gdk.EventType.TOUCH_BEGIN) {
                    note_activate (6, true);
                    set_note_on (6, true);
                }
                if (event.get_event_type () == Gdk.EventType.TOUCH_END) {
                    note_activate (6, false);
                    set_note_on (6, false);
                }
                return false;
            });
            keys[7].button_press_event.connect ((event) => {
                note_activate (7, true);
                return false;
            });
            keys[7].button_release_event.connect ((event) => {
                note_activate (7, false);
                return false;
            });
            keys[7].touch_event.connect ((event) => {
                if (event.get_event_type () == Gdk.EventType.TOUCH_BEGIN) {
                    note_activate (7, true);
                    set_note_on (7, true);
                }
                if (event.get_event_type () == Gdk.EventType.TOUCH_END) {
                    note_activate (7, false);
                    set_note_on (7, false);
                }
                return false;
            });
            keys[8].button_press_event.connect ((event) => {
                note_activate (8, true);
                return false;
            });
            keys[8].button_release_event.connect ((event) => {
                note_activate (8, false);
                return false;
            });
            keys[8].touch_event.connect ((event) => {
                if (event.get_event_type () == Gdk.EventType.TOUCH_BEGIN) {
                    note_activate (8, true);
                    set_note_on (8, true);
                }
                if (event.get_event_type () == Gdk.EventType.TOUCH_END) {
                    note_activate (8, false);
                    set_note_on (8, false);
                }
                return false;
            });
            keys[9].button_press_event.connect ((event) => {
                note_activate (9, true);
                return false;
            });
            keys[9].button_release_event.connect ((event) => {
                note_activate (9, false);
                return false;
            });
            keys[9].touch_event.connect ((event) => {
                if (event.get_event_type () == Gdk.EventType.TOUCH_BEGIN) {
                    note_activate (9, true);
                    set_note_on (9, true);
                }
                if (event.get_event_type () == Gdk.EventType.TOUCH_END) {
                    note_activate (9, false);
                    set_note_on (9, false);
                }
                return false;
            });
            keys[10].button_press_event.connect ((event) => {
                note_activate (10, true);
                return false;
            });
            keys[10].button_release_event.connect ((event) => {
                note_activate (10, false);
                return false;
            });
            keys[10].touch_event.connect ((event) => {
                if (event.get_event_type () == Gdk.EventType.TOUCH_BEGIN) {
                    note_activate (10, true);
                    set_note_on (10, true);
                }
                if (event.get_event_type () == Gdk.EventType.TOUCH_END) {
                    note_activate (10, false);
                    set_note_on (10, false);
                }
                return false;
            });
            keys[11].button_press_event.connect ((event) => {
                note_activate (11, true);
                return false;
            });
            keys[11].button_release_event.connect ((event) => {
                note_activate (11, false);
                return false;
            });
            keys[11].touch_event.connect ((event) => {
                if (event.get_event_type () == Gdk.EventType.TOUCH_BEGIN) {
                    note_activate (11, true);
                    set_note_on (11, true);
                }
                if (event.get_event_type () == Gdk.EventType.TOUCH_END) {
                    note_activate (11, false);
                    set_note_on (11, false);
                }
                return false;
            });
        }

        public void set_note_on (int key, bool on, bool? auto = false) {
            if (on) {
                keys[key].note_on (auto);
            } else {
                keys[key].note_off (auto);
            }
        }
        public void update_split () {
            for (int i = 0; i < 12; i++) {
                keys[i].update_split ();
            }
        }
    }
}
