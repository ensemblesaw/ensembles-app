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
    public class SamplerPadView : Gtk.Grid {
        Gtk.Button[] pads;
        Gtk.Button assign_record_button;
        Gtk.Button assign_file_button;
        Gtk.Button stop_button;
        bool assign_mode;
        Gtk.FileChooserDialog file_chooser;
        Gtk.Window mainwindow;
        string current_file_path;
        bool recorded_audio;

        Core.SamplePlayer[] sample_players;
        Core.SampleRecorder sample_recorder;
        public SamplerPadView (Gtk.Window mainwindow) {
            this.mainwindow = mainwindow;
            var header = new Gtk.Label ("SAMPLING  PADS");
            header.valign = Gtk.Align.CENTER;
            header.halign = Gtk.Align.START;
            header.set_opacity (0.4);

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            separator.valign = Gtk.Align.CENTER;

            attach (header, 0, 0, 3, 1);
            attach (separator, 3, 0, 7, 1);

            pads = new Gtk.Button [12];
            for (int i = 0; i < 6; i++) {
                pads[i] = new Gtk.Button ();
                pads[i].get_style_context ().add_class ("sampling-pad");
                pads[i + 6] = new Gtk.Button ();
                pads[i + 6].get_style_context ().add_class ("sampling-pad");
                pads[i].width_request = 32;
                pads[i].hexpand = true;
                pads[i + 6].width_request = 32;
                pads[i + 6].hexpand = true;
                attach (pads[i], i, 1, 1, 1);
                attach (pads[i + 6], i, 2, 1, 1);
            }
            assign_record_button = new Gtk.Button.from_icon_name ("audio-input-microphone-symbolic", Gtk.IconSize.BUTTON);
            assign_record_button.height_request = 38;
            assign_record_button.hexpand = true;
            assign_record_button.vexpand = true;
            assign_record_button.get_style_context ().add_class ("sampler-record-button");
            assign_record_button.get_style_context ().remove_class ("image-button");
            assign_record_button.tooltip_text = _("Click and hold to sample");
            attach (assign_record_button, 7, 1, 1, 1);

            assign_file_button = new Gtk.Button.from_icon_name ("document-open-symbolic", Gtk.IconSize.BUTTON);
            assign_file_button.height_request = 38;
            assign_file_button.hexpand = true;
            assign_file_button.vexpand = true;
            assign_file_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            assign_file_button.get_style_context ().remove_class ("image-button");
            attach (assign_file_button, 7, 2, 1, 1);
            stop_button = new Gtk.Button.with_label ("Stop");
            stop_button.width_request = 51;
            attach (stop_button, 8, 1, 1, 2);
            margin = 4;
            show_all ();

            sample_players = new Core.SamplePlayer[12];
            sample_recorder = new Core.SampleRecorder ();

            file_chooser = new Gtk.FileChooserDialog (_("Open Sound Sample"),
                                                      mainwindow,
                                                      Gtk.FileChooserAction.OPEN,
                                                      _("Cancel"),
                                                      Gtk.ResponseType.CANCEL,
                                                      _("Open"),
                                                      Gtk.ResponseType.ACCEPT
                                                     );
            file_chooser.local_only = false;
            file_chooser.modal = true;

            var file_filter_wav = new Gtk.FileFilter ();
            file_filter_wav.add_mime_type ("audio/wav");
            file_filter_wav.set_filter_name ("Waveform Audio");
            var file_filter_mp3 = new Gtk.FileFilter ();
            file_filter_mp3.add_mime_type ("audio/mp3");
            file_filter_mp3.set_filter_name ("MPEG Audio Layer III");
            file_chooser.add_filter (file_filter_wav);
            file_chooser.add_filter (file_filter_mp3);

            make_events ();
        }

        void make_events () {
            assign_record_button.button_press_event.connect (() => {
                assign_record_button.get_style_context ().add_class ("sampler-record-button-active");
                sample_recorder.start_recording ();
                return false;
            });
            assign_record_button.button_release_event.connect (() => {
                assign_record_button.get_style_context ().remove_class ("sampler-record-button-active");
                sample_recorder.stop_recording ();
                return false;
            });
            sample_recorder.handle_recording_complete.connect ((path) => {
                current_file_path = path;
                debug ("%s\n", current_file_path);
                assign_mode = true;
                recorded_audio = true;
                stop_button.set_label ("Cancel");
                for (int i = 0; i < 12; i++) {
                    pads[i].get_style_context ().add_class ("sampler-pad-assignable");
                }
            });
            assign_file_button.clicked.connect (() => {
                file_chooser.run ();
                file_chooser.hide ();
            });
            file_chooser.response.connect ((response_id) => {
                if (response_id == -3) {
                    current_file_path = file_chooser.get_file ().get_path ();
                    debug ("%d\n", response_id);
                    assign_mode = true;
                    recorded_audio = false;
                    stop_button.set_label ("Cancel");
                    for (int i = 0; i < 12; i++) {
                        pads[i].get_style_context ().add_class ("sampler-pad-assignable");
                    }
                }
            });

            stop_button.clicked.connect (() => {
                for (int i = 0; i < 12; i++) {
                    if (sample_players[i] != null) {
                        sample_players[i].stop_sample ();
                    }
                }
                assign_mode = false;
                sample_recorder.cancel_recording ();
                stop_button.set_label ("Stop");
                for (int i = 0; i < 12; i++) {
                    pads[i].get_style_context ().remove_class ("sampler-pad-assignable");
                }
            });

            this.get_toplevel ().destroy.connect (() => {
                debug ("CLEANUP: Removing temporary sample recordings\n");
                for (int i = 0; i < 12; i++) {
                    if (sample_players[i] != null) {
                        sample_players[i].unref ();
                    }
                }
            });

            pads[0].clicked.connect (() => {
                if (assign_mode) {
                    if (sample_players[0] != null) {
                       // sample_players[0].
                    }
                    sample_players[0] = new Core.SamplePlayer (current_file_path, recorded_audio);
                    debug ("Assigned\n");
                    assign_mode = false;
                    stop_button.set_label ("Stop");
                    for (int i = 0; i < 12; i++) {
                        pads[i].get_style_context ().remove_class ("sampler-pad-assignable");
                    }
                } else {
                    if (sample_players[0] != null) {
                        sample_players[0].play_sample ();
                    }
                }
            });
            pads[1].clicked.connect (() => {
                if (assign_mode) {
                    sample_players[1] = new Core.SamplePlayer (current_file_path, recorded_audio);
                    debug ("Assigned\n");
                    assign_mode = false;
                    for (int i = 0; i < 12; i++) {
                        pads[i].get_style_context ().remove_class ("sampler-pad-assignable");
                    }
                } else {
                    if (sample_players[1] != null) {
                        sample_players[1].play_sample ();
                    }
                }
            });
            pads[2].clicked.connect (() => {
                if (assign_mode) {
                    sample_players[2] = new Core.SamplePlayer (current_file_path, recorded_audio);
                    debug ("Assigned\n");
                    assign_mode = false;
                    for (int i = 0; i < 12; i++) {
                        pads[i].get_style_context ().remove_class ("sampler-pad-assignable");
                    }
                } else {
                    if (sample_players[2] != null) {
                        sample_players[2].play_sample ();
                    }
                }
            });
            pads[3].clicked.connect (() => {
                if (assign_mode) {
                    sample_players[3] = new Core.SamplePlayer (current_file_path, recorded_audio);
                    debug ("Assigned\n");
                    assign_mode = false;
                    for (int i = 0; i < 12; i++) {
                        pads[i].get_style_context ().remove_class ("sampler-pad-assignable");
                    }
                } else {
                    if (sample_players[3] != null) {
                        sample_players[3].play_sample ();
                    }
                }
            });
            pads[4].clicked.connect (() => {
                if (assign_mode) {
                    sample_players[4] = new Core.SamplePlayer (current_file_path, recorded_audio);
                    debug ("Assigned\n");
                    assign_mode = false;
                    for (int i = 0; i < 12; i++) {
                        pads[i].get_style_context ().remove_class ("sampler-pad-assignable");
                    }
                } else {
                    if (sample_players[4] != null) {
                        sample_players[4].play_sample ();
                    }
                }
            });
            pads[5].clicked.connect (() => {
                if (assign_mode) {
                    sample_players[5] = new Core.SamplePlayer (current_file_path, recorded_audio);
                    debug ("Assigned\n");
                    assign_mode = false;
                    for (int i = 0; i < 12; i++) {
                        pads[i].get_style_context ().remove_class ("sampler-pad-assignable");
                    }
                } else {
                    if (sample_players[5] != null) {
                        sample_players[5].play_sample ();
                    }
                }
            });
            pads[6].clicked.connect (() => {
                if (assign_mode) {
                    sample_players[6] = new Core.SamplePlayer (current_file_path, recorded_audio);
                    debug ("Assigned\n");
                    assign_mode = false;
                    for (int i = 0; i < 12; i++) {
                        pads[i].get_style_context ().remove_class ("sampler-pad-assignable");
                    }
                } else {
                    if (sample_players[6] != null) {
                        sample_players[6].play_sample ();
                    }
                }
            });
            pads[7].clicked.connect (() => {
                if (assign_mode) {
                    sample_players[7] = new Core.SamplePlayer (current_file_path, recorded_audio);
                    debug ("Assigned\n");
                    assign_mode = false;
                    for (int i = 0; i < 12; i++) {
                        pads[i].get_style_context ().remove_class ("sampler-pad-assignable");
                    }
                } else {
                    if (sample_players[7] != null) {
                        sample_players[7].play_sample ();
                    }
                }
            });
            pads[8].clicked.connect (() => {
                if (assign_mode) {
                    sample_players[8] = new Core.SamplePlayer (current_file_path, recorded_audio);
                    debug ("Assigned\n");
                    assign_mode = false;
                    for (int i = 0; i < 12; i++) {
                        pads[i].get_style_context ().remove_class ("sampler-pad-assignable");
                    }
                } else {
                    if (sample_players[8] != null) {
                        sample_players[8].play_sample ();
                    }
                }
            });
            pads[9].clicked.connect (() => {
                if (assign_mode) {
                    sample_players[9] = new Core.SamplePlayer (current_file_path, recorded_audio);
                    debug ("Assigned\n");
                    assign_mode = false;
                    for (int i = 0; i < 12; i++) {
                        pads[i].get_style_context ().remove_class ("sampler-pad-assignable");
                    }
                } else {
                    if (sample_players[9] != null) {
                        sample_players[9].play_sample ();
                    }
                }
            });
            pads[10].clicked.connect (() => {
                if (assign_mode) {
                    sample_players[10] = new Core.SamplePlayer (current_file_path, recorded_audio);
                    debug ("Assigned\n");
                    assign_mode = false;
                    for (int i = 0; i < 12; i++) {
                        pads[i].get_style_context ().remove_class ("sampler-pad-assignable");
                    }
                } else {
                    if (sample_players[10] != null) {
                        sample_players[10].play_sample ();
                    }
                }
            });
            pads[11].clicked.connect (() => {
                if (assign_mode) {
                    sample_players[11] = new Core.SamplePlayer (current_file_path, recorded_audio);
                    debug ("Assigned\n");
                    assign_mode = false;
                    for (int i = 0; i < 12; i++) {
                        pads[i].get_style_context ().remove_class ("sampler-pad-assignable");
                    }
                } else {
                    if (sample_players[11] != null) {
                        sample_players[11].play_sample ();
                    }
                }
            });
        }

        public void set_sampler_volume (double volume) {
            for (int i = 0; i < 12; i++) {
                if (sample_players[i] != null) {
                    sample_players[i].set_volume (volume);
                }
            }
        }
    }
}
