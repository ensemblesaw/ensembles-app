/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Shell.Widgets.Display;
using Ensembles.Models;

namespace Ensembles.Shell.Layouts.Display {
    public class StyleScreen : DisplayWindow {
        private Gtk.ListBox main_list_box;
        //  StyleMenuItem[] style_menu_items;

        public StyleScreen () {
            base (_("Style"), _("Pick a Rhythm to accompany you"));
        }

        construct {
            build_ui ();
            build_events ();
        }

        private void build_ui () {
            var scrollable = new Gtk.ScrolledWindow () {
                hexpand = true,
                vexpand = true,
                margin_start = 8,
                margin_end = 8,
                margin_top = 8,
                margin_bottom = 8
            };
            append (scrollable);

            main_list_box = new Gtk.ListBox () {
                selection_mode = Gtk.SelectionMode.SINGLE
            };
            main_list_box.get_style_context ().add_class ("menu-box");
            scrollable.set_child (main_list_box);
        }

        public void build_events () {
            main_list_box.row_activated.connect ((item) => {
                var style_item = (StyleMenuItem) item;

                Application.arranger_workstation.queue_change_style (style_item.style);
            });

            Application.event_bus.arranger_ready.connect (() => {
                Timeout.add_seconds (1, () => {
                    populate (Application.arranger_workstation.styles);
                    Idle.add (() => {
                        var row_to_select = main_list_box.get_row_at_index (0);
                        main_list_box.select_row (row_to_select);
                        Application.arranger_workstation.queue_change_style (((StyleMenuItem) row_to_select).style);
                        return false;
                    });
                    return false;
                });
            });
        }

        public void populate (Style[] styles) {
            Console.log ("Populating style list…");
            //  style_menu_items = new StyleMenuItem[styles.length];

            var temp_category = "";
            for (uint16 i = 0; i < styles.length; i++) {
                var show_category = false;
                if (temp_category != styles[i].genre) {
                    temp_category = styles[i].genre;
                    show_category = true;
                }

                var menu_item = new StyleMenuItem (styles[i], show_category);
                //  style_menu_items[i] = menu_item;
                main_list_box.insert (menu_item, -1);
            }

            min_value = 0;
            max_value = styles.length - 1;
        }

        public void scroll_to_selected_row () {
            var selected_item = main_list_box.get_selected_row ();
            if (selected_item != null) {
                selected_item.grab_focus ();

                //  var adj = main_list_box.get_adjustment ();
                //  if (adj != null) {
                //      int height, _htemp;
                //      height = selected_item.get_allocated_height ();

                //      Timeout.add (200, () => {
                //          adj.set_value (_selected_index * height);
                //          return false;
                //      });
                //  }
            }
        }
    }
}
