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
    public class ToggleSwitch : Gtk.Button {
        Gtk.Label text_label;
        Gtk.Box indicator_box;
        bool on = false;
        public signal void toggled (bool active);
        public ToggleSwitch (string label) {
            text_label = new Gtk.Label (label);
            indicator_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            indicator_box.height_request = 4;
            indicator_box.get_style_context ().add_class ("toggle-indicator");
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            box.pack_start (indicator_box);
            box.pack_end (text_label);

            this.add (box);

            this.clicked.connect (() => {
                if (on) {
                    set_active (false);
                } else {
                    set_active (true);
                }
                toggled (on);
            });
            get_style_context ().remove_class ("toggle");
            get_style_context ().add_class ("toggle-switch");
        }

        public void set_active (bool active) {
            if (active) {
                on = true;
                indicator_box.get_style_context ().add_class ("toggle-indicator-active");
            } else {
                on = false;
                indicator_box.get_style_context ().remove_class ("toggle-indicator-active");
            }
        }
    }
}
