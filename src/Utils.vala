namespace Ensembles {
    public class Utils {
        static string display_theme_path = "";
        public static string set_display_theme (string name) {
            display_theme_path = Environment.get_home_dir () + "/Documents/Ensembles/DisplayThemes/";
            print (display_theme_path);
            var display_theme_provider = new Gtk.CssProvider ();
            try {
                display_theme_provider.load_from_path (display_theme_path + name);
                Gtk.StyleContext.add_provider_for_screen (
                    Gdk.Screen.get_default (), display_theme_provider,
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                );
            } catch (Error e) {
                warning ("Failed to apply display theme: " + e.message);
                if (DirUtils.create_with_parents (Environment.get_home_dir () + "/Documents/Ensembles", 2000) != -1) {
                    if (DirUtils.create_with_parents (display_theme_path, 2000) != -1) {
                        debug ("Made user display theme folder\n");
                        File tf_source = File.new_for_path (Constants.PKGDATADIR + "/themes/DisplayUnit.css");
                        File tf_dest = File.new_for_path (display_theme_path + "Default.css");
                        if (tf_source.query_exists () && !tf_dest.query_exists ()) {
                            try {
                                tf_source.copy (tf_dest, GLib.FileCopyFlags.OVERWRITE);
                                display_theme_provider.load_from_path (display_theme_path + "Default.css");
                                Gtk.StyleContext.add_provider_for_screen (
                                    Gdk.Screen.get_default (), display_theme_provider,
                                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                                );
                            } catch (Error e) {
                                warning (e.message);
                            }
                        }
                    }
                }
                return "Default.css";
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
    }
}
