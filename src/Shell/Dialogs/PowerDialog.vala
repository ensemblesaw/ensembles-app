/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Dialog {
    public class PowerDialog : Gtk.Window {
        private Gtk.Image power_icon;
        private Gtk.Label header;
        private Gtk.Label message;
        private Gtk.Button log_out_button;
        private Gtk.Button cancel_button;
        private Gtk.Button shutdown_button;

        construct {
            build_ui ();
            build_events ();
        }

        public PowerDialog (Gtk.Window main_window) {
            Object (
                modal: true,
                transient_for: main_window,
                decorated: false
            );
        }

        private void build_ui () {
            add_css_class ("pseudowindow-actual");

            var main_grid = new Gtk.Grid () {
                row_spacing = 8,
                column_spacing = 8,
                halign = Gtk.Align.CENTER,
                valign = Gtk.Align.CENTER
            };
            main_grid.add_css_class ("pseudowindow");
            main_grid.add_css_class ("opaque");

            set_child (main_grid);

            power_icon = new Gtk.Image.from_icon_name ("system-shutdown") {
                width_request = 48,
                height_request = 48,
                icon_size = Gtk.IconSize.LARGE
            };
            main_grid.attach (power_icon, 0, 0, 1, 2);

            header = new Gtk.Label (_("Are you sure you want to Shut Down?")) {
                halign = Gtk.Align.START
            };
            header.add_css_class (Granite.STYLE_CLASS_H3_LABEL);
            main_grid.attach (header, 1, 0, 4);

            message = new Gtk.Label (_("This will turn off this device")) {
                halign = Gtk.Align.START
            };
            main_grid.attach (message, 1, 1, 4);

            log_out_button = new Gtk.Button.with_label (_("Log Out Instead…"));
            main_grid.attach (log_out_button, 1, 2, 2);

            cancel_button = new Gtk.Button.with_label (_("Cancel"));
            main_grid.attach (cancel_button, 3, 2);

            shutdown_button = new Gtk.Button.with_label (_("Shut Down"));
            shutdown_button.add_css_class (Granite.STYLE_CLASS_DESTRUCTIVE_ACTION);
            main_grid.attach (shutdown_button, 4, 2);
        }

        private void build_events () {
            cancel_button.clicked.connect (() => {
                this.close ();
            });

            log_out_button.clicked.connect (() => {
                Application.main_window.close ();
            });

            shutdown_button.clicked.connect (() => {
                Application.main_window.close ();
            });

            ((Gtk.Widget) this).realize.connect (() => {
                var display = Gdk.Display.get_default ();
                var monitor = display.get_monitor_at_surface (get_surface ());
                set_default_size (monitor.geometry.width, monitor.geometry.height);
            });
        }
    }
}
