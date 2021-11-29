/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class StyleControllerView : Gtk.Grid {
        Gtk.Button intro_button_a;
        Gtk.Button intro_button_b;
        Gtk.Button var_fill_button_a;
        Gtk.Button var_fill_button_b;
        Gtk.Button var_fill_button_c;
        Gtk.Button var_fill_button_d;
        Gtk.Button break_button;
        Gtk.Button ending_button_a;
        Gtk.Button ending_button_b;
        Gtk.Button sync_start_button;
        Gtk.Button sync_stop_button;
        Gtk.Button start_button;

        public signal void start_stop ();

        public signal void switch_var_a ();
        public signal void switch_var_b ();
        public signal void switch_var_c ();
        public signal void switch_var_d ();

        public signal void queue_intro_a ();
        public signal void queue_intro_b ();

        public signal void queue_ending_a ();
        public signal void queue_ending_b ();

        public signal void break_play ();

        public signal void sync_stop ();
        public signal void sync_start ();

        public StyleControllerView () {
            row_homogeneous = true;
            vexpand = true;
            var intro_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
                expand = true
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
                if (RecorderScreen.sequencer != null) {
                    RecorderScreen.sequencer.initial_settings_style_part_index = 0;
                }
                if (RecorderScreen.sequencer != null && RecorderScreen.sequencer.current_state != Core.MidiRecorder.RecorderState.PLAYING) {
                    var event = new Core.MidiEvent ();
                    event.event_type = Core.MidiEvent.EventType.STYLECONTROL;
                    event.value1 = 0;
                    Shell.RecorderScreen.sequencer.record_event (event);
                }
                set_style_section_by_index (0);
            });
            intro_button_b.clicked.connect (() => {
                if (RecorderScreen.sequencer != null) {
                    RecorderScreen.sequencer.initial_settings_style_part_index = 1;
                }
                if (RecorderScreen.sequencer != null && RecorderScreen.sequencer.current_state != Core.MidiRecorder.RecorderState.PLAYING) {
                    var event = new Core.MidiEvent ();
                    event.event_type = Core.MidiEvent.EventType.STYLECONTROL;
                    event.value1 = 1;
                    Shell.RecorderScreen.sequencer.record_event (event);
                }
                set_style_section_by_index (1);
            });

            var var_fill_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            var_fill_box.hexpand = true;
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
                if (RecorderScreen.sequencer != null) {
                    RecorderScreen.sequencer.initial_settings_style_part_index = 2;
                }
                if (RecorderScreen.sequencer != null && RecorderScreen.sequencer.current_state != Core.MidiRecorder.RecorderState.PLAYING) {
                    var event = new Core.MidiEvent ();
                    event.event_type = Core.MidiEvent.EventType.STYLECONTROL;
                    event.value1 = 2;
                    Shell.RecorderScreen.sequencer.record_event (event);
                }
                set_style_section_by_index (2);
            });

            var_fill_button_b.clicked.connect (() => {
                if (RecorderScreen.sequencer != null) {
                    RecorderScreen.sequencer.initial_settings_style_part_index = 3;
                }
                if (RecorderScreen.sequencer != null && RecorderScreen.sequencer.current_state != Core.MidiRecorder.RecorderState.PLAYING) {
                    var event = new Core.MidiEvent ();
                    event.event_type = Core.MidiEvent.EventType.STYLECONTROL;
                    event.value1 = 3;
                    Shell.RecorderScreen.sequencer.record_event (event);
                }
                set_style_section_by_index (3);
            });

            var_fill_button_c.clicked.connect (() => {
                if (RecorderScreen.sequencer != null) {
                    RecorderScreen.sequencer.initial_settings_style_part_index = 4;
                }
                if (RecorderScreen.sequencer != null && RecorderScreen.sequencer.current_state != Core.MidiRecorder.RecorderState.PLAYING) {
                    var event = new Core.MidiEvent ();
                    event.event_type = Core.MidiEvent.EventType.STYLECONTROL;
                    event.value1 = 4;
                    Shell.RecorderScreen.sequencer.record_event (event);
                }
                set_style_section_by_index (4);
            });

            var_fill_button_d.clicked.connect (() => {
                if (RecorderScreen.sequencer != null) {
                    RecorderScreen.sequencer.initial_settings_style_part_index = 5;
                }
                if (RecorderScreen.sequencer != null && RecorderScreen.sequencer.current_state != Core.MidiRecorder.RecorderState.PLAYING) {
                    var event = new Core.MidiEvent ();
                    event.event_type = Core.MidiEvent.EventType.STYLECONTROL;
                    event.value1 = 5;
                    Shell.RecorderScreen.sequencer.record_event (event);
                }
                set_style_section_by_index (5);
            });

            break_button = new Gtk.Button.with_label (_("Break")) {
                sensitive = false
            };
            break_button.clicked.connect (() => {
                if (RecorderScreen.sequencer != null) {
                    RecorderScreen.sequencer.initial_settings_style_part_index = 6;
                }
                if (RecorderScreen.sequencer != null && RecorderScreen.sequencer.current_state != Core.MidiRecorder.RecorderState.PLAYING) {
                    var event = new Core.MidiEvent ();
                    event.event_type = Core.MidiEvent.EventType.STYLECONTROL;
                    event.value1 = 6;
                    Shell.RecorderScreen.sequencer.record_event (event);
                }
                set_style_section_by_index (6);
            });

            var ending_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            ending_box.hexpand = true;
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
                if (RecorderScreen.sequencer != null) {
                    RecorderScreen.sequencer.initial_settings_style_part_index = 7;
                }
                if (RecorderScreen.sequencer != null && RecorderScreen.sequencer.current_state != Core.MidiRecorder.RecorderState.PLAYING) {
                    var event = new Core.MidiEvent ();
                    event.event_type = Core.MidiEvent.EventType.STYLECONTROL;
                    event.value1 = 7;
                    Shell.RecorderScreen.sequencer.record_event (event);
                }
                set_style_section_by_index (7);
            });
            ending_button_b.clicked.connect (() => {
                if (RecorderScreen.sequencer != null) {
                    RecorderScreen.sequencer.initial_settings_style_part_index = 8;
                }
                if (RecorderScreen.sequencer != null && RecorderScreen.sequencer.current_state != Core.MidiRecorder.RecorderState.PLAYING) {
                    var event = new Core.MidiEvent ();
                    event.event_type = Core.MidiEvent.EventType.STYLECONTROL;
                    event.value1 = 8;
                    Shell.RecorderScreen.sequencer.record_event (event);
                }
                set_style_section_by_index (8);
            });

            var sync_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            sync_box.hexpand = true;
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
                if (RecorderScreen.sequencer != null) {
                    RecorderScreen.sequencer.initial_settings_style_part_index = 9;
                }
                if (RecorderScreen.sequencer != null && RecorderScreen.sequencer.current_state != Core.MidiRecorder.RecorderState.PLAYING) {
                    var event = new Core.MidiEvent ();
                    event.event_type = Core.MidiEvent.EventType.STYLECONTROL;
                    event.value1 = 9;
                    Shell.RecorderScreen.sequencer.record_event (event);
                }
                set_style_section_by_index (9);
            });
            sync_stop_button.clicked.connect (() => {
                if (RecorderScreen.sequencer != null) {
                    RecorderScreen.sequencer.initial_settings_style_part_index = 10;
                }
                if (RecorderScreen.sequencer != null && RecorderScreen.sequencer.current_state != Core.MidiRecorder.RecorderState.PLAYING) {
                    var event = new Core.MidiEvent ();
                    event.event_type = Core.MidiEvent.EventType.STYLECONTROL;
                    event.value1 = 10;
                    Shell.RecorderScreen.sequencer.record_event (event);
                }
                set_style_section_by_index (10);
            });

            start_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic") {
                sensitive = false,
                width_request = 64,
                hexpand = true
            };
            start_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            start_button.get_style_context ().remove_class ("image-button");
            start_button.clicked.connect (() => {
                start_stop ();
            });

            var intro_label = new Gtk.Label ("       " + _("INTRO") + "       ");
            intro_label.set_opacity (0.4);
            var var_label = new Gtk.Label ("       " + _("VARIATION / FILL-IN") + "       ");
            var_label.set_opacity (0.4);
            var ending_label = new Gtk.Label ("     " + _("ENDING") + "     ");
            ending_label.set_opacity (0.4);

            attach (intro_box, 0, 0, 1, 1);
            attach (var_fill_box, 1, 0, 1, 1);
            attach (break_button, 2, 0, 1, 1);
            attach (ending_box, 3, 0, 1, 1);
            attach (sync_box, 4, 0, 1, 1);
            attach (start_button, 5, 0, 1, 1);
            attach (intro_label, 0, 1, 1, 1);
            attach (var_label, 1, 1, 1, 1);
            attach (ending_label, 3, 1, 1, 1);
            column_spacing = 4;
            margin = 4;
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
                case 0:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case 1:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case 2:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case 3:
                var_fill_button_a.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case 5:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case 7:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case 9:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case 11:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case 13:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
            }
        }

        public void set_style_section_by_index (int index) {
            switch (index) {
                case 0:
                queue_intro_a ();
                intro_button_a.get_style_context ().add_class ("queue-measure");
                intro_button_b.get_style_context ().remove_class ("queue-measure");
                ending_button_a.get_style_context ().remove_class ("queue-measure");
                ending_button_b.get_style_context ().remove_class ("queue-measure");

                break;
                case 1:
                queue_intro_b ();
                intro_button_a.get_style_context ().remove_class ("queue-measure");
                intro_button_b.get_style_context ().add_class ("queue-measure");
                ending_button_a.get_style_context ().remove_class ("queue-measure");
                ending_button_b.get_style_context ().remove_class ("queue-measure");
                break;
                case 2:
                switch_var_a ();
                var_fill_button_a.get_style_context ().add_class ("queue-measure");
                var_fill_button_b.get_style_context ().remove_class ("queue-measure");
                var_fill_button_c.get_style_context ().remove_class ("queue-measure");
                var_fill_button_d.get_style_context ().remove_class ("queue-measure");
                break;
                case 3:
                switch_var_b ();
                var_fill_button_a.get_style_context ().remove_class ("queue-measure");
                var_fill_button_b.get_style_context ().add_class ("queue-measure");
                var_fill_button_c.get_style_context ().remove_class ("queue-measure");
                var_fill_button_d.get_style_context ().remove_class ("queue-measure");
                break;
                case 4:
                switch_var_c ();
                var_fill_button_a.get_style_context ().remove_class ("queue-measure");
                var_fill_button_b.get_style_context ().remove_class ("queue-measure");
                var_fill_button_c.get_style_context ().add_class ("queue-measure");
                var_fill_button_d.get_style_context ().remove_class ("queue-measure");
                break;
                case 5:
                switch_var_d ();
                var_fill_button_a.get_style_context ().remove_class ("queue-measure");
                var_fill_button_b.get_style_context ().remove_class ("queue-measure");
                var_fill_button_c.get_style_context ().remove_class ("queue-measure");
                var_fill_button_d.get_style_context ().add_class ("queue-measure");
                break;
                case 6:
                break_play ();
                break;
                case 7:
                queue_ending_a ();
                ending_button_a.get_style_context ().add_class ("queue-measure");
                ending_button_b.get_style_context ().remove_class ("queue-measure");
                intro_button_a.get_style_context ().remove_class ("queue-measure");
                intro_button_b.get_style_context ().remove_class ("queue-measure");
                break;
                case 8:
                queue_ending_b ();
                ending_button_a.get_style_context ().remove_class ("queue-measure");
                ending_button_b.get_style_context ().add_class ("queue-measure");
                intro_button_a.get_style_context ().remove_class ("queue-measure");
                intro_button_b.get_style_context ().remove_class ("queue-measure");
                break;
                case 9:
                sync_start_button.get_style_context ().add_class ("queue-measure");
                sync_start ();
                break;
                case 10:
                sync_stop_button.get_style_context ().add_class ("queue-measure");
                sync_stop ();
                break;
            }
        }
    }
}
