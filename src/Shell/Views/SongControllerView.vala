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
        Gtk.Button rewind_button;
        Gtk.Button play_button;
        Gtk.Button repeat_button;
        Gtk.Button open_file_button;

        Gtk.FileChooserDialog file_chooser;

        Gtk.Window mainwindow;

        bool repeat_on;

        public signal void change_song (string path);
        public signal void play ();
        public signal void change_repeat (bool active);
        public signal void rewind ();

        public SongControllerView (Gtk.Window mainwindow) {
            this.mainwindow = mainwindow;
            rewind_button = new Gtk.Button.from_icon_name ("media-seek-backward-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            play_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            repeat_button = new Gtk.Button.from_icon_name ("media-playlist-no-repeat-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            open_file_button = new Gtk.Button.from_icon_name ("document-open-symbolic", Gtk.IconSize.LARGE_TOOLBAR);

            play_button.sensitive = false;
            rewind_button.sensitive = false;
            repeat_button.sensitive = false;

            attach (rewind_button, 0, 0, 1, 1);
            attach (play_button, 1, 0, 1, 1);
            attach (repeat_button, 2, 0, 1, 1);
            attach (open_file_button, 3, 0, 1, 1);

            margin_end = 8;

            this.show_all ();

            file_chooser = new Gtk.FileChooserDialog (_("Open MIDI Song"),
                                                      mainwindow,
                                                      Gtk.FileChooserAction.OPEN,
                                                      _("Cancel"),
                                                      Gtk.ResponseType.CANCEL,
                                                      _("Open"),
                                                      Gtk.ResponseType.ACCEPT
                                                     );
            file_chooser.local_only = false;
            file_chooser.modal = true;

            var file_filter_midi = new Gtk.FileFilter ();
            file_filter_midi.add_mime_type ("audio/midi");
            file_filter_midi.set_filter_name ("MIDI Sequence");
            file_chooser.add_filter (file_filter_midi);

            open_file_button.clicked.connect (() => {
                file_chooser.run ();
                file_chooser.hide ();
            });

            file_chooser.response.connect ((response_id) => {
                if (response_id == -3) {
                    string current_file_path = file_chooser.get_file ().get_path ();
                    change_song (current_file_path);
                }
            });

            repeat_button.clicked.connect (() => {
                if (repeat_on) {
                    repeat_on = false;
                    repeat_button.set_image (new Gtk.Image.from_icon_name ("media-playlist-no-repeat-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
                } else {
                    repeat_on = true;
                    repeat_button.set_image (new Gtk.Image.from_icon_name ("media-playlist-repeat-one-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
                }
                change_repeat (repeat_on);
            });

            play_button.clicked.connect (() => {
                play ();
            });

            rewind_button.clicked.connect (() => {
                rewind ();
            });
        }

        public void set_playing (bool playing) {
            if (playing) {
                play_button.set_image (new Gtk.Image.from_icon_name ("media-playback-pause-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
            } else {
                play_button.set_image (new Gtk.Image.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
            }
        }

        public void set_player_active () {
            play_button.sensitive = true;
            rewind_button.sensitive = true;
            repeat_button.sensitive = true;
        }
    }
}
