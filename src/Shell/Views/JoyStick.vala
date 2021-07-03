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
    public class JoyStick : Gtk.Grid {
        Gtk.Button x_assign_button;
        Gtk.Button y_assign_button;
        public JoyStick () {
            x_assign_button = new Gtk.Button.with_label ("X-Assign");
            y_assign_button = new Gtk.Button.with_label ("Y-Assign");
            var button_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            button_box.margin = 4;
            button_box.width_request = 140;
            button_box.set_layout (Gtk.ButtonBoxStyle.EXPAND);
            button_box.pack_start (x_assign_button);
            button_box.pack_end (y_assign_button);
            attach (button_box, 0, 0, 1, 1);
            var main_box = new Gtk.Grid ();
            main_box.vexpand = true;
            main_box.margin = 4;
            main_box.get_style_context ().add_class ("joystick-pad");
            attach (main_box, 0, 1, 1, 1);
            get_style_context ().add_class ("joystick-background");
            width_request = 150;
        }
    }
}