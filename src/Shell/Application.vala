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
 * Authored by: Subhadeep Jasu
 */

namespace Ensembles.Shell { 
    public class EnsemblesApp : Gtk.Application {
        static EnsemblesApp _instance = null;

        public static EnsemblesApp instance {
            get {
                if (_instance == null) {
                    _instance = new EnsemblesApp ();
                }
                return _instance;
            }
        }
        
        string version_string = "";

        Ensembles.Shell.MainWindow main_window;

        Gtk.CssProvider css_provider;


        public EnsemblesApp () {
            Object (
                application_id: "com.github.subhadeepjasu.ensembles"
            );
            version_string = "1.0.0";
        }

        protected override void activate () {
            if (this.main_window == null) {
                this.main_window = new Ensembles.Shell.MainWindow ();
                this.add_window (main_window);
            }
            if (css_provider == null) {
                css_provider = new Gtk.CssProvider();
                css_provider.load_from_resource ("/com/github/subhadeepjasu/ensembles/Application.css");
                // CSS Provider
                Gtk.StyleContext.add_provider_for_screen (
                    Gdk.Screen.get_default(),
                    css_provider,
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                );
            }
            this.main_window.show_all ();
        }
    }
}