namespace Ensembles.Core { 
    public class StyleDiscovery {
        string in_built_style_path;
        string user_style_path;
        public List<string> style_files;
        public List<string> style_names;
        public List<string> style_genre;
        public List<int> style_tempo;
        Ensembles.Core.StyleAnalyser analyser;

        public signal void analysis_complete ();
        public StyleDiscovery() {
            in_built_style_path = Constants.PKGDATADIR + "/Styles";
            user_style_path = Environment.get_home_dir () + "/Documents/Ensembles/Styles";
            style_files = new List<string> ();
            style_names = new List<string> ();
            style_genre = new List<string> ();
            style_tempo = new List<int> ();

            if (DirUtils.create_with_parents (Environment.get_home_dir () + "/Documents/Ensembles", 2000) != -1) {
                if (DirUtils.create_with_parents (Environment.get_home_dir () + "/Documents/Ensembles/Styles", 2000) != -1) {
                    print ("Made user style_folder\n");
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
                        style_files.append (path);
                        path = path.replace (in_built_style_path + "/", "");
                        path = path.replace (".enstl", "");
                        var temp = path.split ("@");
                        style_names.append (temp[1].replace ("_", " "));
                        style_genre.append (temp[0].replace ("_", " "));
                    }
                }
                dir = Dir.open (user_style_path, 0);
                name = null;
                while ((name = dir.read_name ()) != null) {
                    string path = Path.build_filename (user_style_path, name);
                    if (path.contains (".enstl")) {
                        style_files.append (path);
                        path = path.replace (user_style_path + "/", "");
                        path = path.replace (".enstl", "");
                        var temp = path.split ("@");
                        style_names.append (temp[1].replace ("_", " "));
                        style_genre.append (temp[0].replace ("_", " "));
                    }
                }
            } catch (FileError e) {
                warning (e.message);
            }
        }

        public void run_analysis () {
            for (int i = 0; i < style_files.length (); i++) {
                int tempo = analyser.analyze_style (style_files.nth_data (i));
                style_tempo.append (tempo);
            }
            Timeout.add (1000, () => {
                analysis_complete ();
                return false;
            });
            
        }
    }
}