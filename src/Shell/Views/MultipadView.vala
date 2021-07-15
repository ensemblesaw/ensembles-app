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
    public class MultipadView : Gtk.Grid {
        Gtk.Button[] pads;
        Gtk.Button assign_button;
        Gtk.Button stop_button;
        public MultipadView () {
            var header = new Gtk.Label ("MULTIPAD VARIABLES");
            header.valign = Gtk.Align.CENTER;
            header.halign = Gtk.Align.START;
            header.set_opacity (0.4);

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            separator.valign = Gtk.Align.CENTER;

            attach (header, 0, 0, 4, 1);
            attach (separator, 3, 0, 5, 1);

            pads = new Gtk.Button [12];
            for (int i = 0; i < 6; i++) {
                pads[i] = new Gtk.Button ();
                pads[i + 6] = new Gtk.Button ();
                pads[i].width_request = 32;
                pads[i].hexpand = true;
                pads[i + 6].width_request = 32;
                pads[i + 6].hexpand = true;
                attach (pads[i], i, 1, 1, 1);
                attach (pads[i + 6], i, 2, 1, 1);
            }
            assign_button = new Gtk.Button.with_label ("Assign");
            assign_button.height_request = 80;
            assign_button.vexpand = true;
            assign_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            attach (assign_button, 7, 1, 1, 2);
            stop_button = new Gtk.Button.with_label ("Stop");
            stop_button.width_request = 51;
            attach (stop_button, 8, 1, 1, 2);
            margin = 4;
            show_all ();
        }
    }
}
