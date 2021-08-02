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
    public class StyleMenu : WheelScrollableWidget {
        Gtk.Button close_button;
        Gtk.ListBox main_list;

        StyleItem[] style_rows;

        public signal void close_menu ();
        public signal void change_style (Ensembles.Core.Style accomp_style);
        public StyleMenu () {
            this.get_style_context ().add_class ("menu-background");

            close_button = new Gtk.Button.from_icon_name ("application-exit-symbolic", Gtk.IconSize.BUTTON);
            close_button.margin_end = 4;
            close_button.halign = Gtk.Align.END;


            var headerbar = new Hdy.HeaderBar ();
            headerbar.set_title ("Style");
            headerbar.set_subtitle ("Pick a Rhythm to accompany you");
            headerbar.get_style_context ().add_class ("menu-header");
            headerbar.pack_start (close_button);
            main_list = new Gtk.ListBox ();
            main_list.get_style_context ().add_class ("menu-box");

            var scrollable = new Gtk.ScrolledWindow (null, null);
            scrollable.hexpand = true;
            scrollable.vexpand = true;
            scrollable.margin = 8;
            scrollable.add (main_list);

            this.attach (headerbar, 0, 0, 1, 1);
            this.attach (scrollable, 0, 1, 1, 1);


            close_button.clicked.connect (() => {
                close_menu ();
            });

            main_list.set_selection_mode (Gtk.SelectionMode.BROWSE);
            main_list.row_activated.connect ((row) => {
                int index = row.get_index ();
                change_style (style_rows[index].accomp_style);
            });
        }

        public void populate_style_menu (Ensembles.Core.Style[] accomp_style) {
            style_rows = new StyleItem [accomp_style.length];
            string temp_category = "";
            for (int i = 0; i < accomp_style.length; i++) {
                bool show_category = false;
                if (temp_category != accomp_style[i].genre) {
                    temp_category = accomp_style[i].genre;
                    show_category = true;
                }
                var row = new StyleItem (accomp_style[i], show_category);
                style_rows[i] = row;
                main_list.insert (row, -1);
            }

            main_list.select_row (style_rows[0]);
            main_list.show_all ();
            Ensembles.Core.CentralBus.set_styles_ready (true);
        }
    }
}
