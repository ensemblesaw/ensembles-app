/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Models;

namespace Ensembles.Shell.Widgets.Display {
    public class StyleMenuItem : Gtk.ListBoxRow {
        public Style style { get; set; }
        public bool show_category { get; set; }

        public StyleMenuItem (Style style, bool show_category = false) {
            Object (
                style: style,
                show_category: show_category
            );

            build_ui ();
        }

        private void build_ui () {
            add_css_class ("menu-item");

            var menu_item_grid = new Gtk.Grid ();
            set_child (menu_item_grid);

            var style_name_label = new Gtk.Label (style.name) {
                halign = Gtk.Align.START,
                hexpand = true
            };
            style_name_label.add_css_class ("menu-item-name");
            menu_item_grid.attach (style_name_label, 0, 0, 1, 2);

            var tempo_label = new Gtk.Label (style.time_signature_n.to_string () +
            "/" +
            style.time_signature_d.to_string () +
            "\t" +
            (((double)style.tempo / 100.0 >= 1) ? "" : " ") +
            "♩ =  " + style.tempo.to_string ()) {
                halign = Gtk.Align.END
            };
            tempo_label.add_css_class ("menu-item-description");
            menu_item_grid.attach (tempo_label, 1, 1, 1, 1);

            var category_label = new Gtk.Label ("");
            if (show_category) {
                category_label.set_text (style.genre);
                category_label.add_css_class ("menu-item-category");
            }

            menu_item_grid.attach (category_label, 1, 0, 2, 1);

            if (style.copyright_notice != null && style.copyright_notice != "") {
                var copyright_button = new Gtk.Button.from_icon_name ("text-x-copying-symbolic") {
                    margin_top = 6,
                    margin_start = 4,
                    margin_end = 4,
                    tooltip_text = style.copyright_notice
                };
                copyright_button.add_css_class ("menu-item-icon");
                menu_item_grid.attach (copyright_button, 2, 1, 1, 1);
            }
        }
    }
}
