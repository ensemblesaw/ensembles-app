/*-
 * Copyright (c) 2021-2022 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License 
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
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

        public signal void analysis_complete ();
        public StyleDiscovery () {
            in_built_style_path = Constants.PKGDATADIR + "/StyleFiles";
            user_style_path = Environment.get_home_dir () + "/Documents/Ensembles/StyleFiles";
            style_files = new List<string> ();
            style_names = new List<string> ();
            style_genre = new List<string> ();
            style_tempo = new List<int> ();
            styles = new List<Style> ();

            if (DirUtils.create_with_parents (Environment.get_home_dir () + "/Documents/Ensembles", 2000) != -1) {
                if (DirUtils.create_with_parents (
                    Environment.get_home_dir () + "/Documents/Ensembles/StyleFiles", 2000) != -1) {
                    debug ("Made user style_folder\n");
                }
            }
            find_styles ();
            analyser = new Ensembles.Core.StyleAnalyser ();
            run_analysis ();
        }

        public void find_styles () {
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
                styles.nth_data (i).tempo = tempo;
                styles.nth_data (i).timesignature_n = analyser.time_sig_n;
                styles.nth_data (i).timesignature_d = analyser.time_sig_d;
            }
            Timeout.add (1000, () => {
                analysis_complete ();
                return false;
            });
        }

        private CompareFunc<Style> stylecmp = (a, b) => {
            return (a.genre).ascii_casecmp (b.genre);
        };
    }
}
