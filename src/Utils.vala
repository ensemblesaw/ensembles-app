namespace Ensembles {
    public class Utils {
        static string DISPLAY_THEME_PATH = Path.build_path ("/", Environment.get_home_dir (), "Documents", "Ensembles", "DisplayThemes");
        public static string set_display_theme (string name) {
            var display_theme_provider = new Gtk.CssProvider ();
            try {
                display_theme_provider.load_from_path (Environment.get_home_dir () + "Documents/Ensembles/DisplayThemes/" + name);
                Gtk.StyleContext.add_provider_for_screen (
                    Gdk.Screen.get_default (), display_theme_provider,
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                );
            } catch (Error e) {
                warning ("Failed to apply display theme: " + e.message);
                if (DirUtils.create_with_parents (Environment.get_home_dir () + "/Documents/Ensembles", 2000) != -1) {
                    if (DirUtils.create_with_parents (DISPLAY_THEME_PATH, 2000) != -1) {
                        debug ("Made user display theme folder\n");
                    }
                }
                return "Default.css";
            }
            return name;
        }

        public static string[] get_theme_list () {
            string[] themes = new string [0];
            try {
                Dir dir = Dir.open (DISPLAY_THEME_PATH);
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
