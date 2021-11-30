namespace Ensembles {
    public class Utils {
        static string display_theme_path = "";
        public static string set_display_theme (string name) {
            display_theme_path = Environment.get_home_dir () + "/Documents/Ensembles/DisplayThemes/";
            print (display_theme_path);
            // Update  the stylesheets first
            if (DirUtils.create_with_parents (Environment.get_home_dir () + "/Documents/Ensembles", 2000) != -1) {
                if (DirUtils.create_with_parents (display_theme_path, 2000) != -1) {
                    create_file ("DisplayUnit", "Default", "css");
                    create_file ("DisplayUnitElementaryLight", "Elementary Light", "css");
                    create_file ("DisplayUnitElementaryDark", "Elementary Dark", "css");
                }
            }
            // Attempt to set the given theme
            var display_theme_provider = new Gtk.CssProvider ();
            try {
                display_theme_provider.load_from_path (display_theme_path + name);
                Gtk.StyleContext.add_provider_for_screen (
                    Gdk.Screen.get_default (), display_theme_provider,
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                );
            } catch (Error e) {
                try {
                    display_theme_provider.load_from_path (display_theme_path + "Default.css");
                    Gtk.StyleContext.add_provider_for_screen (
                        Gdk.Screen.get_default (), display_theme_provider,
                        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                    );
                    return "Default.css";
                } catch (Error e1) {
                    try {
                        display_theme_provider.load_from_path (display_theme_path + "Elementary Light.css");
                        Gtk.StyleContext.add_provider_for_screen (
                            Gdk.Screen.get_default (), display_theme_provider,
                            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                        );
                        return "Elementary Light.css";
                    } catch (Error e2) {
                        try {
                            display_theme_provider.load_from_path (display_theme_path + "Elementary Dark.css");
                            Gtk.StyleContext.add_provider_for_screen (
                                Gdk.Screen.get_default (), display_theme_provider,
                                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                            );
                            return "Elementary Dark.css";
                        } catch (Error e3) {
                            warning ("Failed to load any of the default Display Themes: %s", e3.message);
                        }
                    }
                }
            }
            return name;
        }

        public static string[] get_theme_list () {
            string[] themes = new string [0];
            try {
                Dir dir = Dir.open (display_theme_path);
                string? name = null;
                while ((name = dir.read_name ()) != null) {
                    if (name.contains (".css")) {
                        print (name + "\n");
                        themes.resize (themes.length + 1);
                        themes[themes.length - 1] = name;
                    }
                }
            } catch (Error e) {
                warning ("Failed to load display themes: " + e.message);
            }
            return themes;
        }

        private static bool create_file (string source_name, string dest_name, string extension) {
            File tf_source_elementary_light = File.new_for_path (Constants.PKGDATADIR + "/themes/%s.%s".printf(source_name, extension));
            File tf_dest_elementary_light = File.new_for_path (display_theme_path + "%s.%s".printf (dest_name, extension));
            try {
                if (tf_source_elementary_light.query_exists () &&
                    (!tf_dest_elementary_light.query_exists () ||
                    (tf_source_elementary_light.query_info("*", FileQueryInfoFlags.NONE).get_modification_date_time ().to_unix () >
                    tf_dest_elementary_light.query_info("*", FileQueryInfoFlags.NONE).get_modification_date_time ().to_unix ()))) {
                    print ("Installing newer stylesheet: %s.%s\n", dest_name, extension);
                    tf_source_elementary_light.copy (tf_dest_elementary_light, GLib.FileCopyFlags.OVERWRITE);
                }
            } catch (Error e) {
                warning (e.message);
                return false;
            }
            return true;
        }
    }
}
