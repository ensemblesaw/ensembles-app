/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright © 2019 Alain M. (https://github.com/alainm23/planner)<alainmh23@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/*
 * This file is part of Ensembles
 */

namespace Ensembles.Core {
    /*
     * This is where all the core functionality of Ensembles resides
     * Everything responsible for making sounds, recording sounds
     * and manipulating sounds are here
     */
    public class ArrangerCore : Object {
        public Ensembles.Core.Voice[] detected_voices;
        public int[] detected_voice_indices;
        public Ensembles.Core.Synthesizer synthesizer;
        public Ensembles.Core.StylePlayer style_player;
        public Ensembles.Core.MetronomeLFOPlayer metronome_player;
        public Ensembles.Core.CentralBus bus;
        public Ensembles.Core.MidiInputHost midi_input_host;
        public Ensembles.Core.SongPlayer song_player;
        public Ensembles.Core.Arpeggiator arpeggiator;
        public Ensembles.Core.Harmonizer harmonizer;

        // Plugins System
        public PlugIns.PlugInManager plugin_manager;


        // Analysers
        VoiceAnalyser voice_analyser;
        StyleDiscovery style_discoverer;

        // Path constants
        /*
         * sf stands for SoundFont (Registered Trademark of Emu Systems)
         * sf_loc is location of the actual soundfont file which is also like the sound database
         * sf_schema_loc is the location for the csv file that specifies the categorization of the sounds
        */
        public string sf_loc = Constants.SF2DATADIR + "/EnsemblesGM.sf2";
        public string sf_schema_loc = Constants.SF2DATADIR + "/EnsemblesGMSchema.csv";
        // lfo stands for Low Frequency Oscillator
        public string metronome_lfo_directory = Constants.PKGDATADIR + "/MetronomesAndLFO";

        // Signals
        public signal void song_player_state_changed (string song_name, Core.SongPlayer.PlayerStatus status);

        construct {
            make_core_components ();
            make_bus_events ();
            make_other_core_events ();
        }

        void make_core_components () {
            Core.AudioDriverSniffer.check_drivers ();

            // Find out which driver was selected in user settings
            debug ("STARTUP: Initializing Settings");
            string driver_string = Core.AudioDriverSniffer.get_available_driver (
                Application.settings.get_string ("driver")
            );

            if (driver_string == "") {
                error ("FATAL: No compatible audio drivers found!");
            }

            // Load Central Bus
            // Central Bus is a set of variables (memory slots) that track the state of the synthesizer
            // It is accessible from various modules
            debug ("STARTUP: Loading Central Bus");
            bus = new Core.CentralBus ();

            // Start monitoring MIDI input streamfor devices
            debug ("STARTUP: Loading MIDI Input Monitor");
            midi_input_host = new Core.MidiInputHost ();

            // Initialise plugins
            debug ("STARTUP: Initializing Plugin System");
            plugin_manager = new PlugIns.PlugInManager ();

            // Load the main audio synthesizer
            debug ("STARTUP: Loading Synthesizer");
            synthesizer = new Core.Synthesizer (sf_loc,
                                                driver_string,
                                                Application.settings.get_double ("buffer-length"));

            // Load the style engine
            debug ("STARTUP: Loading Style Engine");
            style_player = new Core.StylePlayer ();

            // Load Metronome and LFO engine. Yes, Metronome and LFO are handled together!
            debug ("STARTUP: Loading Metronome and LFO Engine");
            metronome_player = new Core.MetronomeLFOPlayer (metronome_lfo_directory);

            // Load arpeggio and auto harmony modules
            arpeggiator = new Core.Arpeggiator ();
            harmonizer = new Core.Harmonizer ();

            // Create Analysers
            voice_analyser = new VoiceAnalyser ();
            style_discoverer = new StyleDiscovery ();
        }

        // Connect Central Bus events
        void make_bus_events () {
            bus.clock_tick.connect (() => {
                Idle.add (() => {
                    Application.main_window.beat_counter_panel.sync ();
                    Application.main_window.style_controller_view.sync ();
                    Application.main_window.main_display_unit.set_measure_display (
                        Ensembles.Core.CentralBus.get_measure ()
                    );
                    return false;
                });

                if (metronome_player.looping) metronome_player.stop_loop ();
                metronome_player.play_measure (
                    Core.CentralBus.get_beats_per_bar (),
                    Core.CentralBus.get_quarter_notes_per_bar ()
                );
            });
            bus.system_halt.connect (() => {
                Idle.add (() => {
                    //style_player.reload_style ();
                    Application.main_window.beat_counter_panel.halt ();
                    metronome_player.stop_loop ();
                    return false;
                });
            });
            bus.loaded_tempo_change.connect ((tempo) => {
                Application.main_window.beat_counter_panel.change_tempo (tempo);
                Application.main_window.main_display_unit.set_tempo_display (tempo);
                if (metronome_player != null)
                    metronome_player.set_tempo (tempo);
                if (arpeggiator != null)
                    arpeggiator.change_tempo (tempo);
                if (Shell.RecorderScreen.sequencer != null) {
                    Shell.RecorderScreen.sequencer.initial_settings_tempo = tempo;
                }
            });
            bus.loaded_time_signature_change.connect ((n, d) => {
                if (Application.main_window.beat_counter_panel != null) {
                    Application.main_window.beat_counter_panel.change_beats_per_bar (n);
                    Application.main_window.beat_counter_panel.change_qnotes_per_bar (d);
                    debug ("ts: %d\n", d);
                    Application.main_window.main_display_unit.update_time_signature (n, d);
                }
            });
            bus.split_key_change.connect (() => {
                Application.main_window.main_keyboard.update_split ();
            });
        }

        void make_other_core_events () {
            midi_input_host.receive_note_event.connect ((key, is_pressed, velocity, layer)=>{
                //  debug ("%d %d %d\n", key, is_pressed, velocity);
                if (Application.settings.get_boolean ("arpeggiator-on")) {
                    if (Application.settings.get_boolean ("accomp-on")) {
                        if (key > Core.CentralBus.get_split_key ()) {
                            arpeggiator.send_notes (key, is_pressed, velocity);
                        } else {
                            synthesizer.send_notes_realtime (key, is_pressed, velocity);
                        }
                    } else {
                        arpeggiator.send_notes (key, is_pressed, velocity);
                    }
                } else {
                    synthesizer.send_notes_realtime (key, is_pressed, velocity, layer + 17);
                }
                if (Application.settings.get_boolean ("harmonizer-on")) {
                    if (Application.settings.get_boolean ("accomp-on")) {
                        if (key > Core.CentralBus.get_split_key ()) {
                            harmonizer.send_notes (key, is_pressed, velocity);
                        } else {
                            synthesizer.send_notes_realtime (key, is_pressed, velocity);
                        }
                    } else {
                        synthesizer.send_notes_realtime (key, is_pressed, velocity);
                    }
                }
                Application.main_window.main_keyboard.set_note_on (key, is_pressed, Shell.Key.NoteType.NORMAL);
            });

            arpeggiator.generate_notes.connect ((key, on, velocity) => {
                if (Application.settings.get_boolean ("harmonizer-on")) {
                    if (Application.settings.get_boolean ("accomp-on")) {
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
            harmonizer.halt_notes.connect (() => {
                Application.main_window.main_keyboard.halt_all ();
                synthesizer.halt_realtime (true);
            });

            synthesizer.detected_chord.connect ((chord, type) => {
                style_player.change_chords (chord, type);
                Application.main_window.main_display_unit.set_chord_display (chord, type);
                harmonizer.set_chord (chord, type);
            });

            metronome_player.beat_sync.connect (() => {
                Application.main_window.beat_counter_panel.sync ();
            });

            voice_analyser.analysis_complete.connect (() => {
                detected_voices = voice_analyser.get_all_voices ();
                detected_voice_indices = voice_analyser.get_all_category_indices ();
                Idle.add (() => {
                    Application.main_window.main_display_unit.update_voice_list (detected_voices);
                    return false;
                });
            });

            style_discoverer.analysis_complete.connect (() => {
                Idle.add (() =>{
                    Application.main_window.main_display_unit.update_style_list (style_discoverer.styles);
                    return false;
                });
            });
        }

        public void garbage_collect () {
            Idle.add (() => {
                debug ("Cleaning up Core");
                debug ("CLEANUP: Unloading MIDI Input Monitor");
                midi_input_host.destroy ();
                Thread.usleep (5000);
                debug ("CLEANUP: Unloading Metronome and LFO Engine");
                metronome_player.unref ();
                debug ("CLEANUP: Unloading Style Engine");
                style_player.unref ();
                if (song_player != null) {
                    debug ("CLEANUP: Unloading Song Player");
                    song_player.songplayer_destroy ();
                    song_player = null;
                }
                Thread.usleep (5000);
                debug ("CLEANUP: Unloading Central Bus");
                bus.unref ();
                Thread.usleep (5000);
                debug ("CLEANUP: Unloading Synthesizer");
                synthesizer.synthesizer_deinit ();

                return false;
            });
        }

        public void load_data () {
            Thread.usleep (500000);
            // Load Voices
            debug ("LOADING DATA: Voices");
            voice_analyser.analyse (sf_loc, sf_schema_loc);

            // Load Plug-ins
            debug ("LOADING DATA: Plug-ins");
            plugin_manager.discover ();
            Application.main_window.main_display_unit.update_effect_list ();

            // Load Styles
            // Start looking for styles in the app data folder and user styles folder
            debug ("LOADING DATA: Styles");
            style_discoverer.load_styles ();

            Idle.add (() => {
                Application.main_window.main_display_unit.queue_remove_splash ();
                Application.main_window.style_controller_view.ready ();
                Application.main_window.ctrl_panel.load_settings ();
                return false;
            });
            if (Application.main_window != null) {
                Application.main_window.main_display_unit.update_splash_text (_("Initialize…"));
            }
            debug ("System Ready\n");
            Timeout.add (3000, () => {
                if (song_player != null) {
                    song_player.play ();
                }
                return false;
            });
        }

        public void open_file (File file) {
            string path = file.get_path ();
            queue_song (path);
        }

        public void queue_song (string path) {
            string song_name = "Unknown";
            try {
                Regex regex = new Regex ("[ \\w-]+?(?=\\.)");
                MatchInfo match_info;
                if (regex.match (path, 0, out match_info)) {
                    song_name = match_info.fetch (0);
                }
            } catch (RegexError e) {
                warning (e.message);
            }

            if (song_player != null) {
                song_player.player_status_changed.disconnect (Application.main_window.update_header_bar);
                song_player.songplayer_destroy ();
                song_player = null;
            }
            debug ("Creating new Song Player instance with midi file: %s", path);
            song_player = new Core.SongPlayer (sf_loc, path, song_name);
            song_player.player_status_changed.connect (Application.main_window.update_header_bar);
            int song_tempo = song_player.current_file_tempo;
            style_player.change_tempo (song_tempo);
            Application.main_window.main_display_unit.set_tempo_display (song_tempo);
            if (Shell.RecorderScreen.sequencer != null) {
                Shell.RecorderScreen.sequencer.initial_settings_tempo = song_tempo;
            }
            Application.main_window.custom_title_text.set_text (_("Now Playing - %s").printf (song_name));
            Application.main_window.song_control_panel.set_player_active ();
            song_player_state_changed (song_name, Core.SongPlayer.PlayerStatus.READY);
        }
    }
}
