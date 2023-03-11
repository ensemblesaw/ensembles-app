/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Services {
    public class Theme {
        static Gtk.CssProvider main_css_provider;
        static Gtk.CssProvider complimentary_css_provider;

        public static string theme_color = "blueberry";

        public static void init_theme () {
            //  weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
            //  default_theme.add_resource_path ("/com/github/subhadeepjasu/ensembles");

            GLib.Value theme_value = GLib.Value (GLib.Type.STRING);
            Gtk.Settings.get_default ().get_property ("gtk-theme-name", ref theme_value);

            var system_theme = theme_value.get_string ();

            if (system_theme.has_prefix ("io.elementary.")) {
                theme_color = theme_value.get_string ().replace ("io.elementary.stylesheet.", "");
            } else {
                Gtk.Settings.get_default ().set_property ("gtk-icon-theme-name", "elementary");
            }

            if (main_css_provider == null) {
                main_css_provider = new Gtk.CssProvider ();
                main_css_provider.load_from_resource ("/com/github/subhadeepjasu/ensembles/Application.css");
                Gtk.StyleContext.add_provider_for_display (
                    Gdk.Display.get_default (),
                    main_css_provider,
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                );
            }

            // Set colors that are complimentary to the accent color for special cases
            if (complimentary_css_provider == null) {
                complimentary_css_provider = new Gtk.CssProvider ();
                complimentary_css_provider.load_from_data (AccentColors.get_complementary (theme_color));

                Gtk.StyleContext.add_provider_for_display (
                    Gdk.Display.get_default (),
                    complimentary_css_provider,
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                );
            }
        }
    }
}
