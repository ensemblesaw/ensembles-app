/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright © 2019 Alain M. (https://github.com/alainm23/planner)<alainmh23@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Ensembles.Shell.Dialogs.Preferences.TopBox : Gtk.Box {
    public signal void back_activated ();
    public signal void done_activated ();

    public TopBox (string icon, string title) {
        get_style_context ().add_class (Granite.STYLE_CLASS_FLAT);

        var back_button = new Gtk.Button.with_mnemonic (_("Back")) {
            can_focus = false,
            margin_top = 3,
            margin_bottom = 3,
            margin_start = 3,
            margin_end = 3,
            valign = Gtk.Align.CENTER,
            label = _("Back")
        };
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);

        var title_icon = new Gtk.Image.from_icon_name (icon) {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };

        var title_button = new Gtk.Label (title) {
            valign = Gtk.Align.CENTER
        };
        title_button.get_style_context ().add_class ("font-bold");
        title_button.get_style_context ().add_class ("h3");

        var top_grid = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            valign = Gtk.Align.CENTER
        };
        top_grid.append (title_icon);
        top_grid.append (title_button);

        var done_button = new Gtk.Button.with_label (_("Done"));
        done_button.get_style_context ().add_class (Granite.STYLE_CLASS_FLAT);

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        header_box.hexpand = true;
        header_box.append (back_button);
        header_box.append (top_grid);
        header_box.append (done_button);

        var header_bar = new Adw.HeaderBar () {
            decoration_layout = ""
        };

        header_bar.set_title_widget (header_box);

        back_button.clicked.connect (() => {
            back_activated ();
        });

        done_button.clicked.connect (() => {
            done_activated ();
        });

        append(header_bar);
    }
}
