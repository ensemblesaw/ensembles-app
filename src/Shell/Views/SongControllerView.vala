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

namespace Ensembles.Shell { 
    public class SongControllerView : Gtk.Grid {
        Gtk.Button prev_button;
        Gtk.Button play_button;
        Gtk.Button next_button;

        public SongControllerView () {
            prev_button = new Gtk.Button.from_icon_name ("media-skip-backward-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            play_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            next_button = new Gtk.Button.from_icon_name ("media-skip-forward-symbolic", Gtk.IconSize.LARGE_TOOLBAR);

            attach (prev_button, 0, 0, 1, 1);
            attach (play_button, 1, 0, 1, 1);
            attach (next_button, 2, 0, 1, 1);

            margin_end = 8;

            this.show_all ();
        }
    }
}