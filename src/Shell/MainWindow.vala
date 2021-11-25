/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright © 2019 Alain M. (https://github.com/alainm23/planner)<alainmh23@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class MainWindow : Gtk.Window {
        // View components
        public StyleControllerView style_controller_view;
        public BeatCounterView beat_counter_panel;
        public MainDisplayCasing main_display_unit;
        public ControlPanel ctrl_panel;
        public SliderBoardView slider_board;
        public VoiceCategoryView voice_category_panel;
        public MixerBoardView mixer_board_view;
        public SamplerPadView sampler_panel;
        public RegistryView registry_panel;
        public AppMenuView app_menu;
        public SongControllerView song_control_panel;
        public KeyboardView main_keyboard;

        Gtk.HeaderBar headerbar;
        Gtk.Scale seek_bar;
        public Gtk.Label custom_title_text;
        Gtk.Grid custom_title_grid;

        // For song player
        public string song_name;

        // Computer Keyboard input handling
        public PcKeyboardHandler keyboard_input_handler;

        // Signals
        public signal void song_player_state_changed (string song_name, Core.SongPlayer.PlayerStatus status);


        construct {
            // This module looks for computer keyboard input and fires off signals that can be connected to
            keyboard_input_handler = new PcKeyboardHandler ();

            // Make headerbar
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

            // Make the display unit imitation that we see in the center of the app UI
            main_display_unit = new MainDisplayCasing ();

            // Make the control panel that appears to the right
            ctrl_panel = new ControlPanel ();

            // Make the onscreen keyboard that appears at the bottom
            main_keyboard = new KeyboardView ();

            // Make the Slider/Knob section that appears to the left
            slider_board = new SliderBoardView (main_keyboard.joy_stick);

            // Make the Voice Jump list panel that appears below the Slider/Knob panel
            voice_category_panel = new VoiceCategoryView ();

            // Make the main style/voice mixer that appears right below the display unit
            mixer_board_view = new MixerBoardView ();

            // Make the sampling pad panel that appears below the control panel
            sampler_panel = new SamplerPadView (this);

            // Make the registry panel which consists of the registry buttons
            registry_panel = new RegistryView ();

            // Make the style controller panel
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

            // Show list of detected devices when the user enables MIDI Input
            app_menu.change_enable_midi_input.connect ((enable) => {
                if (enable) {
                    var devices_found = Application.arranger_core.controller_connection.get_device_list ();
                    app_menu.update_devices (devices_found);
                }
            });
            // Connect the onscreen keyboard with the synthesizer
            main_keyboard.connect_synthesizer (Application.arranger_core.synthesizer);

            make_ui_events ();
        }
        // Connect UI events
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
                Application.arranger_core.controller_connection.connect_device (device.id);
            });
            app_menu.open_preferences_dialog.connect (open_preferences);
            main_display_unit.change_style.connect ((accomp_style) => {
                Application.arranger_core.style_player.add_style_file (accomp_style.path, accomp_style.tempo);
            });
            main_display_unit.change_voice.connect ((voice, channel) => {
                Application.arranger_core.synthesizer.change_voice (voice, channel);
            });
            main_display_unit.change_tempo.connect ((tempo) => {
                Application.arranger_core.style_player.change_tempo (tempo);
                if (RecorderScreen.sequencer != null) {
                    RecorderScreen.sequencer.initial_settings_tempo = tempo;
                }
            });
            beat_counter_panel.open_tempo_editor.connect (main_display_unit.open_tempo_screen);
            ctrl_panel.accomp_change.connect ((active) => {
                Application.arranger_core.synthesizer.set_accompaniment_on (active);
            });
            ctrl_panel.reverb_change.connect ((level) => {
                Application.arranger_core.synthesizer.set_master_reverb_level (level);
            });
            ctrl_panel.reverb_active_change.connect ((active) => {
                Application.arranger_core.synthesizer.set_master_reverb_active (active);
            });
            ctrl_panel.chorus_change.connect ((level) => {
                Application.arranger_core.synthesizer.set_master_chorus_level (level);
            });
            ctrl_panel.chorus_active_change.connect ((active) => {
                Application.arranger_core.synthesizer.set_master_chorus_active (active);
            });
            ctrl_panel.update_split.connect (() => {
                main_keyboard.update_split ();
            });
            ctrl_panel.start_metronome.connect ((active) => {
                if (active) {
                    Ensembles.Core.CentralBus.set_metronome_on (true);
                    Application.arranger_core.metronome_player.play_loop (Core.CentralBus.get_beats_per_bar (), Core.CentralBus.get_quarter_notes_per_bar ());
                } else {
                    Application.arranger_core.metronome_player.stop_loop ();
                    Ensembles.Core.CentralBus.set_metronome_on (false);
                }
            });
            ctrl_panel.dial_rotate.connect (main_display_unit.wheel_scroll);
            ctrl_panel.dial_activate.connect (main_display_unit.wheel_activate);
            ctrl_panel.open_recorder.connect (main_display_unit.open_recorder_screen);
            registry_panel.notify_recall.connect ((tempo) => {
                ctrl_panel.load_settings ();
                main_display_unit.load_settings (tempo);
            });
            keyboard_input_handler.note_activate.connect ((key, on) => {
                if (Application.settings.get_boolean ("arpeggiator-on")) {
                    if (Application.settings.get_boolean ("accomp-on")) {
                        if (key > Core.CentralBus.get_split_key ()) {
                            Application.arranger_core.arpeggiator.send_notes (key, on, 100);
                        } else {
                            Application.arranger_core.synthesizer.send_notes_realtime (key, on, 100);
                        }
                    } else {
                        Application.arranger_core.arpeggiator.send_notes (key, on, 100);
                    }
                } else {
                    Application.arranger_core.synthesizer.send_notes_realtime (key, on, 100);
                }
                if (Application.settings.get_boolean ("harmonizer-on")) {
                    if (Application.settings.get_boolean ("accomp-on")) {
                        if (key > Core.CentralBus.get_split_key ()) {
                            Application.arranger_core.harmonizer.send_notes (key, on, 100);
                        } else {
                            Application.arranger_core.synthesizer.send_notes_realtime (key, on, 100);
                        }
                    } else {
                        Application.arranger_core.synthesizer.send_notes_realtime (key, on, 100);
                    }
                }
                main_keyboard.set_note_on (key, (on == 144));
            });

            style_controller_view.start_stop.connect (Application.arranger_core.style_player.play_style);
            style_controller_view.switch_var_a.connect (Application.arranger_core.style_player.switch_var_a);
            style_controller_view.switch_var_b.connect (Application.arranger_core.style_player.switch_var_b);
            style_controller_view.switch_var_c.connect (Application.arranger_core.style_player.switch_var_c);
            style_controller_view.switch_var_d.connect (Application.arranger_core.style_player.switch_var_d);
            style_controller_view.queue_intro_a.connect (Application.arranger_core.style_player.queue_intro_a);
            style_controller_view.queue_intro_b.connect (Application.arranger_core.style_player.queue_intro_b);
            style_controller_view.queue_ending_a.connect (Application.arranger_core.style_player.queue_ending_a);
            style_controller_view.queue_ending_b.connect (Application.arranger_core.style_player.queue_ending_b);
            style_controller_view.break_play.connect (Application.arranger_core.style_player.break_play);
            style_controller_view.sync_start.connect (Application.arranger_core.style_player.sync_start);
            style_controller_view.sync_stop.connect (Application.arranger_core.style_player.sync_stop);

            keyboard_input_handler.style_start_stop.connect (Application.arranger_core.style_player.play_style);
            keyboard_input_handler.style_var_a.connect (Application.arranger_core.style_player.switch_var_a);
            keyboard_input_handler.style_var_b.connect (Application.arranger_core.style_player.switch_var_b);
            keyboard_input_handler.style_var_c.connect (Application.arranger_core.style_player.switch_var_c);
            keyboard_input_handler.style_var_d.connect (Application.arranger_core.style_player.switch_var_d);
            keyboard_input_handler.style_intro_a.connect (Application.arranger_core.style_player.queue_intro_a);
            keyboard_input_handler.style_intro_b.connect (Application.arranger_core.style_player.queue_intro_b);
            keyboard_input_handler.style_ending_a.connect (Application.arranger_core.style_player.queue_ending_a);
            keyboard_input_handler.style_ending_b.connect (Application.arranger_core.style_player.queue_ending_b);
            keyboard_input_handler.style_break.connect (Application.arranger_core.style_player.break_play);

            keyboard_input_handler.registration_recall.connect (registry_panel.registry_recall);
            keyboard_input_handler.registration_bank_change.connect (registry_panel.change_bank);

            voice_category_panel.voice_quick_select.connect ((index) => {
                main_display_unit.quick_select_voice (Application.arranger_core.detected_voice_indices[index]);
            });
            mixer_board_view.set_sampler_gain.connect (sampler_panel.set_sampler_volume);
            main_display_unit.channel_mod_screen.broadcast_assignment.connect (slider_board.send_modulator);
            slider_board.send_assignable_mode.connect (main_display_unit.channel_mod_screen.set_assignable);
            slider_board.open_LFO_editor.connect (main_display_unit.open_lfo_screen);
            song_control_panel.change_song.connect ((path) => {
                Application.arranger_core.queue_song (path);
                Application.arranger_core.song_player.play ();
            });
            song_control_panel.play.connect (() => {
                if (Application.arranger_core.song_player != null) {
                    if (Application.arranger_core.song_player.get_status () == Core.SongPlayer.PlayerStatus.PLAYING) {
                        Application.arranger_core.song_player.pause ();
                        song_player_state_changed (song_name, Core.SongPlayer.PlayerStatus.READY);
                    } else {
                        Application.arranger_core.song_player.play ();
                        song_player_state_changed (song_name, Core.SongPlayer.PlayerStatus.PLAYING);
                    }
                }
            });
            song_control_panel.rewind.connect (() => {
                if (Application.arranger_core.song_player != null) {
                    Application.arranger_core.song_player.rewind ();
                }
            });
            song_control_panel.change_repeat.connect ((active) => {
                if (Application.arranger_core.song_player != null) {
                    Application.arranger_core.song_player.set_repeat (active);
                }
            });
            seek_bar.change_value.connect (() => {
                if (Application.arranger_core.song_player != null) {
                    Application.arranger_core.song_player.seek ((float) (seek_bar.get_value ()));
                }
                return false;
            });
            seek_bar.button_press_event.connect (() => {
                if (Application.arranger_core.song_player != null) {
                    Application.arranger_core.song_player.seek_lock (true);
                }
                return false;
            });
            seek_bar.button_release_event.connect (() => {
                if (Application.arranger_core.song_player != null) {
                    Application.arranger_core.song_player.seek_lock (false);
                }
                return false;
            });

            // Perform garbage collection when the app exits
            this.destroy.connect (() => app_exit ());
            debug ("Initialized\n");
        }

        public void app_exit (bool? force_close = false) {
            Idle.add (() => {
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

                if (force_close) {
                    Application.main_window.close ();
                }
                print ("Exiting!\n");
                return false;
            });
        }

        public void update_header_bar (float fraction, int tempo_bpm, Core.SongPlayer.PlayerStatus status) {
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

        // Used by MPRIS
        public void media_toggle_play () {
            if (Application.arranger_core.song_player != null) {
                if (Application.arranger_core.song_player.get_status () == Core.SongPlayer.PlayerStatus.PLAYING) {
                    Application.arranger_core.song_player.pause ();
                    song_player_state_changed (song_name, Core.SongPlayer.PlayerStatus.READY);
                } else {
                    Application.arranger_core.song_player.play ();
                    song_player_state_changed (song_name, Core.SongPlayer.PlayerStatus.PLAYING);
                }
            } else {
                Application.arranger_core.style_player.play_style ();
            }
        }

        public void media_pause () {
            if (Application.arranger_core.song_player != null) {
                Application.arranger_core.song_player.pause ();
            } else {
                Application.arranger_core.style_player.stop_style ();
            }
        }

        public void media_prev () {
            if (Application.arranger_core.song_player != null) {
                Application.arranger_core.song_player.rewind ();
            }
        }

        private void open_preferences () {
            var dialog = new Dialogs.Preferences.Preferences ();
            dialog.destroy.connect (Gtk.main_quit);
            dialog.show_all ();
        }
    }
}
