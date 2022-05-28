/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class StyleControllerView : Gtk.Grid {
        public const int UI_INDEX_STYLE_INTRO_1 = 1;
        public const int UI_INDEX_STYLE_INTRO_2 = 2;
        public const int UI_INDEX_STYLE_VAR_A = 3;
        public const int UI_INDEX_STYLE_VAR_B = 4;
        public const int UI_INDEX_STYLE_VAR_C = 5;
        public const int UI_INDEX_STYLE_VAR_D = 6;
        public const int UI_INDEX_STYLE_BREAK = 7;
        public const int UI_INDEX_STYLE_ENDING_1 = 8;
        public const int UI_INDEX_STYLE_ENDING_2 = 9;
        public const int UI_INDEX_STYLE_SYNC_START = 10;
        public const int UI_INDEX_STYLE_SYNC_STOP = 11;
        public const int UI_INDEX_STYLE_START_STOP = 12;

        private Gtk.Button intro_button_a;
        private Gtk.Button intro_button_b;
        private Gtk.Button var_fill_button_a;
        private Gtk.Button var_fill_button_b;
        private Gtk.Button var_fill_button_c;
        private Gtk.Button var_fill_button_d;
        private Gtk.Button break_button;
        private Gtk.Button ending_button_a;
        private Gtk.Button ending_button_b;
        private Gtk.Button sync_start_button;
        private Gtk.Button sync_stop_button;
        private Gtk.Button start_button;

        construct {
            row_homogeneous = true;
            column_spacing = 4;
            margin = 4;

            var intro_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
                hexpand = true,
            };

            intro_button_a = new Gtk.Button.with_label ("1") {
                sensitive = false
            };

            intro_button_b = new Gtk.Button.with_label ("2") {
                sensitive = false
            };

            intro_box.add (intro_button_a);
            intro_box.add (intro_button_b);
            intro_box.set_layout (Gtk.ButtonBoxStyle.EXPAND);
            intro_button_a.clicked.connect (() => {
                send_to_recorder (UI_INDEX_STYLE_INTRO_1);
                set_style_section_by_index (UI_INDEX_STYLE_INTRO_1);
            });

            intro_button_a.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (intro_button_a, UI_INDEX_STYLE_INTRO_1);
                }
                return false;
            });

            intro_button_b.clicked.connect (() => {
                send_to_recorder (UI_INDEX_STYLE_INTRO_2);
                set_style_section_by_index (UI_INDEX_STYLE_INTRO_2);
            });

            intro_button_b.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (intro_button_b, UI_INDEX_STYLE_INTRO_2);
                }
                return false;
            });

            var var_fill_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
                hexpand = true
            };

            var_fill_button_a = new Gtk.Button.with_label ("A") {
                sensitive = false
            };

            var_fill_button_b = new Gtk.Button.with_label ("B") {
                sensitive = false
            };

            var_fill_button_c = new Gtk.Button.with_label ("C") {
                sensitive = false
            };

            var_fill_button_d = new Gtk.Button.with_label ("D") {
                sensitive = false
            };

            var_fill_box.add (var_fill_button_a);
            var_fill_box.add (var_fill_button_b);
            var_fill_box.add (var_fill_button_c);
            var_fill_box.add (var_fill_button_d);
            var_fill_box.set_layout (Gtk.ButtonBoxStyle.EXPAND);
            var_fill_button_a.clicked.connect (() => {
                send_to_recorder (UI_INDEX_STYLE_VAR_A);
                set_style_section_by_index (UI_INDEX_STYLE_VAR_A);
            });

            var_fill_button_a.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (var_fill_button_a, UI_INDEX_STYLE_VAR_A);
                }
                return false;
            });

            var_fill_button_b.clicked.connect (() => {
                send_to_recorder (UI_INDEX_STYLE_VAR_B);
                set_style_section_by_index (UI_INDEX_STYLE_VAR_B);
            });

            var_fill_button_b.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (var_fill_button_b, UI_INDEX_STYLE_VAR_B);
                }
                return false;
            });

            var_fill_button_c.clicked.connect (() => {
                send_to_recorder (UI_INDEX_STYLE_VAR_C);
                set_style_section_by_index (UI_INDEX_STYLE_VAR_C);
            });

            var_fill_button_c.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (var_fill_button_c, UI_INDEX_STYLE_VAR_C);
                }
                return false;
            });

            var_fill_button_d.clicked.connect (() => {
                send_to_recorder (UI_INDEX_STYLE_VAR_D);
                set_style_section_by_index (UI_INDEX_STYLE_VAR_D);
            });

            var_fill_button_d.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (var_fill_button_d, UI_INDEX_STYLE_VAR_D);
                }
                return false;
            });

            break_button = new Gtk.Button.with_label (_("Break")) {
                sensitive = false
            };

            break_button.clicked.connect (() => {
                send_to_recorder (UI_INDEX_STYLE_BREAK);
                set_style_section_by_index (UI_INDEX_STYLE_BREAK);
            });

            break_button.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (break_button, UI_INDEX_STYLE_BREAK);
                }
                return false;
            });

            var ending_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
                hexpand = true
            };

            ending_button_a = new Gtk.Button.with_label ("1") {
                sensitive = false
            };

            ending_button_b = new Gtk.Button.with_label ("2") {
                sensitive = false
            };

            ending_box.add (ending_button_a);
            ending_box.add (ending_button_b);
            ending_box.set_layout (Gtk.ButtonBoxStyle.EXPAND);
            ending_button_a.clicked.connect (() => {
                send_to_recorder (UI_INDEX_STYLE_ENDING_1);
                set_style_section_by_index (UI_INDEX_STYLE_ENDING_1);
            });

            ending_button_a.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (ending_button_a, UI_INDEX_STYLE_ENDING_1);
                }
                return false;
            });

            ending_button_b.clicked.connect (() => {
                send_to_recorder (UI_INDEX_STYLE_ENDING_2);
                set_style_section_by_index (UI_INDEX_STYLE_ENDING_2);
            });

            ending_button_b.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (ending_button_b, UI_INDEX_STYLE_ENDING_2);
                }
                return false;
            });

            var sync_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
                hexpand = true
            };

            sync_start_button = new Gtk.Button.with_label (_("Sync Start")) {
                sensitive = false
            };

            sync_stop_button = new Gtk.Button.with_label (_("Sync Stop")) {
                sensitive = false
            };

            sync_box.add (sync_start_button);
            sync_box.add (sync_stop_button);
            sync_box.set_layout (Gtk.ButtonBoxStyle.EXPAND);
            sync_start_button.clicked.connect (() => {
                send_to_recorder (UI_INDEX_STYLE_SYNC_START);
                set_style_section_by_index (UI_INDEX_STYLE_SYNC_START);
            });

            sync_start_button.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (sync_start_button, UI_INDEX_STYLE_SYNC_START);
                }
                return false;
            });

            sync_stop_button.clicked.connect (() => {
                send_to_recorder (UI_INDEX_STYLE_SYNC_STOP);
                set_style_section_by_index (UI_INDEX_STYLE_SYNC_STOP);
            });

            sync_stop_button.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (sync_stop_button, UI_INDEX_STYLE_SYNC_STOP);
                }
                return false;
            });

            start_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic") {
                sensitive = false,
                width_request = 64,
                hexpand = true
            };

            start_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            start_button.get_style_context ().remove_class ("image-button");
            start_button.clicked.connect (Application.arranger_core.style_player.play_style);

            start_button.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (start_button, UI_INDEX_STYLE_START_STOP);
                }
                return false;
            });

            var intro_label = new Gtk.Label ("       " + _("INTRO") + "       ") {
                opacity = 0.4
            };
            var var_label = new Gtk.Label ("       " + _("VARIATION / FILL-IN") + "       ") {
                opacity = 0.4
            };
            var ending_label = new Gtk.Label ("     " + _("ENDING") + "     ") {
                opacity = 0.4
            };

            attach (intro_box, 0, 0, 1, 1);
            attach (var_fill_box, 1, 0, 1, 1);
            attach (break_button, 2, 0, 1, 1);
            attach (ending_box, 3, 0, 1, 1);
            attach (sync_box, 4, 0, 1, 1);
            attach (start_button, 5, 0, 1, 1);
            attach (intro_label, 0, 1, 1, 1);
            attach (var_label, 1, 1, 1, 1);
            attach (ending_label, 3, 1, 1, 1);
        }

        public void ready (bool? ready = true) {
            intro_button_a.set_sensitive (ready);
            intro_button_b.set_sensitive (ready);
            var_fill_button_a.set_sensitive (ready);
            var_fill_button_b.set_sensitive (ready);
            var_fill_button_c.set_sensitive (ready);
            var_fill_button_d.set_sensitive (ready);
            ending_button_a.set_sensitive (ready);
            ending_button_b.set_sensitive (ready);
            sync_start_button.set_sensitive (ready);
            sync_stop_button.set_sensitive (ready);
            start_button.set_sensitive (ready);
            break_button.set_sensitive (ready);
        }

        public void sync () {
            intro_button_a.get_style_context ().remove_class ("queue-measure");
            intro_button_b.get_style_context ().remove_class ("queue-measure");
            var_fill_button_a.get_style_context ().remove_class ("queue-measure");
            var_fill_button_b.get_style_context ().remove_class ("queue-measure");
            var_fill_button_c.get_style_context ().remove_class ("queue-measure");
            var_fill_button_d.get_style_context ().remove_class ("queue-measure");
            ending_button_a.get_style_context ().remove_class ("queue-measure");
            ending_button_b.get_style_context ().remove_class ("queue-measure");
            sync_start_button.get_style_context ().remove_class ("queue-measure");
            sync_stop_button.get_style_context ().remove_class ("queue-measure");
        }

        public void set_style_section (int section) {
            sync ();
            switch (section) {
                case UI_INDEX_STYLE_INTRO_1:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case UI_INDEX_STYLE_INTRO_2:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case UI_INDEX_STYLE_VAR_A:
                var_fill_button_a.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case UI_INDEX_STYLE_VAR_B:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case UI_INDEX_STYLE_VAR_C:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case UI_INDEX_STYLE_VAR_D:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case UI_INDEX_STYLE_ENDING_1:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case UI_INDEX_STYLE_ENDING_2:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                default:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
            }
        }

        public void set_style_section_by_index (int index) {
            switch (index) {
                case UI_INDEX_STYLE_INTRO_1:
                Application.arranger_core.style_player.queue_intro_a ();
                intro_button_a.get_style_context ().add_class ("queue-measure");
                intro_button_b.get_style_context ().remove_class ("queue-measure");
                ending_button_a.get_style_context ().remove_class ("queue-measure");
                ending_button_b.get_style_context ().remove_class ("queue-measure");
                break;
                case UI_INDEX_STYLE_INTRO_2:
                Application.arranger_core.style_player.queue_intro_b ();
                intro_button_a.get_style_context ().remove_class ("queue-measure");
                intro_button_b.get_style_context ().add_class ("queue-measure");
                ending_button_a.get_style_context ().remove_class ("queue-measure");
                ending_button_b.get_style_context ().remove_class ("queue-measure");
                break;
                case UI_INDEX_STYLE_VAR_A:
                Application.arranger_core.style_player.switch_var_a ();
                var_fill_button_a.get_style_context ().add_class ("queue-measure");
                var_fill_button_b.get_style_context ().remove_class ("queue-measure");
                var_fill_button_c.get_style_context ().remove_class ("queue-measure");
                var_fill_button_d.get_style_context ().remove_class ("queue-measure");
                break;
                case UI_INDEX_STYLE_VAR_B:
                Application.arranger_core.style_player.switch_var_b ();
                var_fill_button_a.get_style_context ().remove_class ("queue-measure");
                var_fill_button_b.get_style_context ().add_class ("queue-measure");
                var_fill_button_c.get_style_context ().remove_class ("queue-measure");
                var_fill_button_d.get_style_context ().remove_class ("queue-measure");
                break;
                case UI_INDEX_STYLE_VAR_C:
                Application.arranger_core.style_player.switch_var_c ();
                var_fill_button_a.get_style_context ().remove_class ("queue-measure");
                var_fill_button_b.get_style_context ().remove_class ("queue-measure");
                var_fill_button_c.get_style_context ().add_class ("queue-measure");
                var_fill_button_d.get_style_context ().remove_class ("queue-measure");
                break;
                case UI_INDEX_STYLE_VAR_D:
                Application.arranger_core.style_player.switch_var_d ();
                var_fill_button_a.get_style_context ().remove_class ("queue-measure");
                var_fill_button_b.get_style_context ().remove_class ("queue-measure");
                var_fill_button_c.get_style_context ().remove_class ("queue-measure");
                var_fill_button_d.get_style_context ().add_class ("queue-measure");
                break;
                case UI_INDEX_STYLE_BREAK:
                Application.arranger_core.style_player.break_play ();
                break;
                case UI_INDEX_STYLE_ENDING_1:
                Application.arranger_core.style_player.queue_ending_a ();
                ending_button_a.get_style_context ().add_class ("queue-measure");
                ending_button_b.get_style_context ().remove_class ("queue-measure");
                intro_button_a.get_style_context ().remove_class ("queue-measure");
                intro_button_b.get_style_context ().remove_class ("queue-measure");
                break;
                case UI_INDEX_STYLE_ENDING_2:
                Application.arranger_core.style_player.queue_ending_b ();
                ending_button_a.get_style_context ().remove_class ("queue-measure");
                ending_button_b.get_style_context ().add_class ("queue-measure");
                intro_button_a.get_style_context ().remove_class ("queue-measure");
                intro_button_b.get_style_context ().remove_class ("queue-measure");
                break;
                case UI_INDEX_STYLE_SYNC_START:
                sync_start_button.get_style_context ().add_class ("queue-measure");
                Application.arranger_core.style_player.sync_start ();
                break;
                case UI_INDEX_STYLE_SYNC_STOP:
                sync_stop_button.get_style_context ().add_class ("queue-measure");
                Application.arranger_core.style_player.sync_stop ();
                break;
            }
        }

        public void handle_midi_button_event (int index, bool press = true) {
            if (press) {
                if (index == UI_INDEX_STYLE_START_STOP) {
                    Application.arranger_core.style_player.play_style ();
                } else {
                    send_to_recorder (index);
                    set_style_section_by_index (index);
                }
            }
        }

        private void send_to_recorder (int event_index) {
            if (RecorderScreen.sequencer != null) {
                RecorderScreen.sequencer.initial_settings_style_part_index = event_index;
            }

            if (RecorderScreen.sequencer != null &&
                RecorderScreen.sequencer.current_state != Core.MidiRecorder.RecorderState.PLAYING) {
                var event = new Core.MidiEvent ();
                event.event_type = Core.MidiEvent.EventType.STYLECONTROL;
                event.value1 = event_index;
                Shell.RecorderScreen.sequencer.record_event (event);
            }
        }
    }
}
