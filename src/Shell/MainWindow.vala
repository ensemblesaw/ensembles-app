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
    public class MainWindow : Gtk.Window {
        StyleControllerView style_controller_view;
        BeatCounterView beat_counter_panel;
        MainDisplayCasing main_display_unit;
        ControlPanel ctrl_panel;
        SliderBoardView slider_board;
        VoiceCategoryView voice_category_panel;
        MixerBoardView mixer_board_view;
        SamplerPadView sampler_panel;
        RegistryView registry_panel;
        AppMenuView app_menu;
        SongControllerView song_control_panel;
        KeyboardView main_keyboard;
        Ensembles.Core.Voice[] detected_voices;
        int[] detected_voice_indices;
        Ensembles.Core.Synthesizer synthesizer;
        Ensembles.Core.StyleDiscovery style_discovery;
        Ensembles.Core.StylePlayer style_player;
        Ensembles.Core.MetronomeLFOPlayer metronome_player;
        Ensembles.Core.CentralBus bus;
        Ensembles.Core.Controller controller_connection;
        Ensembles.Core.SongPlayer song_player;
        Ensembles.Core.Arpeggiator arpeggiator;
        Ensembles.Core.Harmonizer harmonizer;

        string sf_loc = Constants.SF2DATADIR + "/EnsemblesGM.sf2";
        string sf_schema_loc = Constants.SF2DATADIR + "/EnsemblesGMSchema.csv";
        string metronome_lfo_directory = Constants.PKGDATADIR + "/MetronomesAndLFO";

        Gtk.HeaderBar headerbar;
        Gtk.Scale seek_bar;
        Gtk.Label custom_title_text;
        Gtk.Grid custom_title_grid;

        string song_name;

        PcKeyboardHandler keyboard_input_handler;

        public signal void song_player_state_changed (string song_name, Core.SongPlayer.PlayerStatus status);
        public MainWindow () {
            Gtk.Settings settings = Gtk.Settings.get_default ();
            settings.gtk_application_prefer_dark_theme = true;

            debug ("STARTUP: Initializing Settings");

            string driver_string = get_available_driver (EnsemblesApp.settings.get_string ("driver"));
            if (driver_string == "") {
                error ("FATAL: No compatible audio drivers found!");
            }
            
            Core.DriverSettingsProvider.initialize_drivers (
                driver_string,
                EnsemblesApp.settings.get_double ("buffer-length")
            );
            debug ("STARTUP: Loading Central Bus");
            bus = new Ensembles.Core.CentralBus ();
            make_bus_events ();

            keyboard_input_handler = new PcKeyboardHandler ();

            beat_counter_panel = new BeatCounterView ();
            headerbar = new Gtk.HeaderBar ();
            headerbar.has_subtitle = false;
            headerbar.set_show_close_button (true);
            headerbar.title = "Ensembles";
            headerbar.pack_start (beat_counter_panel);

            Gtk.Button app_menu_button = new Gtk.Button.from_icon_name ("open-menu",
                                                                        Gtk.IconSize.LARGE_TOOLBAR);
            headerbar.pack_end (app_menu_button);
            this.set_titlebar (headerbar);

            app_menu = new AppMenuView (app_menu_button);

            app_menu_button.clicked.connect (() => {
                app_menu.popup ();
            });

            song_control_panel = new SongControllerView (this);
            headerbar.pack_end (song_control_panel);

            custom_title_text = new Gtk.Label ("Ensembles");
            custom_title_text.get_style_context ().add_class ("title");
            seek_bar = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 1, 0.01);
            seek_bar.set_draw_value (false);
            seek_bar.width_request = 400;
            custom_title_grid = new Gtk.Grid ();
            custom_title_grid.attach (custom_title_text, 0, 1, 1, 1);
            custom_title_grid.attach (seek_bar, 0, 2, 1, 1);
            custom_title_grid.show_all ();

            main_display_unit = new MainDisplayCasing ();

            ctrl_panel = new ControlPanel ();

            main_keyboard = new KeyboardView ();

            slider_board = new SliderBoardView (main_keyboard.joy_stick);

            voice_category_panel = new VoiceCategoryView ();

            mixer_board_view = new MixerBoardView ();

            sampler_panel = new SamplerPadView (this);

            registry_panel = new RegistryView ();

            style_controller_view = new StyleControllerView ();


            var style_registry_grid = new Gtk.Grid ();
            style_registry_grid.attach (style_controller_view, 0, 0, 1, 1);
            style_registry_grid.attach (registry_panel, 1, 0, 1, 1);

            var grid = new Gtk.Grid ();
            grid.attach (slider_board, 0, 0, 1, 1);
            grid.attach (main_display_unit, 1, 0, 1, 1);
            grid.attach (ctrl_panel, 2, 0, 1, 1);
            grid.attach (voice_category_panel, 0, 1, 1, 1);
            grid.attach (mixer_board_view, 1, 1, 1, 1);
            grid.attach (sampler_panel, 2, 1, 1, 1);
            grid.attach (style_registry_grid, 0, 2, 3, 1);
            grid.attach (main_keyboard, 0, 3, 3, 1);
            this.add (grid);
            this.show_all ();

            debug ("STARTUP: Loading MIDI Input Monitor");
            controller_connection = new Ensembles.Core.Controller ();
            app_menu.change_enable_midi_input.connect ((enable) => {
                if (enable) {
                    var devices_found = controller_connection.get_device_list ();
                    app_menu.update_devices (devices_found);
                }
            });
            app_menu.open_preferences_dialog.connect (open_preferences);
            debug ("STARTUP: Loading Synthesizer");
            synthesizer = new Ensembles.Core.Synthesizer (sf_loc);
            main_keyboard.connect_synthesizer (synthesizer);
            debug ("STARTUP: Loading Style Engine");
            style_player = new Ensembles.Core.StylePlayer ();

            debug ("STARTUP: Discovering Styles");
            style_discovery = new Ensembles.Core.StyleDiscovery ();
            style_discovery.analysis_complete.connect (() => {
                //  style_player.add_style_file (style_discovery.styles.nth_data (0).path);
                main_display_unit.update_style_list (style_discovery.styles);
            });

            debug ("STARTUP: Loading Metronome and LFO Engine");
            metronome_player = new Ensembles.Core.MetronomeLFOPlayer (metronome_lfo_directory);

            arpeggiator = new Core.Arpeggiator ();
            harmonizer = new Core.Harmonizer ();

            make_ui_events ();

            load_voices ();
        }
        void make_bus_events () {
            bus.clock_tick.connect (() => {
                beat_counter_panel.sync ();
                style_controller_view.sync ();
                main_display_unit.set_measure_display (Ensembles.Core.CentralBus.get_measure ());
                if (metronome_player.looping) metronome_player.stop_loop ();
                metronome_player.play_measure (Core.CentralBus.get_beats_per_bar (), Core.CentralBus.get_quarter_notes_per_bar ());
            });
            bus.system_halt.connect (() => {
                style_player.reload_style ();
                beat_counter_panel.halt ();
                metronome_player.stop_loop ();
            });
            bus.system_ready.connect (() => {
                Timeout.add (2000, () => {
                    Idle.add (() => {
                        main_display_unit.queue_remove_splash ();
                        style_controller_view.ready ();
                        ctrl_panel.load_settings ();
                        return false;
                    });
                    return false;
                });
                Timeout.add (3000, () => {
                    if (song_player != null) {
                        song_player.play ();
                    }
                    return false;
                });
            });
            bus.style_section_change.connect ((section) => {
                style_controller_view.set_style_section (section);
            });
            bus.loaded_tempo_change.connect ((tempo) => {
                beat_counter_panel.change_tempo (tempo);
                main_display_unit.set_tempo_display (tempo);
                if (metronome_player != null)
                    metronome_player.set_tempo (tempo);
                if (arpeggiator != null)
                    arpeggiator.change_tempo (tempo);
            });
            bus.loaded_time_signature_change.connect ((n, d) => {
                if (beat_counter_panel != null) {
                    beat_counter_panel.change_beats_per_bar (n);
                    beat_counter_panel.change_qnotes_per_bar (d);
                    print ("ts: %d\n", d);
                }
            });
            bus.split_key_change.connect (() => {
                main_keyboard.update_split ();
            });
        }
        void make_ui_events () {
            this.key_press_event.connect ((event) => {
                return keyboard_input_handler.handle_keypress_event (event.keyval);
            });
            this.key_release_event.connect ((event) => {
                keyboard_input_handler.handle_keyrelease_event (event.keyval);
                return false;
            });
            this.window_state_event.connect ((event) => {
                if ((int)(event.changed_mask) == 4) {
                    main_keyboard.visible = false;
                    Timeout.add (100, () => {
                        main_keyboard.visible = true;
                        return false;
                    }, Priority.DEFAULT_IDLE);
                }
                return false;
            });
            app_menu.change_active_input_device.connect ((device) => {
                //  debug("%d %s\n", device.id, device.name);
                controller_connection.connect_device (device.id);
            });
            main_display_unit.change_style.connect ((accomp_style) => {
                style_player.add_style_file (accomp_style.path, accomp_style.tempo);
            });
            main_display_unit.change_voice.connect ((voice, channel) => {
                synthesizer.change_voice (voice, channel);
            });
            main_display_unit.change_tempo.connect ((tempo) => {
                style_player.change_tempo (tempo);
            });
            beat_counter_panel.open_tempo_editor.connect (main_display_unit.open_tempo_screen);
            ctrl_panel.accomp_change.connect ((active) => {
                synthesizer.set_accompaniment_on (active);
            });
            ctrl_panel.reverb_change.connect ((level) => {
                synthesizer.set_master_reverb_level (level);
            });
            ctrl_panel.reverb_active_change.connect ((active) => {
                synthesizer.set_master_reverb_active (active);
            });
            ctrl_panel.chorus_change.connect ((level) => {
                synthesizer.set_master_chorus_level (level);
            });
            ctrl_panel.chorus_active_change.connect ((active) => {
                synthesizer.set_master_chorus_active (active);
            });
            ctrl_panel.update_split.connect (() => {
                main_keyboard.update_split ();
            });
            ctrl_panel.start_metronome.connect ((active) => {
                if (active) {
                    Ensembles.Core.CentralBus.set_metronome_on (true);
                    metronome_player.play_loop (Core.CentralBus.get_beats_per_bar (), Core.CentralBus.get_quarter_notes_per_bar ());
                } else {
                    metronome_player.stop_loop ();
                    Ensembles.Core.CentralBus.set_metronome_on (false);
                }
            });
            ctrl_panel.dial_rotate.connect (main_display_unit.wheel_scroll);
            ctrl_panel.dial_activate.connect (main_display_unit.wheel_activate);
            registry_panel.notify_recall.connect ((tempo) => {
                ctrl_panel.load_settings ();
                main_display_unit.load_settings (tempo);
            });
            controller_connection.receive_note_event.connect ((key, on, velocity)=>{
                //  debug ("%d %d %d\n", key, on, velocity);
                if (EnsemblesApp.settings.get_boolean ("arpeggiator-on")) {
                    if (EnsemblesApp.settings.get_boolean ("accomp-on")) {
                        if (key > Core.CentralBus.get_split_key ()) {
                            arpeggiator.send_notes (key, on, velocity);
                        } else {
                            synthesizer.send_notes_realtime (key, on, velocity);
                        }
                    } else {
                        arpeggiator.send_notes (key, on, velocity);
                    }
                } else {
                    synthesizer.send_notes_realtime (key, on, velocity);
                }
                if (EnsemblesApp.settings.get_boolean ("harmonizer-on")) {
                    if (EnsemblesApp.settings.get_boolean ("accomp-on")) {
                        if (key > Core.CentralBus.get_split_key ()) {
                            harmonizer.send_notes (key, on, velocity);
                        } else {
                            synthesizer.send_notes_realtime (key, on, velocity);
                        }
                    } else {
                        synthesizer.send_notes_realtime (key, on, velocity);
                    }
                }
                main_keyboard.set_note_on (key, (on == 144));
            });
            keyboard_input_handler.note_activate.connect ((key, on) => {
                if (EnsemblesApp.settings.get_boolean ("arpeggiator-on")) {
                    if (EnsemblesApp.settings.get_boolean ("accomp-on")) {
                        if (key > Core.CentralBus.get_split_key ()) {
                            arpeggiator.send_notes (key, on, 100);
                        } else {
                            synthesizer.send_notes_realtime (key, on, 100);
                        }
                    } else {
                        arpeggiator.send_notes (key, on, 100);
                    }
                } else {
                    synthesizer.send_notes_realtime (key, on, 100);
                }
                if (EnsemblesApp.settings.get_boolean ("harmonizer-on")) {
                    if (EnsemblesApp.settings.get_boolean ("accomp-on")) {
                        if (key > Core.CentralBus.get_split_key ()) {
                            harmonizer.send_notes (key, on, 100);
                        } else {
                            synthesizer.send_notes_realtime (key, on, 100);
                        }
                    } else {
                        synthesizer.send_notes_realtime (key, on, 100);
                    }
                }
                main_keyboard.set_note_on (key, (on == 144));
            });
            arpeggiator.generate_notes.connect ((key, on, velocity) => {
                if (EnsemblesApp.settings.get_boolean ("harmonizer-on")) {
                    if (EnsemblesApp.settings.get_boolean ("accomp-on")) {
                        if (key > Core.CentralBus.get_split_key ()) {
                            harmonizer.send_notes (key, on, velocity);
                        } else {
                            synthesizer.send_notes_realtime (key, on, velocity);
                        }
                    } else {
                        synthesizer.send_notes_realtime (key, on, velocity);
                    }
                } else {
                    synthesizer.send_notes_realtime (key, on, velocity);
                }
            });
            arpeggiator.halt_notes.connect (synthesizer.halt_realtime);
            harmonizer.generate_notes.connect ((key, on, velocity) => {
                if (key > Core.CentralBus.get_split_key ()) {
                    synthesizer.send_notes_realtime (key, on, velocity);
                }
            });
            harmonizer.halt_notes.connect (synthesizer.halt_realtime);

            style_controller_view.start_stop.connect (style_player.play_style);
            style_controller_view.switch_var_a.connect (style_player.switch_var_a);
            style_controller_view.switch_var_b.connect (style_player.switch_var_b);
            style_controller_view.switch_var_c.connect (style_player.switch_var_c);
            style_controller_view.switch_var_d.connect (style_player.switch_var_d);
            style_controller_view.queue_intro_a.connect (style_player.queue_intro_a);
            style_controller_view.queue_intro_b.connect (style_player.queue_intro_b);
            style_controller_view.queue_ending_a.connect (style_player.queue_ending_a);
            style_controller_view.queue_ending_b.connect (style_player.queue_ending_b);
            style_controller_view.break_play.connect (style_player.break_play);
            style_controller_view.sync_start.connect (style_player.sync_start);
            style_controller_view.sync_stop.connect (style_player.sync_stop);

            keyboard_input_handler.style_start_stop.connect (style_player.play_style);
            keyboard_input_handler.style_var_a.connect (style_player.switch_var_a);
            keyboard_input_handler.style_var_b.connect (style_player.switch_var_b);
            keyboard_input_handler.style_var_c.connect (style_player.switch_var_c);
            keyboard_input_handler.style_var_d.connect (style_player.switch_var_d);
            keyboard_input_handler.style_intro_a.connect (style_player.queue_intro_a);
            keyboard_input_handler.style_intro_b.connect (style_player.queue_intro_b);
            keyboard_input_handler.style_ending_a.connect (style_player.queue_ending_a);
            keyboard_input_handler.style_ending_b.connect (style_player.queue_ending_b);
            keyboard_input_handler.style_break.connect (style_player.break_play);

            keyboard_input_handler.registration_recall.connect (registry_panel.registry_recall);
            keyboard_input_handler.registration_bank_change.connect (registry_panel.change_bank);

            synthesizer.detected_chord.connect ((chord, type) => {
                style_player.change_chords (chord, type);
                main_display_unit.set_chord_display (chord, type);
                harmonizer.set_chord (chord, type);
            });
            voice_category_panel.voice_quick_select.connect ((index) => {
                main_display_unit.quick_select_voice (detected_voice_indices[index]);
            });
            mixer_board_view.set_sampler_gain.connect (sampler_panel.set_sampler_volume);
            main_display_unit.channel_mod_screen.broadcast_assignment.connect (slider_board.send_modulator);
            slider_board.send_assignable_mode.connect (main_display_unit.channel_mod_screen.set_assignable);
            slider_board.open_LFO_editor.connect (main_display_unit.open_lfo_screen);
            metronome_player.beat_sync.connect (beat_counter_panel.sync);
            song_control_panel.change_song.connect ((path) => {
                queue_song (path);
                song_player.play ();
            });
            song_control_panel.play.connect (() => {
                if (song_player != null) {
                    if (song_player.get_status () == Core.SongPlayer.PlayerStatus.PLAYING) {
                        song_player.pause ();
                        song_player_state_changed (song_name, Core.SongPlayer.PlayerStatus.READY);
                    } else {
                        song_player.play ();
                        song_player_state_changed (song_name, Core.SongPlayer.PlayerStatus.PLAYING);
                    }
                }
            });
            song_control_panel.rewind.connect (() => {
                if (song_player != null) {
                    song_player.rewind ();
                }
            });
            song_control_panel.change_repeat.connect ((active) => {
                if (song_player != null) {
                    song_player.set_repeat (active);
                }
            });
            seek_bar.change_value.connect (() => {
                if (song_player != null) {
                    song_player.seek ((float) (seek_bar.get_value ()));
                }
                return false;
            });
            seek_bar.button_press_event.connect (() => {
                if (song_player != null) {
                    song_player.seek_lock (true);
                }
                return false;
            });
            seek_bar.button_release_event.connect (() => {
                if (song_player != null) {
                    song_player.seek_lock (false);
                }
                return false;
            });
            this.destroy.connect (() => {
                print ("App Exit\n");
                debug ("CLEANUP: Unloading Registry Memory");
                registry_panel.unref ();
                debug ("CLEANUP: Unloading Slider Board");
                slider_board.unref ();
                debug ("CLEANUP: Unloading Mixer Board");
                mixer_board_view.unref ();
                debug ("CLEANUP: Unloading On-screen Keyboard");
                main_keyboard.unref ();
                debug ("CLEANUP: Unloading Beat Counter");
                beat_counter_panel.unref ();

                debug ("CLEANUP: Unloading MIDI Input Monitor");
                controller_connection.unref ();
                debug ("CLEANUP: Unloading Metronome and LFO Engine");
                metronome_player.unref ();
                debug ("CLEANUP: Unloading Style Engine");
                style_player.unref ();
                if (song_player != null) {
                    debug ("CLEANUP: Unloading Song Player");
                    song_player.songplayer_destroy ();
                    song_player = null;
                }
                debug ("CLEANUP: Unloading Central Bus");
                bus.unref ();
                debug ("CLEANUP: Unloading Synthesizer");
                synthesizer.unref ();
            });
            debug ("Initialized\n");
        }

        void load_voices () {
            var voice_analyser = new Ensembles.Core.VoiceAnalyser (sf_loc, sf_schema_loc);
            detected_voices = voice_analyser.get_all_voices ();
            detected_voice_indices = voice_analyser.get_all_category_indices ();
            main_display_unit.update_voice_list (detected_voices);
        }

        private void update_header_bar (float fraction, int tempo_bpm, Core.SongPlayer.PlayerStatus status) {
            if (status == Core.SongPlayer.PlayerStatus.PLAYING || status == Core.SongPlayer.PlayerStatus.READY) {
                if (headerbar.get_custom_title () == null) {
                    headerbar.set_custom_title (custom_title_grid);
                }
                seek_bar.set_value ((double) fraction);
            } else {
                headerbar.set_custom_title (null);
                seek_bar.set_value (0);
            }
            if (status == Core.SongPlayer.PlayerStatus.PLAYING) {
                song_control_panel.set_playing (true);
            } else {
                song_control_panel.set_playing (false);
            }
        }

        public void open_file (File file) {
            string path = file.get_path ();
            queue_song (path);
        }

        public void queue_song (string path) {
            if (song_player != null) {
                song_player.player_status_changed.disconnect (update_header_bar);
                song_player.songplayer_destroy ();
                song_player = null;
            }
            debug ("Creating new Song Player instance with midi file: %s", path);
            song_player = new Core.SongPlayer (sf_loc, path);
            int song_tempo = song_player.current_file_tempo;
            song_player.player_status_changed.connect (update_header_bar);
            style_player.change_tempo (song_tempo);
            main_display_unit.set_tempo_display (song_tempo);
            try {
                Regex regex = new Regex ("[ \\w-]+?(?=\\.)");
                MatchInfo match_info;
                if (regex.match (path, 0, out match_info)) {
                    song_name = match_info.fetch (0);
                    custom_title_text.set_text ("Now Playing - " + song_name);
                }
                song_player_state_changed (song_name, Core.SongPlayer.PlayerStatus.READY);
            } catch (RegexError e) {
                warning (e.message);
            }
            song_control_panel.set_player_active ();
        }

        public void media_toggle_play () {
            if (song_player != null) {
                if (song_player.get_status () == Core.SongPlayer.PlayerStatus.PLAYING) {
                    song_player.pause ();
                    song_player_state_changed (song_name, Core.SongPlayer.PlayerStatus.READY);
                } else {
                    song_player.play ();
                    song_player_state_changed (song_name, Core.SongPlayer.PlayerStatus.PLAYING);
                }
            } else {
                style_player.play_style ();
            }
        }

        public void media_pause () {
            if (song_player != null) {
                song_player.pause ();
            } else {
                style_player.sync_stop ();
            }
        }

        public void media_prev () {
            if (song_player != null) {
                song_player.rewind ();
            }
        }

        private void open_preferences () {
            var dialog = new Dialogs.Preferences.Preferences ();
            dialog.destroy.connect (Gtk.main_quit);
            dialog.show_all ();
        }

        private string get_available_driver (string driver_from_settings) {
            string driver_string = "";
            switch (EnsemblesApp.settings.get_string ("driver")) {
                case "alsa":
                if (alsa_driver_found > 0) {
                    driver_string = "alsa";
                }
                break;
                case "pulseaudio":
                if (pulseaudio_driver_found > 0) {
                    driver_string = "pulseaudio";
                }
                break;
                case "pipewire":
                if (pipewire_driver_found > 0) {
                    driver_string = "pipewire";
                }
                break;
                case "pipewire-pulse":
                if (pipewire_pulse_driver_found > 0) {
                    driver_string = "pipewire-pulse";
                }
                break;
            }
            if (driver_string == "") {
                if (alsa_driver_found > 0) {
                    return "alsa";
                }
                if (pulseaudio_driver_found > 0) {
                    return "pulseaudio";
                }
                if (pipewire_driver_found > 0) {
                    return "pulseaudio";
                }
                if (pipewire_pulse_driver_found > 0) {
                    return "pipewire-pulse";
                }
            }
            return driver_string;
        }
    }
}
