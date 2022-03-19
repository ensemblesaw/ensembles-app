/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
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
                                            "\t" +
                                            (((double)accomp_style.tempo / 100.0 >= 1) ? "" : " ") +
                                            "♩ =  " + accomp_style.tempo.to_string ());
            tempo_label.get_style_context ().add_class ("menu-item-description");
            tempo_label.halign = Gtk.Align.END;

            var copyright_button = new Gtk.Button.from_icon_name ("text-x-copying-symbolic", Gtk.IconSize.BUTTON) {
                margin_top = 6,
                margin_start = 4,
                margin_end = 4,
                tooltip_text = accomp_style.copyright_notice
            };
            copyright_button.get_style_context ().add_class ("menu-item-icon");

            var category_label = new Gtk.Label ("");
            var style_grid = new Gtk.Grid ();
            if (show_category) {
                category_label.set_text (accomp_style.genre);
                category_label.get_style_context ().add_class ("menu-item-annotation");
            }
            style_grid.attach (style_label, 0, 0, 1, 2);
            style_grid.attach (category_label, 1, 0, 2, 1);
            style_grid.attach (tempo_label, 1, 1, 1, 1);
            style_grid.attach (copyright_button, 2, 1, 1, 1);
            this.add (style_grid);
        }
    }
}
