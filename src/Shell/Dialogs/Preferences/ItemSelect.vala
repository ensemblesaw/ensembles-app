/*
 * Copyright © 2019 Alain M. (https://github.com/alainm23/planner)<alainmh23@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Ensembles.Shell.Dialogs.Preferences.ItemSelect : Gtk.Box {
    private Gtk.ComboBoxText combobox;

    public signal void activated (int active);

    public ItemSelect (string title, int active, List<string> items, bool visible_separator=true) {
        Object (
            title: title,
            orientation: Gtk.Orientation.VERTICAL,
            spacing: 0
        );
        var title_label = new Gtk.Label (title);
        title_label.get_style_context ().add_class ("font-weight-600");

        combobox = new Gtk.ComboBoxText ();
        combobox.can_focus = false;
        combobox.valign = Gtk.Align.CENTER;
        combobox.width_request = 150;

        foreach (var item in items) {
            combobox.append_text (item);
        }

        combobox.active = active;

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        box.margin_start = 12;
        box.margin_end = 12;
        box.margin_top = 3;
        box.margin_bottom = 3;
        box.hexpand = true;
        box.append (title_label);
        box.append (combobox);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.get_style_context ().add_class ("preferences-view");
        main_box.hexpand = true;
        main_box.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        main_box.append (box);

        if (visible_separator == true) {
            main_box.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        }

        combobox.changed.connect (() => {
            activated (combobox.active);
        });

        append (main_box);
    }

    public void set_combobox_sensitive (bool sensitive) {
        combobox.set_sensitive (sensitive);
    }
}
