using Ensembles.Models;

namespace Ensembles.Core.FileLoaders {
    public class StyleFileLoader : Object {
        public Style[] styles;

        private List<Style?> style_list;

        private string stock_style_path;
        private string user_style_path;

        public StyleFileLoader () {
            stock_style_path = Constants.PKGDATADIR + "/StyleFiles";
            user_style_path = Environment.get_user_special_dir (GLib.UserDirectory.DOCUMENTS) +
            "/ensembles" + "/styles";

            style_list = new List<Style?> ();

            try {
                Dir dir = Dir.open (stock_style_path, 0);
                string? name = null;
                while ((name = dir.read_name ()) != null) {
                    string path = Path.build_filename (stock_style_path, name);
                    if (path.has_suffix (".enstl") && path.contains ("@")) {
                        try {
                            var analyser = new Analysers.StyleAnalyser (path);
                            style_list.append (analyser.get_style ());
                        } catch (StyleError e) {
                            Console.log (e, Console.LogLevel.WARNING);
                        } catch (Error e) {
                            Console.log ("Style file not found or invalid!", Console.LogLevel.WARNING);
                        }
                    }
                }
            } catch (FileError e) {
                Console.log ("Stock style directory not found", Console.LogLevel.WARNING);
            }

            try {
                Dir dir = Dir.open (user_style_path, 0);
                string? name = null;
                while ((name = dir.read_name ()) != null) {
                    string path = Path.build_filename (user_style_path, name);
                    if (path.has_suffix (".enstl") && path.contains ("@")) {
                        try {
                            var analyser = new Analysers.StyleAnalyser (path);
                            style_list.append (analyser.get_style ());
                        } catch (StyleError e) {
                            Console.log (e, Console.LogLevel.WARNING);
                        } catch (Error e) {
                            Console.log ("Style file not found or invalid!", Console.LogLevel.WARNING);
                        }
                    }
                }
            } catch (FileError e) {
                Console.log ("User style directory not found", Console.LogLevel.TRACE);
            }

            style_list.sort (stylecmp);
        }

        /**
         * Get an array of style objects which can be passed into
         * style engines to play them
         */
        public Style[] get_styles (out uint len) {
            len = style_list.length ();
            var styles = new Style[len];
            uint i = 0;

            foreach (var style in style_list) {
                styles[i++] = (owned)style;
            }

            return styles;
        }

        private CompareFunc<Style?> stylecmp = (a, b) => {
            return (a.genre).ascii_casecmp (b.genre);
        };
    }
}
