/*-
 * Copyright (c) 2018-2019 Subhadeep Jasu <subhajasu@gmail.com>
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
    public class MainWindow : Gtk.Window {
        Gtk.Button button;
        Ensembles.Core.EffectRack fx_rack;
        Ensembles.Core.RealTimePlay play;

        string sf_loc = Constants.PKGDATADIR + "/SoundFonts/Synthia_Revamped_GM.sf2";
        public MainWindow () {
            button = new Gtk.Button.with_label ("C");
            this.add (button);
            this.show_all ();
            fx_rack = new Ensembles.Core.EffectRack ();
            play = new Ensembles.Core.RealTimePlay (sf_loc);
            button.clicked.connect (() => {
                fx_rack.print_hello (7);
                play.note_on ();
            });
        }
    }
}