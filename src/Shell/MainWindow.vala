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
        MultipadView multipad_panel;
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

        string sf_loc = Constants.SF2DATADIR + "/EnsemblesGM.sf2";
        string sf_schema_loc = Constants.SF2DATADIR + "/EnsemblesGMSchema.csv";
        string metronome_lfo_directory = Constants.PKGDATADIR + "/MetronomesAndLFO";
        public MainWindow () {
            Gtk.Settings settings = Gtk.Settings.get_default ();
            settings.gtk_application_prefer_dark_theme = true;
            bus = new Ensembles.Core.CentralBus ();
            make_bus_events ();

            beat_counter_panel = new BeatCounterView ();
            var headerbar = new Gtk.HeaderBar ();
            headerbar.has_subtitle = false;
            headerbar.set_show_close_button (true);
            headerbar.title = "Ensembles";
            headerbar.pack_start (beat_counter_panel);

            Gtk.Button app_menu_button = new Gtk.Button.from_icon_name ("preferences-system-symbolic",
                                                                        Gtk.IconSize.BUTTON);
            headerbar.pack_end (app_menu_button);
            this.set_titlebar (headerbar);

            app_menu = new AppMenuView (app_menu_button);

            app_menu_button.clicked.connect (() => {
                app_menu.popup ();
            });

            song_control_panel = new SongControllerView ();
            headerbar.pack_end (song_control_panel);

            main_display_unit = new MainDisplayCasing ();

            ctrl_panel = new ControlPanel ();

            slider_board = new SliderBoardView ();

            voice_category_panel = new VoiceCategoryView ();

            mixer_board_view = new MixerBoardView ();

            multipad_panel = new MultipadView ();

            registry_panel = new RegistryView ();

            style_controller_view = new StyleControllerView ();

            main_keyboard = new KeyboardView ();

            var style_registry_grid = new Gtk.Grid ();
            style_registry_grid.attach (style_controller_view, 0, 0, 1, 1);
            style_registry_grid.attach (registry_panel, 1, 0, 1, 1);

            var grid = new Gtk.Grid ();
            grid.attach (slider_board, 0, 0, 1, 1);
            grid.attach (main_display_unit, 1, 0, 1, 1);
            grid.attach (ctrl_panel, 2, 0, 1, 1);
            grid.attach (voice_category_panel, 0, 1, 1, 1);
            grid.attach (mixer_board_view, 1, 1, 1, 1);
            grid.attach (multipad_panel, 2, 1, 1, 1);
            grid.attach (style_registry_grid, 0, 2, 3, 1);
            grid.attach (main_keyboard, 0, 3, 3, 1);
            this.add (grid);
            this.show_all ();

            controller_connection = new Ensembles.Core.Controller ();
            app_menu.change_enable_midi_input.connect ((enable) => {
                if (enable) {
                    var devices_found = controller_connection.get_device_list ();
                    app_menu.update_devices (devices_found);
                }
            });
            synthesizer = new Ensembles.Core.Synthesizer (sf_loc);
            main_keyboard.connect_synthesizer (synthesizer);
            style_player = new Ensembles.Core.StylePlayer ();

            style_discovery = new Ensembles.Core.StyleDiscovery ();
            style_discovery.analysis_complete.connect (() => {
                style_player.add_style_file (style_discovery.style_files.nth_data (0));
                main_display_unit.update_style_list (
                    style_discovery.style_files,
                    style_discovery.style_names,
                    style_discovery.style_genre,
                    style_discovery.style_tempo
                );
            });

            metronome_player = new Ensembles.Core.MetronomeLFOPlayer (metronome_lfo_directory);

            make_ui_events ();

            load_voices ();
        }
        void make_bus_events () {
            bus.clock_tick.connect (() => {
                beat_counter_panel.sync ();
                style_controller_view.sync ();
                main_display_unit.set_measure_display (Ensembles.Core.CentralBus.get_measure ());
                if (metronome_player.looping) metronome_player.stop_loop ();
                metronome_player.play_measure (4, 4);
            });
            bus.system_halt.connect (() => {
                style_player.reload_style ();
                beat_counter_panel.halt ();
                metronome_player.stop_loop ();
            });
            bus.system_ready.connect (() => {
                main_display_unit.queue_remove_splash ();
                style_controller_view.ready ();
            });
            bus.style_section_change.connect ((section) => {
                style_controller_view.set_style_section (section);
            });
            bus.loaded_tempo_change.connect ((tempo) => {
                beat_counter_panel.change_tempo (tempo);
                main_display_unit.set_tempo_display (tempo);
                if (metronome_player != null)
                    metronome_player.set_tempo (tempo);
            });
            bus.split_key_change.connect (() => {
                main_keyboard.update_split ();
            });
        }
        void make_ui_events () {
            this.window_state_event.connect ((event) => {
                if (event.type == Gdk.EventType.WINDOW_STATE) {
                    main_keyboard.visible = false;
                    Timeout.add (100, () => {
                        main_keyboard.visible = true;
                        return false;
                    }, Priority.DEFAULT_IDLE);
                }
                return false;
            });
            app_menu.change_active_input_device.connect ((device) => {
                //  print("%d %s\n", device.id, device.name);
                controller_connection.connect_device (device.id);
            });
            main_display_unit.change_style.connect ((path, name, tempo) => {
                style_player.add_style_file (path);
            });
            main_display_unit.change_voice.connect ((voice, channel) => {
                synthesizer.change_voice (voice, channel);
            });
            ctrl_panel.accomp_change.connect ((active) => {
                synthesizer.set_accompaniment_on (active);
            });
            ctrl_panel.reverb_change.connect ((level) => {
                synthesizer.set_master_reverb_level (level);
            });
            ctrl_panel.chorus_change.connect ((level) => {
                synthesizer.set_master_chorus_level (level);
            });
            ctrl_panel.update_split.connect (() => {
                main_keyboard.update_split ();
            });
            ctrl_panel.start_metronome.connect ((active) => {
                if (active) {
                    Ensembles.Core.CentralBus.set_metronome_on (true);
                    metronome_player.play_loop (4, 4);
                } else {
                    metronome_player.stop_loop ();
                    Ensembles.Core.CentralBus.set_metronome_on (false);
                }
            });
            controller_connection.receive_note_event.connect ((key, on, velocity)=>{
                //  print ("%d %d %d\n", key, on, velocity);
                synthesizer.send_notes_realtime (key, on, velocity);
                main_keyboard.set_note_on (key, (on == 144));
            });
            style_controller_view.start_stop.connect (() => {
                style_player.play_style ();
            });

            style_controller_view.switch_var_a.connect (() => {
                style_player.switch_var_a ();
            });

            style_controller_view.switch_var_b.connect (() => {
                style_player.switch_var_b ();
            });

            style_controller_view.switch_var_c.connect (() => {
                style_player.switch_var_c ();
            });

            style_controller_view.switch_var_d.connect (() => {
                style_player.switch_var_d ();
            });

            style_controller_view.queue_intro_a.connect (() => {
                style_player.queue_intro_a ();
            });

            style_controller_view.queue_intro_b.connect (() => {
                style_player.queue_intro_b ();
            });

            style_controller_view.queue_ending_a.connect (() => {
                style_player.queue_ending_a ();
            });

            style_controller_view.queue_ending_b.connect (() => {
                style_player.queue_ending_b ();
            });

            style_controller_view.break_play.connect (() => {
                style_player.break_play ();
            });

            style_controller_view.sync_start.connect (() => {
                style_player.sync_start ();
            });

            style_controller_view.sync_stop.connect (() => {
                style_player.sync_stop ();
            });
            synthesizer.detected_chord.connect ((chord, type) => {
                style_player.change_chords (chord, type);
                main_display_unit.set_chord_display (chord, type);
            });
            voice_category_panel.voice_quick_select.connect ((index) => {
                main_display_unit.quick_select_voice (detected_voice_indices[index]);
            });
            main_display_unit.channel_mod_screen.broadcast_assignment.connect (slider_board.send_modulator);
            slider_board.send_assignable_mode.connect (main_display_unit.channel_mod_screen.set_assignable);
            slider_board.open_LFO_editor.connect (main_display_unit.open_lfo_screen);
            metronome_player.beat_sync.connect (() => {
                beat_counter_panel.sync ();
            });
            this.destroy.connect (() => {
                slider_board.stop_monitoring ();
            });
            print ("Initialized\n");
        }

        void load_voices () {
            var voice_analyser = new Ensembles.Core.VoiceAnalyser (sf_loc, sf_schema_loc);
            detected_voices = voice_analyser.get_all_voices ();
            detected_voice_indices = voice_analyser.get_all_category_indices ();
            main_display_unit.update_voice_list (detected_voices);
        }
    }
}
