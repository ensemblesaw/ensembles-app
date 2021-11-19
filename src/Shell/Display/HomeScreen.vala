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
    public class HomeScreen : Gtk.Grid {
        int tempo = 33;
        Gtk.Button style_button;
        Gtk.Button voice_l_button;
        Gtk.Button voice_r1_button;
        Gtk.Button voice_r2_button;

        Gtk.Button fx_rack_button;

        Gtk.Label selected_style_label;
        Gtk.Label selected_voice_l_label;
        Gtk.Label selected_voice_r1_label;
        Gtk.Label selected_voice_r2_label;

        Gtk.Label tempo_label;
        Gtk.Label measure_label;
        Gtk.Label beat_label;
        Gtk.Label transpose_label;
        Gtk.Label octave_shift_label;
        Gtk.Label chord_label;
        Gtk.Label chord_flat_label;
        Gtk.Label chord_type_label;

        EqualizerBar[] equalizer_bar;
        Gtk.Button[] channel_configure_buttons;

        public signal void open_style_menu ();
        public signal void open_voice_l_menu ();
        public signal void open_voice_r1_menu ();
        public signal void open_voice_r2_menu ();
        public signal void open_fx_menu ();
        public signal void edit_channel (int synth_index, int channel);

        public HomeScreen () {
            this.get_style_context ().add_class ("home-screen-background");

            var top_panel = new Gtk.Grid ();
            top_panel.get_style_context ().add_class ("home-screen-panel-top");
            top_panel.height_request = 46;
            top_panel.width_request = 460;

            var style_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            style_button_box.height_request = 46;
            var style_label = new Gtk.Label (_("Style"));
            style_label.halign = Gtk.Align.CENTER;
            style_label.get_style_context ().add_class ("display-top-panel-header");
            selected_style_label = new Gtk.Label (_("Dance Pop"));
            selected_style_label.ellipsize = Pango.EllipsizeMode.MIDDLE;
            selected_style_label.halign = Gtk.Align.CENTER;
            selected_style_label.get_style_context ().add_class ("display-top-panel-subheader");
            style_button_box.pack_start (style_label, false, true, 0);
            style_button_box.pack_end (selected_style_label, false, true, 0);
            style_button_box.hexpand = true;
            style_button = new Gtk.Button ();
            style_button.add (style_button_box);
            style_button.get_style_context ().add_class ("display-top-panel-button");

            style_button.clicked.connect (() => {
                open_style_menu ();
            });

            var voice_l_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            voice_l_button_box.height_request = 46;
            voice_l_button_box.get_style_context ().add_class ("display-top-panel-button");
            var voice_l_label = new Gtk.Label (_("Voice L"));
            voice_l_label.halign = Gtk.Align.CENTER;
            voice_l_label.get_style_context ().add_class ("display-top-panel-header");
            selected_voice_l_label = new Gtk.Label (_("Finger Bass"));
            selected_voice_l_label.ellipsize = Pango.EllipsizeMode.MIDDLE;
            selected_voice_l_label.halign = Gtk.Align.CENTER;
            selected_voice_l_label.get_style_context ().add_class ("display-top-panel-subheader");
            voice_l_button_box.pack_start (voice_l_label, false, true, 0);
            voice_l_button_box.pack_end (selected_voice_l_label, false, true, 0);
            voice_l_button_box.hexpand = true;
            voice_l_button = new Gtk.Button ();
            voice_l_button.add (voice_l_button_box);
            voice_l_button.get_style_context ().add_class ("display-top-panel-button");

            voice_l_button.clicked.connect (() => {
                open_voice_l_menu ();
            });

            var voice_r1_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            voice_r1_button_box.height_request = 46;
            voice_r1_button_box.get_style_context ().add_class ("display-top-panel-button");
            var voice_r1_label = new Gtk.Label (_("Voice R1"));
            voice_r1_label.halign = Gtk.Align.CENTER;
            voice_r1_label.get_style_context ().add_class ("display-top-panel-header");
            selected_voice_r1_label = new Gtk.Label (_("Grand Piano"));
            selected_voice_r1_label.ellipsize = Pango.EllipsizeMode.MIDDLE;
            selected_voice_r1_label.halign = Gtk.Align.CENTER;
            selected_voice_r1_label.get_style_context ().add_class ("display-top-panel-subheader");
            voice_r1_button_box.pack_start (voice_r1_label, false, true, 0);
            voice_r1_button_box.pack_end (selected_voice_r1_label, false, true, 0);
            voice_r1_button_box.hexpand = true;
            voice_r1_button = new Gtk.Button ();
            voice_r1_button.add (voice_r1_button_box);
            voice_r1_button.get_style_context ().add_class ("display-top-panel-button");

            voice_r1_button.clicked.connect (() => {
                open_voice_r1_menu ();
            });

            var voice_r2_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            voice_r2_button_box.height_request = 46;
            voice_r2_button_box.get_style_context ().add_class ("display-top-panel-button");
            var voice_r2_label = new Gtk.Label (_("Voice R2"));
            voice_r2_label.halign = Gtk.Align.CENTER;
            voice_r2_label.get_style_context ().add_class ("display-top-panel-header");
            selected_voice_r2_label = new Gtk.Label (_("Slow Strings"));
            selected_voice_r2_label.ellipsize = Pango.EllipsizeMode.MIDDLE;
            selected_voice_r2_label.halign = Gtk.Align.CENTER;
            selected_voice_r2_label.get_style_context ().add_class ("display-top-panel-subheader");
            voice_r2_button_box.pack_start (voice_r2_label, false, true, 0);
            voice_r2_button_box.pack_end (selected_voice_r2_label, false, true, 0);
            voice_r2_button_box.hexpand = true;
            voice_r2_button = new Gtk.Button ();
            voice_r2_button.add (voice_r2_button_box);
            voice_r2_button.get_style_context ().add_class ("display-top-panel-button");

            voice_r2_button.clicked.connect (() => {
                open_voice_r2_menu ();
            });


            top_panel.attach (style_button, 0, 0, 1, 1);
            top_panel.attach (voice_l_button, 1, 0, 1, 1);
            top_panel.attach (voice_r1_button, 2, 0, 1, 1);
            top_panel.attach (voice_r2_button, 3, 0, 1, 1);

            top_panel.column_homogeneous = true;




            // Bottom part
            var tempo_header = new Gtk.Label (_("Tempo"));
            tempo_header.get_style_context ().add_class ("display-bottom-panel-header");
            var measure_header = new Gtk.Label (_("Measure"));
            measure_header.get_style_context ().add_class ("display-bottom-panel-header");
            var time_sig_header = new Gtk.Label (_("Beat"));
            time_sig_header.get_style_context ().add_class ("display-bottom-panel-header");
            var transpose_header = new Gtk.Label (_("Transpose"));
            transpose_header.get_style_context ().add_class ("display-bottom-panel-header");
            var octave_shift_header = new Gtk.Label (_("Octave"));
            octave_shift_header.get_style_context ().add_class ("display-bottom-panel-header");
            var chord_header = new Gtk.Label (_("Chord"));
            chord_header.get_style_context ().add_class ("display-bottom-panel-header");
            chord_header.hexpand = true;

            tempo_label = new Gtk.Label ("125");
            tempo_label.get_style_context ().add_class ("display-bottom-panel-label");
            measure_label = new Gtk.Label ("0");
            measure_label.get_style_context ().add_class ("display-bottom-panel-label");
            beat_label = new Gtk.Label ("4/4");
            beat_label.get_style_context ().add_class ("display-bottom-panel-label");
            transpose_label = new Gtk.Label ("0");
            transpose_label.get_style_context ().add_class ("display-bottom-panel-label");
            octave_shift_label = new Gtk.Label ("0");
            octave_shift_label.get_style_context ().add_class ("display-bottom-panel-label");
            chord_label = new Gtk.Label ("C");
            chord_label.valign = Gtk.Align.START;
            chord_label.halign = Gtk.Align.END;
            chord_label.get_style_context ().add_class ("display-bottom-panel-label");
            chord_flat_label = new Gtk.Label ("");
            chord_flat_label.get_style_context ().add_class ("display-bottom-panel-label-small");
            chord_flat_label.halign = Gtk.Align.START;
            chord_type_label = new Gtk.Label ("");
            chord_type_label.get_style_context ().add_class ("display-bottom-panel-label-small");
            chord_type_label.halign = Gtk.Align.START;

            var tempo_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            tempo_box.pack_start (tempo_header, false, true, 0);
            tempo_box.pack_end (tempo_label, false, true, 0);
            tempo_box.valign = Gtk.Align.START;
            tempo_box.margin_top = 2;

            var measure_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            measure_box.pack_start (measure_header, false, true, 0);
            measure_box.pack_end (measure_label, false, true, 0);
            measure_box.valign = Gtk.Align.START;
            measure_box.margin_top = 2;

            var beat_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            beat_box.pack_start (time_sig_header, false, true, 0);
            beat_box.pack_end (beat_label, false, true, 0);
            beat_box.valign = Gtk.Align.START;
            beat_box.margin_top = 2;

            var transpose_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            transpose_box.pack_start (transpose_header, false, true, 0);
            transpose_box.pack_end (transpose_label, false, true, 0);
            transpose_box.valign = Gtk.Align.START;
            transpose_box.margin_top = 2;

            var octave_shift_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            octave_shift_box.pack_start (octave_shift_header, false, true, 0);
            octave_shift_box.pack_end (octave_shift_label, false, true, 0);
            octave_shift_box.valign = Gtk.Align.START;
            octave_shift_box.margin_top = 2;

            var chord_box = new Gtk.Grid ();
            chord_box.attach (chord_header, 0, 0, 2, 1);
            chord_box.attach (chord_label, 0, 1, 1, 2);
            chord_box.attach (chord_flat_label, 1, 1, 2, 1);
            chord_box.attach (chord_type_label, 1, 2, 2, 1);
            chord_box.margin_top = 2;

            var equalizer_grid = new Gtk.Grid ();
            equalizer_bar = new EqualizerBar[19];
            for (int i = 0; i < 19; i++) {
                equalizer_bar[i] = new EqualizerBar ();
                equalizer_grid.attach (equalizer_bar[i], i, 0, 1, 1);
            }
            equalizer_grid.column_spacing = 4;
            equalizer_grid.column_homogeneous = true;
            equalizer_grid.margin_start = 6;
            equalizer_grid.margin_end = 6;
            equalizer_grid.margin_top = 4;

            var equalizer_label_grid = new Gtk.Grid ();
            for (int i = 0; i < 16; i++) {
                equalizer_label_grid.attach (new Gtk.Label ((i + 1).to_string ()), i, 0, 1, 1);
            }
            equalizer_label_grid.attach (new Gtk.Label ("L"), 16, 0, 1, 1);
            equalizer_label_grid.attach (new Gtk.Label ("R1"), 17, 0, 1, 1);
            equalizer_label_grid.attach (new Gtk.Label ("R2"), 18, 0, 1, 1);

            equalizer_label_grid.column_homogeneous = true;
            equalizer_label_grid.column_spacing = 2;
            equalizer_label_grid.margin_start = 4;
            equalizer_label_grid.margin_end = 6;
            equalizer_label_grid.get_style_context ().add_class ("home-screen-eq-labels");

            var channel_button_grid = new Gtk.Grid ();
            channel_button_grid.margin_start = 2;
            channel_button_grid.margin_end = 2;
            channel_button_grid.column_homogeneous = true;
            channel_configure_buttons = new Gtk.Button [19];
            for (int i = 0; i < 19; i++) {
                channel_configure_buttons[i] = new Gtk.Button.from_icon_name ("preferences-system-symbolic",
                                                                              Gtk.IconSize.BUTTON);
                channel_configure_buttons[i].get_style_context ().add_class ("channel-configure-button");
                channel_button_grid.attach (channel_configure_buttons[i], i, 0, 1, 1);
            }
            connect_channel_buttons ();

            var bottom_panel = new Gtk.Grid ();
            bottom_panel.get_style_context ().add_class ("home-screen-panel-bottom");
            bottom_panel.height_request = 111;
            bottom_panel.attach (tempo_box, 0, 0, 1, 1);
            bottom_panel.attach (measure_box, 1, 0, 1, 1);
            bottom_panel.attach (beat_box, 2, 0, 1, 1);
            bottom_panel.attach (transpose_box, 3, 0, 1, 1);
            bottom_panel.attach (octave_shift_box, 4, 0, 1, 1);
            bottom_panel.attach (chord_box, 5, 0, 1, 1);
            bottom_panel.attach (equalizer_grid, 0, 1, 6, 1);
            bottom_panel.attach (equalizer_label_grid, 0, 3, 6, 1);
            bottom_panel.attach (channel_button_grid, 0, 4, 6, 1);
            bottom_panel.set_column_homogeneous (true);


            fx_rack_button = new Gtk.Button.with_label ("𝑓𝑥 Effects Rack");
            fx_rack_button.margin = 4;
            fx_rack_button.clicked.connect (() => {
                open_fx_menu ();
            });

            var mid_panel = new Gtk.Grid ();
            mid_panel.hexpand = true;
            mid_panel.vexpand = true;
            mid_panel.column_homogeneous = true;
            this.attach (top_panel, 0, 0, 1, 1);
            this.attach (mid_panel, 0, 1, 1, 1);
            this.attach (bottom_panel, 0, 2, 1, 1);

            update_equalizer.begin ();
        }

        public void connect_channel_buttons () {
            channel_configure_buttons[0].clicked.connect (() => {
                edit_channel (1, 0);
            });
            channel_configure_buttons[1].clicked.connect (() => {
                edit_channel (1, 1);
            });
            channel_configure_buttons[2].clicked.connect (() => {
                edit_channel (1, 2);
            });
            channel_configure_buttons[3].clicked.connect (() => {
                edit_channel (1, 3);
            });
            channel_configure_buttons[4].clicked.connect (() => {
                edit_channel (1, 4);
            });
            channel_configure_buttons[5].clicked.connect (() => {
                edit_channel (1, 5);
            });
            channel_configure_buttons[6].clicked.connect (() => {
                edit_channel (1, 6);
            });
            channel_configure_buttons[7].clicked.connect (() => {
                edit_channel (1, 7);
            });
            channel_configure_buttons[8].clicked.connect (() => {
                edit_channel (1, 8);
            });
            channel_configure_buttons[9].clicked.connect (() => {
                edit_channel (1, 9);
            });
            channel_configure_buttons[10].clicked.connect (() => {
                edit_channel (1, 10);
            });
            channel_configure_buttons[11].clicked.connect (() => {
                edit_channel (1, 11);
            });
            channel_configure_buttons[12].clicked.connect (() => {
                edit_channel (1, 12);
            });
            channel_configure_buttons[13].clicked.connect (() => {
                edit_channel (1, 13);
            });
            channel_configure_buttons[14].clicked.connect (() => {
                edit_channel (1, 14);
            });
            channel_configure_buttons[15].clicked.connect (() => {
                edit_channel (1, 15);
            });
            channel_configure_buttons[17].clicked.connect (() => {
                edit_channel (0, 0);
            });
            channel_configure_buttons[16].clicked.connect (() => {
                edit_channel (0, 2);
            });
            channel_configure_buttons[18].clicked.connect (() => {
                edit_channel (0, 1);
            });
        }

        public void set_style_name (string name) {
            selected_style_label.set_text (name);
            selected_style_label.queue_draw ();
        }
        public void set_voice_l_name (string name) {
            selected_voice_l_label.set_text (name);
            selected_voice_l_label.queue_draw ();
        }
        public void set_voice_r1_name (string name) {
            selected_voice_r1_label.set_text (name);
            selected_voice_r1_label.queue_draw ();
        }
        public void set_voice_r2_name (string name) {
            selected_voice_r2_label.set_text (name);
            selected_voice_r2_label.queue_draw ();
        }
        public void set_tempo (int tempo) {
            tempo_label.set_text (tempo.to_string ());
            this.tempo = tempo;
        }
        public void set_measure (int measure) {
            measure_label.set_text (measure.to_string ());
            measure_label.queue_draw ();
        }

        public void set_chord (int chord_main, int chord_type) {
            switch (chord_main) {
                case 0:
                chord_label.set_text ("C");
                chord_flat_label.set_text ("");
                break;
                case 1:
                chord_label.set_text ("C");
                chord_flat_label.set_text ("♯");
                break;
                case 2:
                chord_label.set_text ("D");
                chord_flat_label.set_text ("");
                break;
                case 3:
                chord_label.set_text ("E");
                chord_flat_label.set_text ("♭");
                break;
                case 4:
                chord_label.set_text ("E");
                chord_flat_label.set_text ("");
                break;
                case 5:
                chord_label.set_text ("F");
                chord_flat_label.set_text ("");
                break;
                case 6:
                chord_label.set_text ("F");
                chord_flat_label.set_text ("♯");
                break;
                case -5:
                chord_label.set_text ("G");
                chord_flat_label.set_text ("");
                break;
                case -4:
                chord_label.set_text ("A");
                chord_flat_label.set_text ("♭");
                break;
                case -3:
                chord_label.set_text ("A");
                chord_flat_label.set_text ("");
                break;
                case -2:
                chord_label.set_text ("B");
                chord_flat_label.set_text ("♭");
                break;
                case -1:
                chord_label.set_text ("B");
                chord_flat_label.set_text ("");
                break;
            }
            switch (chord_type) {
                case 0:
                chord_type_label.set_text ("");
                break;
                case 1:
                chord_type_label.set_text ("min");
                break;
            }
            chord_label.queue_draw ();
            chord_flat_label.queue_draw ();
            chord_type_label.queue_draw ();
        }

        async void update_equalizer () {
            Timeout.add (60000 / (tempo * 16), () => {
                if (Core.CentralBus.get_style_looping_on ()) {
                    for (int i = 0; i < 16; i++) {
                        equalizer_bar[i].velocity = Ensembles.Core.Synthesizer.get_channel_velocity (1, i);
                    }
                }
                equalizer_bar[16].velocity = Ensembles.Core.Synthesizer.get_channel_velocity (0, 2);
                equalizer_bar[17].velocity = Ensembles.Core.Synthesizer.get_channel_velocity (0, 0);
                equalizer_bar[18].velocity = Ensembles.Core.Synthesizer.get_channel_velocity (0, 1);
                return true;
            });
        }
    }
}
