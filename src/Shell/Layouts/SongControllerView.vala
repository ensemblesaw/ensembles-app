/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class SongControllerView : Gtk.Grid {
        Gtk.Button rewind_button;
        Gtk.Button play_button;
        Gtk.Button repeat_button;
        Gtk.Button open_file_button;

        Gtk.FileChooserNative file_chooser;

        Gtk.Window mainwindow;

        bool repeat_on;

        public signal void change_song (string path);
        public signal void play ();
        public signal void change_repeat (bool active);
        public signal void rewind ();

        public SongControllerView (Gtk.Window mainwindow) {
            this.mainwindow = mainwindow;
            rewind_button = new Gtk.Button.from_icon_name ("media-seek-backward-symbolic");
            play_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic");
            repeat_button = new Gtk.Button.from_icon_name (
                "media-playlist-no-repeat-symbolic"
            );
            open_file_button = new Gtk.Button.from_icon_name ("document-open-symbolic");

            play_button.sensitive = false;
            rewind_button.sensitive = false;
            repeat_button.sensitive = false;

            play_button.opacity = 0;
            rewind_button.opacity = 0;
            repeat_button.opacity = 0;

            attach (rewind_button, 0, 0, 1, 1);
            attach (play_button, 1, 0, 1, 1);
            attach (repeat_button, 2, 0, 1, 1);
            attach (open_file_button, 3, 0, 1, 1);

            margin_end = 8;

            this.show ();

            file_chooser = new Gtk.FileChooserNative (_("Open MIDI Song"),
                                                      mainwindow,
                                                      Gtk.FileChooserAction.OPEN,
                                                      _("Open"),
                                                      _("Cancel")
                                                     );
            //  file_chooser.local_only = false;
            file_chooser.modal = true;

            var file_filter_midi = new Gtk.FileFilter ();
            file_filter_midi.add_mime_type ("audio/midi");
            file_filter_midi.set_filter_name (_("MIDI Sequence"));
            file_chooser.add_filter (file_filter_midi);

            open_file_button.clicked.connect (() => {
                file_chooser.show ();
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
                    repeat_button.set_icon_name (
                        "media-playlist-no-repeat-symbolic");
                } else {
                    repeat_on = true;
                    repeat_button.set_icon_name (
                        "media-playlist-repeat-one-symbolic");
                }
                change_repeat (repeat_on);
            });

            play_button.clicked.connect (() => {
                play ();
            });

            rewind_button.clicked.connect (() => {
                rewind ();
            });

            row_homogeneous = true;
        }

        public void set_playing (bool playing) {
            if (playing) {
                play_button.set_icon_name (
                    "media-playback-pause-symbolic");
            } else {
                play_button.set_icon_name (
                    "media-playback-start-symbolic");
            }
        }

        public void set_player_active () {
            play_button.sensitive = true;
            rewind_button.sensitive = true;
            repeat_button.sensitive = true;

            play_button.opacity = 1;
            rewind_button.opacity = 1;
            repeat_button.opacity = 1;
        }
    }
}
