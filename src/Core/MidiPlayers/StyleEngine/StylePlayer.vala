/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


namespace Ensembles.Core {
    public class StylePlayer : Object {
        static int style_part;

        public StylePlayer (string? style_file = null) {
            style_player_init ();
            if (style_file != null) {
                style_player_add_style_file (style_file, 0);
            }

            set_style_change_callback ((state) => {
                if (Shell.RecorderScreen.sequencer != null &&
                    Shell.RecorderScreen.sequencer.current_state != MidiRecorder.RecorderState.PLAYING) {
                    var part_event = new MidiEvent ();
                    part_event.event_type = MidiEvent.EventType.STYLECONTROL;
                    part_event.value1 = style_part;

                    var event = new Core.MidiEvent ();
                    event.event_type = Core.MidiEvent.EventType.STYLESTARTSTOP;
                    event.value1 = state;

                    Shell.RecorderScreen.sequencer.record_event (part_event);

                    Shell.RecorderScreen.sequencer.record_event (event);
                }
                print ("Style State: %d\n", state);
            });

            set_style_part_change_callback ((part) => {
                switch (part) {
                    case 1:
                    Application.main_window.style_controller_view.set_style_section (
                        Shell.StyleControllerView.UI_INDEX_STYLE_INTRO_1
                    );
                    break;
                    case 2:
                    Application.main_window.style_controller_view.set_style_section (
                        Shell.StyleControllerView.UI_INDEX_STYLE_INTRO_2
                    );
                    break;
                    case 3:
                    Application.main_window.style_controller_view.set_style_section (
                        Shell.StyleControllerView.UI_INDEX_STYLE_VAR_A
                    );
                    break;
                    case 5:
                    Application.main_window.style_controller_view.set_style_section (
                        Shell.StyleControllerView.UI_INDEX_STYLE_VAR_B
                    );
                    break;
                    case 7:
                    Application.main_window.style_controller_view.set_style_section (
                        Shell.StyleControllerView.UI_INDEX_STYLE_VAR_C
                    );
                    break;
                    case 9:
                    Application.main_window.style_controller_view.set_style_section (
                        Shell.StyleControllerView.UI_INDEX_STYLE_VAR_D
                    );
                    break;
                    case 11:
                    Application.main_window.style_controller_view.set_style_section (
                        Shell.StyleControllerView.UI_INDEX_STYLE_ENDING_1
                    );
                    break;
                    case 13:
                    Application.main_window.style_controller_view.set_style_section (
                        Shell.StyleControllerView.UI_INDEX_STYLE_ENDING_2
                    );
                    break;
                    default:
                    Application.main_window.style_controller_view.set_style_section (
                        0
                    );
                    break;
                }
                if (Shell.RecorderScreen.sequencer != null &&
                    Shell.RecorderScreen.sequencer.current_state == MidiRecorder.RecorderState.RECORDING) {
                    var style_part_actual_event = new Core.MidiEvent ();
                    style_part_actual_event.event_type = Core.MidiEvent.EventType.STYLECONTROLACTUAL;
                    style_part_actual_event.value1 = part;

                    Shell.RecorderScreen.sequencer.record_event (style_part_actual_event);
                }
            });
        }
        ~StylePlayer () {
           style_player_destruct ();
        }

        string file_path;
        int tempo;

        public void add_style_file (string style_file, int tempo) {
            debug ("loading style %s\n", style_file);
            if (file_path != style_file || tempo != this.tempo) {
                file_path = style_file;
                this.tempo = tempo;
                if (Core.CentralBus.get_style_looping_on ()) {
                    sync_stop ();
                    Timeout.add (10, () => {
                        if (!Core.CentralBus.get_style_looping_on ()) {
                            int previous_tempo = Core.CentralBus.get_tempo ();
                            style_player_add_style_file (style_file, previous_tempo);
                            Idle.add (() => {
                                play_style ();
                                return false;
                            });
                        }
                        return Core.CentralBus.get_style_looping_on ();
                    });
                } else {
                    style_player_add_style_file (style_file, tempo);
                }
            }
        }

        public void reload_style () {
            style_player_reload_style ();
        }

        public void play_style () {
            style_player_toggle_play ();
        }

        public void stop_style () {
            style_player_stop ();
        }

        public void switch_var_a () {
            style_player_play_loop (3, 4);
            style_part = Shell.StyleControllerView.UI_INDEX_STYLE_VAR_A;
        }

        public void switch_var_b () {
            style_player_play_loop (5, 6);
            style_part = Shell.StyleControllerView.UI_INDEX_STYLE_VAR_B;
        }

        public void switch_var_c () {
            style_player_play_loop (7, 8);
            style_part = Shell.StyleControllerView.UI_INDEX_STYLE_VAR_C;
        }

        public void switch_var_d () {
            style_player_play_loop (9, 10);
            style_part = Shell.StyleControllerView.UI_INDEX_STYLE_VAR_D;
        }

        public void queue_intro_a () {
            style_player_queue_intro (1, 2);
            style_part = Shell.StyleControllerView.UI_INDEX_STYLE_INTRO_1;
        }

        public void queue_intro_b () {
            style_player_queue_intro (2, 3);
            style_part = Shell.StyleControllerView.UI_INDEX_STYLE_INTRO_2;
        }

        public void queue_ending_a () {
            style_player_queue_ending (11, 12);
            style_part = Shell.StyleControllerView.UI_INDEX_STYLE_ENDING_1;
        }

        public void queue_ending_b () {
            style_player_queue_ending (13, 14);
            style_part = Shell.StyleControllerView.UI_INDEX_STYLE_ENDING_2;
        }

        public void break_play () {
            style_player_break ();
            style_part = Shell.StyleControllerView.UI_INDEX_STYLE_BREAK;
        }

        public void sync_start () {
            style_player_sync_start ();
        }
        public void sync_stop () {
            style_player_sync_stop ();
        }

        public void change_chords (int chord_main, int chord_type) {
            style_player_change_chord (chord_main, chord_type);
        }

        public void change_tempo (int tempo) {
            style_player_set_tempo (tempo);
        }
    }
}

extern void style_player_init ();
extern void style_player_add_style_file (string mid_file, int custom_tempo);
extern void style_player_reload_style ();
extern void style_player_destruct ();
extern void style_player_toggle_play ();
extern void style_player_stop ();
extern void style_player_play_loop (int start, int end);
extern void style_player_queue_intro (int start, int end);
extern void style_player_queue_ending (int start, int end);
extern void style_player_break ();
extern void style_player_sync_start ();
extern void style_player_sync_stop ();
extern void style_player_set_tempo (int tempo_bpm);

extern void style_player_change_chord (int cd_main, int cd_type);

[CCode (cname = "style_player_change_state", has_target = false)]
extern delegate void style_player_change_state_callback (int started);
[CCode (has_target = false)]
extern void set_style_change_callback (style_player_change_state_callback function);

[CCode (cname = "style_player_change_part", has_target = false)]
extern delegate void style_player_change_part_callback (int started);
[CCode (has_target = false)]
extern void set_style_part_change_callback (style_player_change_part_callback function);
