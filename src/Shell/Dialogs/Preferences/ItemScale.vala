/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright © 2019 Alain M. (https://github.com/alainm23/planner)<alainmh23@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Ensembles.Shell.Dialogs.Preferences.ItemScale : Gtk.EventBox {
    private Gtk.Scale scale;

    public signal void changed (double value);

    string _title;

    public string title {
        get {
            return _title;
        }
        set {
            _title = value;
            title_label.set_text (_title);
        }
    }

    Gtk.Label title_label;

    public ItemScale (string title, double value, double lower_limit, double upper_limit, double step, bool visible_separator=true) {
        title_label = new Gtk.Label (title);
        title_label.get_style_context ().add_class ("font-weight-600");

        scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, lower_limit, upper_limit, step);
        scale.valign = Gtk.Align.CENTER;
        scale.width_request = 150;
        scale.draw_value = false;

        scale.set_value (value);

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        box.margin_start = 12;
        box.margin_end = 12;
        box.margin_top = 3;
        box.margin_bottom = 3;
        box.hexpand = true;
        box.pack_start (title_label, false, true, 0);
        box.pack_end (scale, false, true, 0);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.get_style_context ().add_class ("preferences-view");
        main_box.hexpand = true;
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, true, 0);
        main_box.pack_start (box, false, true, 0);

        if (visible_separator == true) {
            main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, true, 0);
        }

        scale.change_value.connect ((scroll, value) => {
            if (value >= lower_limit && value <= upper_limit) {
                changed (value);
            }
            return false;
        });

        add (main_box);
    }

    public void set_scale_sensitive (bool sensitive) {
        scale.set_sensitive (sensitive);
    }
}
