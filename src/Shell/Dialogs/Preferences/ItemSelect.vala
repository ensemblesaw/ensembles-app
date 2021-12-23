/*
 * Copyright © 2019 Alain M. (https://github.com/alainm23/planner)<alainmh23@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Ensembles.Shell.Dialogs.Preferences.ItemSelect : Gtk.EventBox {
    private Gtk.ComboBoxText combobox;

    public signal void activated (int active);

    public ItemSelect (string title, int active, List<string> items, bool visible_separator=true) {
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
        box.pack_start (title_label, false, true, 0);
        box.pack_end (combobox, false, true, 0);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.get_style_context ().add_class ("preferences-view");
        main_box.hexpand = true;
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, true, 0);
        main_box.pack_start (box, false, true, 0);

        if (visible_separator == true) {
            main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, true, 0);
        }

        combobox.changed.connect (() => {
            activated (combobox.active);
        });

        add (main_box);
    }

    public void set_combobox_sensitive (bool sensitive) {
        combobox.set_sensitive (sensitive);
    }
}
