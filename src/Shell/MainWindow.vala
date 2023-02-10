/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright © 2019 Alain M. (https://github.com/alainm23/planner)<alainmh23@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/*
 * This file is part of Ensembles
 */

namespace Ensembles.Shell {
    public class MainWindow : Gtk.ApplicationWindow {
        private Gtk.EventControllerKey event_controller_key;

        // View components
        public StyleControllerView style_controller_view;
        public BeatCounterView beat_counter_panel;
        public CentralDisplay main_display_unit;
        public ControlPanel ctrl_panel;
        public SliderBoardView slider_board;
        public VoiceCategoryView voice_category_panel;
        public MixerBoardView mixer_board_view;
        public SamplerPadView sampler_panel;
        public RegistryView registry_panel;
        public AppMenuView app_menu;
        public SongControllerView song_control_panel;
        public KeyBed main_keyboard;

        Gtk.HeaderBar headerbar;
        Gtk.Button app_menu_button;
        Gtk.Scale seek_bar;
        public Gtk.Label custom_title_text;
        Gtk.Grid custom_title_grid;
        Gtk.Popover common_context_menu;
        Gtk.Label controller_assignment_label;
        Gtk.Button controller_assign_button;
        Gtk.Button controller_reset_button;
        Gtk.Separator ctx_menu_main_separator;
        int _current_ui_assign_index;

        // Computer Keyboard input handling
        public PcKeyboardHandler keyboard_input_handler;


        construct {
            event_controller_key = new Gtk.EventControllerKey ();
            add_controller ((Gtk.ShortcutController)event_controller_key);
            // This module looks for computer keyboard input and fires off signals that can be connected to
            keyboard_input_handler = new PcKeyboardHandler ();

            make_ui ();
            make_events ();
        }

        void make_ui () {
            title = "Ensembles";

            // Make headerbar
            headerbar = new Gtk.HeaderBar () {
                show_title_buttons = true,
            };
            set_titlebar (headerbar);

            beat_counter_panel = new BeatCounterView ();
            headerbar.pack_start (beat_counter_panel);

            app_menu_button = new Gtk.Button.from_icon_name ("open-menu");
            headerbar.pack_end (app_menu_button);

            Gdk.Rectangle app_menu_button_rect;
            app_menu_button.get_allocation (out app_menu_button_rect);

            app_menu = new AppMenuView () {
                pointing_to = app_menu_button_rect
            };

            song_control_panel = new SongControllerView (this);
            headerbar.pack_end (song_control_panel);

            custom_title_text = new Gtk.Label ("Ensembles");
            custom_title_text.get_style_context ().add_class ("title");
            seek_bar = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 1, 0.01) {
                width_request = 400,
                draw_value = false
            };
            custom_title_grid = new Gtk.Grid ();
            custom_title_grid.attach (custom_title_text, 0, 1, 1, 1);
            custom_title_grid.attach (seek_bar, 0, 2, 1, 1);
            custom_title_grid.show ();

            // Make the display unit imitation that we see in the center of the app UI
            main_display_unit = new CentralDisplay ();

            // Make the control panel that appears to the right
            ctrl_panel = new ControlPanel ();

            // Make the onscreen keyboard that appears at the bottom
            main_keyboard = new KeyBed ();
            // Connect the onscreen keyboard with the synthesizer
            main_keyboard.connect_synthesizer (Application.arranger_core.synthesizer);

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
            set_child (grid);
            show ();

            common_context_menu = new Gtk.Popover ();
            common_context_menu.set_child (get_context_menu ());
        }

        Gtk.Widget get_context_menu () {
            var button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 4) {
                margin_start = 4,
                margin_end = 4,
                margin_top = 4,
                margin_bottom = 4
            };

            controller_assignment_label = new Gtk.Label ("") {
                halign = Gtk.Align.START,
                visible = false
            };

            controller_assignment_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
            button_box.append (controller_assignment_label);

            ctx_menu_main_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
                visible = false
            };

            button_box.append (ctx_menu_main_separator);

            controller_assign_button = new Gtk.Button ();
            var assign_button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4) {
                halign = Gtk.Align.START
            };

            assign_button_box.append (new Gtk.Image.from_icon_name ("insert-link"));
            assign_button_box.append (new Gtk.Label (_("Link MIDI Controller")));
            controller_assign_button.set_child (assign_button_box);
            controller_assign_button.get_style_context ().add_class ("flat");
            button_box.append (controller_assign_button);

            controller_reset_button = new Gtk.Button ();
            var reset_button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4) {
                halign = Gtk.Align.START
            };

            reset_button_box.append (new Gtk.Image.from_icon_name ("list-remove"));
            reset_button_box.append (new Gtk.Label (_("Remove Link")));
            controller_reset_button.set_child (reset_button_box);
            controller_reset_button.get_style_context ().add_class ("flat");
            button_box.append (controller_reset_button);

            return button_box;
        }

        public override void size_allocate (int width, int height, int baseline) {
            base.size_allocate (width, height, baseline);
            main_keyboard.visible = false;
            Timeout.add (100, () => {
                main_keyboard.visible = true;
                return false;
            }, Priority.DEFAULT_IDLE);
        }

        // Connect UI events
        void make_events () {
            app_menu_button.clicked.connect (() => {
                app_menu.popup ();
            });

            event_controller_key.key_pressed.connect ((keyval) => {
                return keyboard_input_handler.handle_keypress_event (keyval);
            });

            event_controller_key.key_released.connect ((keyval) => {
                keyboard_input_handler.handle_keyrelease_event (keyval);
            });

            //  window_state_event.connect ((event) => {
            //      if ((int)(event.changed_mask) == 4) {
            //          main_keyboard.visible = false;
            //          Timeout.add (100, () => {
            //              main_keyboard.visible = true;
            //              return false;
            //          }, Priority.DEFAULT_IDLE);
            //      }
            //      return false;
            //  });

            app_menu.open_preferences_dialog.connect (open_preferences);
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
                    Application.arranger_core.metronome_player.play_loop (
                        Core.CentralBus.get_beats_per_bar (),
                        Core.CentralBus.get_quarter_notes_per_bar ()
                    );
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
                //  main_keyboard.set_note_on (key, on);
            });

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
                        Application.arranger_core.song_player_state_changed (
                            Application.arranger_core.song_player.name, Core.SongPlayer.PlayerStatus.READY
                        );
                    } else {
                        Application.arranger_core.song_player.play ();
                        Application.arranger_core.song_player_state_changed (
                            Application.arranger_core.song_player.name, Core.SongPlayer.PlayerStatus.PLAYING
                        );
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

        // Deallocate memory for some stuff
        public void app_exit (bool? force_close = false) {
            Idle.add (() => {
                debug ("App Exit Requested\n");
                debug ("Cleaning up Shell");
                debug ("CLEANUP: Unloading Registry Memory");
                registry_panel.unref ();
                debug ("CLEANUP: Unloading Slider Board");
                slider_board.unref ();
                debug ("CLEANUP: Unloading Mixer Board");
                mixer_board_view.stop_watch ();
                debug ("CLEANUP: Unloading On-screen Keyboard");
                main_keyboard.unref ();
                debug ("CLEANUP: Unloading Beat Counter");
                beat_counter_panel.unref ();

                Thread.usleep (10000);
                // Be sure to also run garbage collection on the core
                Application.arranger_core.garbage_collect ();
                if (force_close) {
                    Thread.usleep (10000);
                    Application.main_window.close ();
                }
                debug ("Exiting!\n");
                return false;
            });
        }

        public void update_header_bar (float fraction, int tempo_bpm, Core.SongPlayer.PlayerStatus status) {
            if (status == Core.SongPlayer.PlayerStatus.PLAYING || status == Core.SongPlayer.PlayerStatus.READY) {
                if (headerbar.title_widget == null) {
                    headerbar.set_title_widget (custom_title_grid);
                }
                seek_bar.set_value ((double) fraction);
            } else {
                headerbar.set_title_widget (null);
                seek_bar.set_value (0);
            }
            if (status == Core.SongPlayer.PlayerStatus.PLAYING) {
                song_control_panel.set_playing (true);
            } else {
                song_control_panel.set_playing (false);
            }
        }

        /* Used by MPRIS
         * This enables integration with audio indicator provided by the DE
         */
        public void media_toggle_play () {
            if (Application.arranger_core.song_player != null) {
                if (Application.arranger_core.song_player.get_status () == Core.SongPlayer.PlayerStatus.PLAYING) {
                    Application.arranger_core.song_player.pause ();
                    Application.arranger_core.song_player_state_changed (
                        Application.arranger_core.song_player.name, Core.SongPlayer.PlayerStatus.READY
                    );
                } else {
                    Application.arranger_core.song_player.play
                    ();
                    Application.arranger_core.song_player_state_changed (
                        Application.arranger_core.song_player.name, Core.SongPlayer.PlayerStatus.PLAYING
                    );
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
            //  dialog.close_request.connect (Gtk.main_quit);
            dialog.show ();
        }

        public void show_context_menu (Gtk.Widget? relative_to, int ui_control_index) {
            Gtk.Allocation relative_alloc;
            relative_to.get_allocation (out relative_alloc);
            common_context_menu.pointing_to = relative_alloc;
            controller_assign_button.clicked.disconnect (assign_button_handler);
            _current_ui_assign_index = ui_control_index;
            controller_assign_button.clicked.connect (assign_button_handler);
            common_context_menu.show ();
            var assignment_label = Application.arranger_core.midi_input_host.get_assignment_label (ui_control_index);
            if (assignment_label.length > 0) {
                controller_assignment_label.set_text (assignment_label);
                controller_assignment_label.visible = true;
                controller_reset_button.visible = true;
                ctx_menu_main_separator.visible = true;
            } else {
                controller_assignment_label.visible = false;
                controller_reset_button.visible = false;
                ctx_menu_main_separator.visible = false;
            }
            controller_assign_button.grab_focus ();
        }

        public void hide_context_menu () {
            common_context_menu.hide ();
        }

        void assign_button_handler () {
            hide_context_menu ();
            var assign_dialog = new Dialogs.MIDIAssignDialog (_current_ui_assign_index);
            assign_dialog.confirm_binding.connect (binding_confirmation_handler);
            assign_dialog.show ();
        }

        void binding_confirmation_handler (int channel, int identifier, int signal_type, int control_type) {
            Application.arranger_core.midi_input_host.set_control_map (channel, identifier, signal_type, control_type);
        }
    }
}
