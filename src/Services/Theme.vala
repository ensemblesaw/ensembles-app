/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Services {
    public class Theme {
        static Gtk.CssProvider main_css_provider;
        static Gtk.CssProvider complimentary_css_provider;

        public static string theme_color = "blueberry";

        private const string COMPLIMENTARY_ACCENT_COLORS =
        "
        @define-color accent_color_complimentary %s;
        @define-color accent_color_complimentary_alternate %s;
        ";

        private static string COMPLIMENTARY_ACCENT_COLORS_STRAWBERRY;
        private static string COMPLIMENTARY_ACCENT_COLORS_ORANGE;
        private static string COMPLIMENTARY_ACCENT_COLORS_BANANA;
        private static string COMPLIMENTARY_ACCENT_COLORS_LIME;
        private static string COMPLIMENTARY_ACCENT_COLORS_MINT;
        private static string COMPLIMENTARY_ACCENT_COLORS_BLUEBERRY;
        private static string COMPLIMENTARY_ACCENT_COLORS_BUBBLEGUM;
        private static string COMPLIMENTARY_ACCENT_COLORS_COCOA;
        private static string COMPLIMENTARY_ACCENT_COLORS_GRAPE;
        private static string COMPLIMENTARY_ACCENT_COLORS_SILVER;
        private static string COMPLIMENTARY_ACCENT_COLORS_SLATE;

        private static void init_accent_colors () {
            COMPLIMENTARY_ACCENT_COLORS_STRAWBERRY =
            COMPLIMENTARY_ACCENT_COLORS.printf ("@BANANA_500", "@ORANGE_500");

            COMPLIMENTARY_ACCENT_COLORS_ORANGE =
            COMPLIMENTARY_ACCENT_COLORS.printf ("@BLUEBERRY_500", "@MINT_500");

            COMPLIMENTARY_ACCENT_COLORS_BANANA =
            COMPLIMENTARY_ACCENT_COLORS.printf ("@MINT_500", "@ORANGE_500");

            COMPLIMENTARY_ACCENT_COLORS_LIME =
            COMPLIMENTARY_ACCENT_COLORS.printf ("@BANANA_500", "@BUBBLEGUM_500");

            COMPLIMENTARY_ACCENT_COLORS_MINT =
            COMPLIMENTARY_ACCENT_COLORS.printf ("@BANANA_500", "@SILVER_500");

            COMPLIMENTARY_ACCENT_COLORS_BLUEBERRY =
            COMPLIMENTARY_ACCENT_COLORS.printf ("@BANANA_500", "@MINT_500");

            COMPLIMENTARY_ACCENT_COLORS_BUBBLEGUM =
            COMPLIMENTARY_ACCENT_COLORS.printf ("@MINT_500", "@GRAPE_500");

            COMPLIMENTARY_ACCENT_COLORS_COCOA =
            COMPLIMENTARY_ACCENT_COLORS.printf ("@BANANA_500", "@MINT_500");

            COMPLIMENTARY_ACCENT_COLORS_GRAPE =
            COMPLIMENTARY_ACCENT_COLORS.printf ("@BANANA_500", "@BUBBLEGUM_500");

            COMPLIMENTARY_ACCENT_COLORS_SILVER =
            COMPLIMENTARY_ACCENT_COLORS.printf ("@BLUEBERRY_300", "@STRAWBERRY_300");

            COMPLIMENTARY_ACCENT_COLORS_SLATE =
            COMPLIMENTARY_ACCENT_COLORS.printf ("@MINT_500", "@BANANA_500");
        }
        public static void init_theme () {
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
                init_accent_colors ();
                complimentary_css_provider = new Gtk.CssProvider ();
                switch (theme_color) {
                    case "strawberry":
                        complimentary_css_provider.load_from_data (COMPLIMENTARY_ACCENT_COLORS_STRAWBERRY.data);
                        break;
                    case "orange":
                        complimentary_css_provider.load_from_data (COMPLIMENTARY_ACCENT_COLORS_ORANGE.data);
                        break;
                    case "banana":
                        complimentary_css_provider.load_from_data (COMPLIMENTARY_ACCENT_COLORS_BANANA.data);
                        break;
                    case "lime":
                        complimentary_css_provider.load_from_data (COMPLIMENTARY_ACCENT_COLORS_LIME.data);
                        break;
                    case "mint":
                        complimentary_css_provider.load_from_data (COMPLIMENTARY_ACCENT_COLORS_MINT.data);
                        break;
                    case "blueberry":
                        complimentary_css_provider.load_from_data (COMPLIMENTARY_ACCENT_COLORS_BLUEBERRY.data);
                        break;
                    case "grape":
                        complimentary_css_provider.load_from_data (COMPLIMENTARY_ACCENT_COLORS_GRAPE.data);
                        break;
                    case "bubblegum":
                        complimentary_css_provider.load_from_data (COMPLIMENTARY_ACCENT_COLORS_BUBBLEGUM.data);
                        break;
                    case "cocoa":
                        complimentary_css_provider.load_from_data (COMPLIMENTARY_ACCENT_COLORS_COCOA.data);
                        break;
                    case "silver":
                        complimentary_css_provider.load_from_data (COMPLIMENTARY_ACCENT_COLORS_SILVER.data);
                        break;
                    case "slate":
                    case "black":
                        complimentary_css_provider.load_from_data (COMPLIMENTARY_ACCENT_COLORS_SLATE.data);
                        break;
                }

                Gtk.StyleContext.add_provider_for_display (
                    Gdk.Display.get_default (),
                    complimentary_css_provider,
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                );
            }
        }
    }
}
