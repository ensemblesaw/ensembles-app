/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Services {
    public class Theme {
        static Gtk.CssProvider main_css_provider;
        static Gtk.CssProvider complimentary_css_provider;

        public static string theme_color = "blueberry";

        public static void init_theme () {
            weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
            default_theme.add_resource_path ("/com/github/subhadeepjasu/ensembles/icons");

            GLib.Value theme_value = GLib.Value (GLib.Type.STRING);

            var gtk_settings = Gtk.Settings.get_default ();
            var granite_settings = Granite.Settings.get_default ();

            gtk_settings.get_property ("gtk-theme-name", ref theme_value);

            var system_theme = theme_value.get_string ();

            if (system_theme.has_prefix ("io.elementary.")) {
                theme_color = theme_value.get_string ().replace ("io.elementary.stylesheet.", "");
            } else {
                gtk_settings.set_property ("gtk-icon-theme-name", "elementary");
            }

            if (main_css_provider == null) {
                main_css_provider = new Gtk.CssProvider ();
                main_css_provider.load_from_resource ("/com/github/subhadeepjasu/ensembles/theme/Application.css");
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

            gtk_settings.gtk_application_prefer_dark_theme = (
                granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
            );

            granite_settings.notify["prefers-color-scheme"].connect (() => {
                gtk_settings.gtk_application_prefer_dark_theme = (
                    granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
                );
            });
        }
    }
}
