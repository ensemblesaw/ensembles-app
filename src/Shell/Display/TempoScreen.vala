/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class TempoScreen : WheelScrollableWidget {
        Gtk.SpinButton tempo_spin_button;
        Gtk.Button tap_button;

        public signal void close_screen ();
        public signal void changed (int tempo);
        public TempoScreen () {
            min_value = 40;
            max_value = 200;
            row_spacing = 8;
            get_style_context ().add_class ("quick-mod");

            var close_button = new Gtk.Button.from_icon_name ("window-close-symbolic", Gtk.IconSize.BUTTON);
            close_button.get_style_context ().add_class ("quick-mod-close-button");
            close_button.clicked.connect (() => {
                close_screen ();
            });
            attach (close_button, 0, 0, 1, 1);

            var header = new Gtk.Label (_("Tempo")) {
                xalign = 0,
                hexpand = true
            };
            header.get_style_context ().add_class ("quick-mod-header");
            attach (header, 1, 0, 1, 1);

            var tempo_grid = new Gtk.Grid ();
            tempo_grid.column_homogeneous = true;
            tempo_grid.row_spacing = 4;
            tempo_grid.column_spacing = 4;
            tempo_grid.get_style_context ().add_class ("quick-mod-grid");

            var tempo_label = new Gtk.Label (_("Beats Per Minute"));
            tempo_spin_button = new Gtk.SpinButton.with_range (40, 200, 1);
            tempo_grid.attach (tempo_label, 0, 0, 1, 1);
            tempo_grid.attach (tempo_spin_button, 1, 0, 1, 1);

            tap_button = new Gtk.Button.with_label (_("Tap"));
            tap_button.get_style_context ().add_class ("quick-mod-button");
            tempo_grid.attach (tap_button, 0, 1, 2, 1);


            var tempo_icon = new Gtk.Image.from_resource ("/com/github/subhadeepjasu/ensembles/images/tempo_icon.svg");
            tempo_icon.vexpand = true;
            tempo_grid.attach (tempo_icon, 0, 2, 2, 1);


            attach (tempo_grid, 0, 1, 2, 1);

            show_all ();

            tempo_spin_button.changed.connect (tempo_changed);

            wheel_scrolled_absolute.connect ((value) => {
                Idle.add (() => {
                    tempo_spin_button.set_value (value);
                    return false;
                });
            });
        }

        public void set_tempo (int tempo) {
            tempo_spin_button.changed.disconnect (tempo_changed);
            tempo_spin_button.set_value ((double) tempo);
            scroll_wheel_location = tempo;
            tempo_spin_button.changed.connect (tempo_changed);
        }

        private void tempo_changed () {
            changed (tempo_spin_button.get_value_as_int ());
        }

        public void scroll_wheel_activate () {
            close_screen ();
        }
    }
}
