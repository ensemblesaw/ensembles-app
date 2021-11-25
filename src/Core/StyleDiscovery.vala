/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


namespace Ensembles.Core {
    public class StyleDiscovery {
        string in_built_style_path;
        string user_style_path;
        public List<string> style_files;
        public List<string> style_names;
        public List<string> style_genre;
        public List<int> style_tempo;
        public List<Style> styles;
        Ensembles.Core.StyleAnalyser analyser;

        public StyleDiscovery () {
            in_built_style_path = Constants.PKGDATADIR + "/StyleFiles";
            user_style_path = Environment.get_home_dir () + "/Documents/Ensembles/StyleFiles";
            style_files = new List<string> ();
            style_names = new List<string> ();
            style_genre = new List<string> ();
            style_tempo = new List<int> ();
            styles = new List<Style> ();
        }

        public void load_styles () {
            if (DirUtils.create_with_parents (Environment.get_home_dir () + "/Documents/Ensembles", 2000) != -1) {
                if (DirUtils.create_with_parents (
                    Environment.get_home_dir () + "/Documents/Ensembles/StyleFiles", 2000) != -1) {
                    debug ("Made user style folder\n");
                }
            }
            find_styles ();
            analyser = new Ensembles.Core.StyleAnalyser ();
            run_analysis ();
        }

        void find_styles () {
            try {
                Dir dir = Dir.open (in_built_style_path, 0);
                string? name = null;
                while ((name = dir.read_name ()) != null) {
                    string path = Path.build_filename (in_built_style_path, name);
                    if (path.contains (".enstl")) {
                        string temp_path = path;
                        path = path.replace (in_built_style_path + "/", "");
                        path = path.replace (".enstl", "");
                        var temp = path.split ("@");
                        style_names.append (temp[1].replace ("_", " "));
                        style_genre.append (temp[0].replace ("_", " "));
                        styles.append (new Style (
                            temp_path,
                            temp[1].replace ("_", " "),
                            temp[0].replace ("_", " "),
                            30,
                            4,
                            4
                        ));
                    }
                }
                dir = Dir.open (user_style_path, 0);
                name = null;
                while ((name = dir.read_name ()) != null) {
                    string path = Path.build_filename (user_style_path, name);
                    if (path.contains (".enstl")) {
                        string temp_path = path;
                        path = path.replace (user_style_path + "/", "");
                        path = path.replace (".enstl", "");
                        var temp = path.split ("@");
                        style_names.append (temp[1].replace ("_", " "));
                        style_genre.append (temp[0].replace ("_", " "));
                        styles.append (new Style (
                            temp_path,
                            temp[1].replace ("_", " "),
                            temp[0].replace ("_", " "),
                            30,
                            4,
                            4
                        ));
                    }
                }
                styles.sort (stylecmp);
            } catch (FileError e) {
                warning (e.message);
            }
        }

        public void run_analysis () {
            for (int i = 0; i < styles.length (); i++) {
                int tempo = analyser.analyze_style (styles.nth_data (i).path);
                Thread.usleep (10000);
                styles.nth_data (i).tempo = tempo;
                styles.nth_data (i).timesignature_n = analyser.time_sig_n;
                styles.nth_data (i).timesignature_d = analyser.time_sig_d;
                Thread.usleep (10000);
                if (Application.main_window != null) {
                    Application.main_window.main_display_unit.update_splash_text (_("Loading Styles: ") + styles.nth_data (i).name);
                }
            }
        }

        private CompareFunc<Style> stylecmp = (a, b) => {
            return (a.genre).ascii_casecmp (b.genre);
        };
    }
}
