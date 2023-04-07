/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles {
    //  public class Utils {
        //  static string display_theme_path = "";
        //  static Gtk.CssProvider display_theme_provider;
        //  public static string set_display_theme (string name) {
        //      display_theme_path = Application.user_config_dir + "/display_themes/";
        //      // Update  the stylesheets first
        //      if (DirUtils.create_with_parents (Application.user_config_dir, 2000) != -1) {
        //          if (DirUtils.create_with_parents (display_theme_path, 2000) != -1) {
        //              create_file ("DisplayUnit", "Default", "css");
        //              create_file ("DisplayUnitElementaryLight", "elementary Light", "css");
        //              create_file ("DisplayUnitElementaryDark", "elementary Dark", "css");
        //              create_file ("DisplayUnitAurora", "Aurora", "css");
        //          }
        //      }
        //      // Attempt to set the given theme
        //      if (display_theme_provider == null) {
        //          display_theme_provider = new Gtk.CssProvider ();
        //      } else {
        //          Gtk.StyleContext.remove_provider_for_display (Gdk.Display.get_default (), display_theme_provider);
        //      }
        //      try {
        //          display_theme_provider.load_from_path (display_theme_path + name + ".css");
        //          Gtk.StyleContext.add_provider_for_display (
        //              Gdk.Display.get_default (), display_theme_provider,
        //              Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        //          );
        //      } catch (Error e) {
        //          warning (e.message);
        //          try {
        //              display_theme_provider.load_from_path (display_theme_path + "Default.css");
        //              Gtk.StyleContext.add_provider_for_display (
        //                  Gdk.Display.get_default (), display_theme_provider,
        //                  Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        //              );
        //              return "Default";
        //          } catch (Error e1) {
        //              warning (e1.message);
        //              try {
        //                  display_theme_provider.load_from_path (display_theme_path + "Elementary Light.css");
        //                  Gtk.StyleContext.add_provider_for_display (
        //                      Gdk.Display.get_default (), display_theme_provider,
        //                      Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        //                  );
        //                  return "Elementary Light";
        //              } catch (Error e2) {
        //                  warning (e2.message);
        //                  try {
        //                      display_theme_provider.load_from_path (display_theme_path + "Elementary Dark.css");
        //                      Gtk.StyleContext.add_provider_for_display (
        //                          Gdk.Display.get_default (), display_theme_provider,
        //                          Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        //                      );
        //                      return "Elementary Dark";
        //                  } catch (Error e3) {
        //                      warning (e3.message);
        //                      try {
        //                          display_theme_provider.load_from_path (display_theme_path + "Aurora.css");
        //                          Gtk.StyleContext.add_provider_for_display (
        //                              Gdk.Display.get_default (), display_theme_provider,
        //                              Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        //                          );
        //                          return "Aurora";
        //                      } catch (Error e4) {
        //                          warning ("Failed to load any of the default Display Themes: %s", e4.message);
        //                      }
        //                  }
        //              }
        //          }
        //      }
        //      return name;
        //  }
    //  }
}
