/*-
 * Copyright (c) 2021-2022 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License 
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
 */

namespace Ensembles.Shell { 
    public class OctaveKeyboard : Gtk.Grid {
        Key[] keys;
        int _index;

        public signal void note_activate (int index, bool on);
        public OctaveKeyboard(int index) {
            _index = index;
            keys = new Key[12];
            for (int i = 0; i < 12; i++) {
                keys[i] = new Key (_index * 12 + i, ((i == 1) || (i == 3) || (i == 6) || (i == 8) || (i == 10)) ? true : false);
            }

            var white_grid = new Gtk.Grid ();
            white_grid.attach (keys[0], 0, 0, 1, 1);
            white_grid.attach (keys[2], 1, 0, 1, 1);
            white_grid.attach (keys[4], 2, 0, 1, 1);
            white_grid.attach (keys[5], 3, 0, 1, 1);
            white_grid.attach (keys[7], 4, 0, 1, 1);
            white_grid.attach (keys[9], 5, 0, 1, 1);
            white_grid.attach (keys[11],6, 0, 1, 1);

            var black_grid = new Gtk.Grid ();
            black_grid.attach (keys[1], 0, 0, 1, 1);
            black_grid.attach (keys[3], 1, 0, 1, 1);
            black_grid.attach (keys[6], 2, 0, 1, 1);
            black_grid.attach (keys[8], 3, 0, 1, 1);
            black_grid.attach (keys[10],4, 0, 1, 1);
            keys[1].margin_start = 18;
            keys[1].margin_end = 5;
            keys[3].margin_start = 6;
            keys[3].margin_end = 14;
            keys[6].margin_start = 23;
            keys[6].margin_end = 10;
            keys[8].margin_end = 10;
            keys[10].margin_end = 18;
            black_grid.valign = Gtk.Align.START;

            var octave_overlay = new Gtk.Overlay ();
            octave_overlay.height_request = 168;
            octave_overlay.hexpand = true;
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
            keys[1].button_press_event.connect ((event) => {
                note_activate (1, true);
                return false;
            });
            keys[1].button_release_event.connect ((event) => {
                note_activate (1, false);
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
            keys[3].button_press_event.connect ((event) => {
                note_activate (3, true);
                return false;
            });
            keys[3].button_release_event.connect ((event) => {
                note_activate (3, false);
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
            keys[5].button_press_event.connect ((event) => {
                note_activate (5, true);
                return false;
            });
            keys[5].button_release_event.connect ((event) => {
                note_activate (5, false);
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
            keys[7].button_press_event.connect ((event) => {
                note_activate (7, true);
                return false;
            });
            keys[7].button_release_event.connect ((event) => {
                note_activate (7, false);
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
            keys[9].button_press_event.connect ((event) => {
                note_activate (9, true);
                return false;
            });
            keys[9].button_release_event.connect ((event) => {
                note_activate (9, false);
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
            keys[11].button_press_event.connect ((event) => {
                note_activate (11, true);
                return false;
            });
            keys[11].button_release_event.connect ((event) => {
                note_activate (11, false);
                return false;
            });
        }

        public void set_note_on (int key, bool on) {
            if (on) {
                keys[key].note_on ();
            } else {
                keys[key].note_off ();
            }
        }
        public void update_split () {
            for (int i = 0; i < 12; i++) {
                keys[i].update_split ();
            }
        }
    }
}