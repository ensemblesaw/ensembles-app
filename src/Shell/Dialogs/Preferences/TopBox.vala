/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright © 2019 Alain M. (https://github.com/alainm23/planner)<alainmh23@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Ensembles.Shell.Dialogs.Preferences.TopBox : Hdy.HeaderBar {
    public signal void back_activated ();
    public signal void done_activated ();

    public TopBox (string icon, string title) {
        decoration_layout = "close:";
        has_subtitle = false;
        show_close_button = false;
        get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var back_button = new Gtk.Button.with_mnemonic (_("Back"));
        back_button.always_show_image = true;
        back_button.can_focus = false;
        back_button.label = _("Back");
        back_button.margin = 3;
        back_button.valign = Gtk.Align.CENTER;
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);

        var title_icon = new Gtk.Image.from_icon_name (icon, Gtk.IconSize.LARGE_TOOLBAR);
        title_icon.halign = Gtk.Align.CENTER;
        title_icon.valign = Gtk.Align.CENTER;

        var title_button = new Gtk.Label (title);
        title_button.valign = Gtk.Align.CENTER;
        title_button.get_style_context ().add_class ("font-bold");
        title_button.get_style_context ().add_class ("h3");

        var top_grid = new Gtk.Grid ();
        top_grid.valign = Gtk.Align.CENTER;
        top_grid.column_spacing = 6;
        top_grid.add (title_icon);
        top_grid.add (title_button);

        var done_button = new Gtk.Button.with_label (_("Done"));
        done_button.get_style_context ().add_class ("flat");

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        header_box.hexpand = true;
        header_box.pack_start (back_button, false, false, 0);
        header_box.set_center_widget (top_grid);
        header_box.pack_end (done_button, false, false, 0);

        back_button.clicked.connect (() => {
            back_activated ();
        });

        done_button.clicked.connect (() => {
            done_activated ();
        });

        set_custom_title (header_box);
    }
}
