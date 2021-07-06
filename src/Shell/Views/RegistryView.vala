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
    public class RegistryView : Gtk.Grid {
        Gtk.SpinButton bank_select;
        Gtk.Button[] registry_buttons;
        Gtk.Button memory_button;
        public RegistryView () {
            row_homogeneous = true;
            vexpand = true;
            bank_select = new Gtk.SpinButton.with_range (1, 10, 1);
            attach (bank_select, 0, 0, 1, 1);

            var button_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            button_box.width_request = 337;

            registry_buttons = new Gtk.Button [10];
            for (int i = 0; i < 10; i ++) {
                registry_buttons[i] = new Gtk.Button.with_label ((i + 1).to_string ());
                button_box.pack_start (registry_buttons[i]);
            }
            button_box.set_layout (Gtk.ButtonBoxStyle.EXPAND);
            button_box.hexpand = true;
            attach (button_box, 1, 0, 1, 1);
            memory_button = new Gtk.Button.with_label ("Memorize");
            attach (memory_button, 2, 0, 1, 1);

            var bank_label = new Gtk.Label ("BANK");
            bank_label.set_opacity (0.4);
            var registry_label = new Gtk.Label ("REGISTRY MEMORY");
            registry_label.set_opacity (0.4);

            attach (bank_label, 0, 1, 1, 1);
            attach (registry_label, 1, 1, 1, 1);

            column_spacing = 4;
            margin = 4;

            this.show_all ();

        }
    }
}