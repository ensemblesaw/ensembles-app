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
    public class StyleItem : Gtk.ListBoxRow {
        public Ensembles.Core.Style accomp_style;
        public StyleItem (Ensembles.Core.Style accomp_style, bool show_category) {
            this.accomp_style = accomp_style;

            var style_label = new Gtk.Label (accomp_style.name);
            style_label.get_style_context ().add_class ("menu-item-label");
            style_label.halign = Gtk.Align.START;
            style_label.hexpand = true;

            var tempo_label = new Gtk.Label (accomp_style.timesignature_n.to_string () +
                                            "/" +
                                            accomp_style.timesignature_d.to_string () +
                                            "\t|\t♩ =  " + accomp_style.tempo.to_string ());
            tempo_label.get_style_context ().add_class ("menu-item-description");
            tempo_label.halign = Gtk.Align.END;
            var category_label = new Gtk.Label ("");
            var style_grid = new Gtk.Grid ();
            if (show_category) {
                category_label.set_text (accomp_style.genre);
                category_label.get_style_context ().add_class ("menu-item-annotation");
            }
            style_grid.attach (style_label, 1, 0, 1, 2);
            style_grid.attach (category_label, 2, 0, 1, 1);
            style_grid.attach (tempo_label, 2, 1, 1, 1);
            this.add (style_grid);
        }
    }
}
