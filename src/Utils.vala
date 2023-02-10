/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles {
    public class Utils {
        static string display_theme_path = "";
        static Gtk.CssProvider display_theme_provider;
        public static string set_display_theme (string name) {
            display_theme_path = Application.user_config_dir + "/display_themes/";
            // Update  the stylesheets first
            if (DirUtils.create_with_parents (Application.user_config_dir, 2000) != -1) {
                if (DirUtils.create_with_parents (display_theme_path, 2000) != -1) {
                    create_file ("DisplayUnit", "Default", "css");
                    create_file ("DisplayUnitElementaryLight", "elementary Light", "css");
                    create_file ("DisplayUnitElementaryDark", "elementary Dark", "css");
                    create_file ("DisplayUnitAurora", "Aurora", "css");
                }
            }
            // Attempt to set the given theme
            if (display_theme_provider == null) {
                display_theme_provider = new Gtk.CssProvider ();
            } else {
                Gtk.StyleContext.remove_provider_for_display (Gdk.Display.get_default (), display_theme_provider);
            }
            try {
                display_theme_provider.load_from_path (display_theme_path + name + ".css");
                Gtk.StyleContext.add_provider_for_display (
                    Gdk.Display.get_default (), display_theme_provider,
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                );
            } catch (Error e) {
                warning (e.message);
                try {
                    display_theme_provider.load_from_path (display_theme_path + "Default.css");
                    Gtk.StyleContext.add_provider_for_display (
                        Gdk.Display.get_default (), display_theme_provider,
                        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                    );
                    return "Default";
                } catch (Error e1) {
                    warning (e1.message);
                    try {
                        display_theme_provider.load_from_path (display_theme_path + "Elementary Light.css");
                        Gtk.StyleContext.add_provider_for_display (
                            Gdk.Display.get_default (), display_theme_provider,
                            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                        );
                        return "Elementary Light";
                    } catch (Error e2) {
                        warning (e2.message);
                        try {
                            display_theme_provider.load_from_path (display_theme_path + "Elementary Dark.css");
                            Gtk.StyleContext.add_provider_for_display (
                                Gdk.Display.get_default (), display_theme_provider,
                                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                            );
                            return "Elementary Dark";
                        } catch (Error e3) {
                            warning (e3.message);
                            try {
                                display_theme_provider.load_from_path (display_theme_path + "Aurora.css");
                                Gtk.StyleContext.add_provider_for_display (
                                    Gdk.Display.get_default (), display_theme_provider,
                                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                                );
                                return "Aurora";
                            } catch (Error e4) {
                                warning ("Failed to load any of the default Display Themes: %s", e4.message);
                            }
                        }
                    }
                }
            }
            return name;
        }

        public async static string[] get_theme_list () {
            string[] themes = new string [0];
            var thread = new Thread<void> ("get_theme_list", () => {
                try {
                    Dir dir = Dir.open (display_theme_path);
                    string? name = null;
                    while ((name = dir.read_name ()) != null) {
                        if (name.contains (".css")) {
                            themes.resize (themes.length + 1);
                            themes[themes.length - 1] = name.replace (".css", "");
                        }
                    }
                } catch (Error e) {
                    warning ("Failed to load display themes: " + e.message);
                }
            });
            thread.join ();
            return themes;
        }

        private static bool create_file (string source_name, string dest_name, string extension) {
            File tf_source_elementary_light = File.new_for_path (
                Constants.PKGDATADIR + "/themes/%s.%s".printf (source_name, extension)
            );

            File tf_dest_elementary_light = File.new_for_path (
                display_theme_path + "%s.%s".printf (dest_name, extension)
            );

            try {
                if (tf_source_elementary_light.query_exists () &&
                    (!tf_dest_elementary_light.query_exists () ||
                    (tf_source_elementary_light.query_info ("*",
                    FileQueryInfoFlags.NONE).get_modification_date_time ().to_unix () >
                    tf_dest_elementary_light.query_info ("*",
                    FileQueryInfoFlags.NONE).get_modification_date_time ().to_unix ()))) {
                    print ("Installing newer stylesheet: %s.%s\n", dest_name, extension);
                    tf_source_elementary_light.copy (tf_dest_elementary_light, GLib.FileCopyFlags.OVERWRITE);
                }
            } catch (Error e) {
                warning (e.message);
                return false;
            }
            return true;
        }

        public static void read_csv (GLib.File csv_file, out string[,] csv_data) {
            try {
                var @is = csv_file.read ();
                var dis = new DataInputStream (@is);

                var lines = new List<string> ();

                var line = "";
                while ((line = dis.read_line ()) != null) {
                    lines.append (line);
                }

                var n = lines.length ();



                if (n > 0) {
                    csv_data = new string[n, lines.nth_data (0).split ("\t").length];
                    for (uint i = 0; i < n; i++) {
                        var tokens = lines.nth_data (i).split ("\t");
                        for (uint j = 0; j < tokens.length; j++) {
                            csv_data[i, j] = tokens[j];
                        }
                    }
                } else {
                    csv_data = null;
                }

            } catch (Error e) {
                print (e.message);
                csv_data = null;
            }
        }

        public static void save_csv (GLib.File csv_file, string[,] csv_data) {
            int m = csv_data.length[0], n = csv_data.length[1];

            try {
                var os = csv_file.create (GLib.FileCreateFlags.PRIVATE);
                for (int i = 0; i < m; i++) {
                    string[] tokens = {};
                    for (int j = 0; j < n; j++) {
                        tokens += csv_data[i, j];
                    }
                    var line = string.joinv ("\t", tokens) + "\n";
                    os.write (line.data);
                }
                os.close ();
            } catch (Error e) {
                print (e.message);
            }

        }
    }
}
