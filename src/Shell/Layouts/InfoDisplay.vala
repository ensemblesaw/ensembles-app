/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Shell.Layouts.DisplayScreens;

namespace Ensembles.Shell.Layouts {
    public class InfoDisplay : Gtk.Box {
        private Gtk.Overlay main_overlay;
        private Gtk.Box splash_screen;
        private Gtk.Label splash_screen_label;
        private Gtk.Stack main_stack;

        // Screens
        private HomeScreen home_screen;

        construct {
            build_ui ();
            build_events ();
        }

        public InfoDisplay () {
            Object (
                hexpand: true,
                vexpand: true,
                width_request: 480,
                height_request: 360
            );
        }

        private void build_ui () {
            get_style_context ().add_class ("panel");

            main_overlay = new Gtk.Overlay () {
                hexpand = true,
                vexpand = true
            };
            main_overlay.get_style_context ().add_class ("display");
            append (main_overlay);

            splash_screen = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            splash_screen.get_style_context ().add_class ("splash-screen-background");
            main_overlay.add_overlay (splash_screen);

            var splash_banner = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true,
                vexpand = true
            };
            splash_banner.get_style_context ().add_class ("ensembles-logo-splash");
            splash_screen.append (splash_banner);

            splash_screen_label = new Gtk.Label (_("Initializing…")) {
                xalign = 0,
                margin_start = 8,
                margin_bottom = 8,
                margin_end = 8,
                margin_top = 8,
                opacity = 0.5
            };
            splash_screen_label.get_style_context ().add_class ("splash-screen-label");
            splash_screen.append (splash_screen_label);

            main_stack = new Gtk.Stack ();
            main_stack.get_style_context ().add_class ("display-stack");
            main_stack.get_style_context ().add_class ("fade-black");
            main_overlay.set_child (main_stack);

            home_screen = new HomeScreen ();
            main_stack.add_named (home_screen, "home");

        }

        private void build_events () {
            Application.event_bus.arranger_ready.connect (() => {
                main_overlay.remove_overlay (splash_screen);
                if (splash_screen != null) {
                    splash_screen.unref ();
                }

                Timeout.add (200, () => {
                    main_stack.get_style_context ().remove_class ("fade-black");
                    return false;
                });
            });
        }
    }
}
