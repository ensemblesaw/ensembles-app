/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core {
    public class MidiRecorder : Object {
        public enum RecorderState {
            RECORDING,
            PLAYING,
            STOPPED
        }

        private string _name;
        private string _file_path;
        private uint8 _track;
        private Gtk.ListBox _sequencer_visual;
        private Gtk.Overlay _sequencer_progress_overlay;
        private Gtk.Box _sequencer_progress;



        private List<MidiEvent>[] midi_event_sequence;
        private PlayBackObject[] playback_objects;
        private Shell.RecorderTrackItem[] track_visuals;
        public bool[] mute_array;

        private Thread<void> play_thread;
        private Thread<void> rcrd_thread;

        private Timer recording_timer;
        private Timer progress_timer;
        private double total_width;

        public RecorderState current_state;
        bool sync_start;

        // Initial Settings;
        public int initial_settings_style_part_index = 2;
        public int initial_settings_tempo = 120;


        // Midi Event Connectors
        public signal void project_name_change (string name);
        public signal void progress_change (double progress);
        public signal void recorder_state_change (RecorderState state);
        public signal void set_ui_sensitive (bool sensitive);

        public void multiplex_events (MidiEvent event) {
            switch (event.event_type) {
                case MidiEvent.EventType.NOTE:
                Application.arranger_core.synthesizer.send_notes_realtime (event.value1, event.value2, event.velocity, event.channel);
                break;
                case MidiEvent.EventType.VOICECHANGE:
                var voice = new Voice (event.value2, event.value1, event.value2, "", "");
                Application.arranger_core.synthesizer.change_voice (voice, event.channel);
                break;
                case MidiEvent.EventType.STYLECHANGE:
                Application.main_window.main_display_unit.style_menu.quick_select_row (event.value1, -1);
                break;
                case MidiEvent.EventType.STYLECONTROL:
                Application.main_window.style_controller_view.set_style_section_by_index (event.value1);
                break;
                case MidiEvent.EventType.STYLESTARTSTOP:
                if (Application.main_window.style_controller_view != null) {
                    if (event.value1 == 1) {
                        Application.arranger_core.style_player.stop_style ();
                    } else {
                        Application.arranger_core.style_player.play_style ();
                    }
                }
                break;
                case MidiEvent.EventType.TEMPO:
                Application.arranger_core.style_player.change_tempo (event.value1);
                break;
                case MidiEvent.EventType.ACCOMP:
                Application.arranger_core.synthesizer.set_accompaniment_on (event.value1 == 1);
                break;
                case MidiEvent.EventType.STYLECHORD:
                Application.arranger_core.synthesizer.set_chord (event.value1, event.value2);
                break;
            }
        }

        public MidiRecorder (string name, string file_path, bool new_project) {
            _file_path = file_path;
            _track = 0;
            sync_start = false;
            initial_settings_tempo = CentralBus.get_tempo ();
            current_state = RecorderState.STOPPED;
            midi_event_sequence = new List<MidiEvent> [10];
            mute_array = new bool [10];
            if (!new_project) {
                open_sequence_from_file (file_path);
            } else {
                _name = name;
            }
        }

        public Gtk.Widget get_sequencer_visual () {
            if (_sequencer_visual == null) {
                _sequencer_visual = new Gtk.ListBox ();
                _sequencer_visual.hexpand = true;
            }

            track_visuals = new Shell.RecorderTrackItem [10];
            for (uint8 i = 0; i < 10; i++) {
                track_visuals[i] = new Shell.RecorderTrackItem (midi_event_sequence[i], i, track_options_handler);
                _sequencer_visual.insert (track_visuals[i], -1);
            }

            _sequencer_visual.set_selection_mode (Gtk.SelectionMode.BROWSE);
            _sequencer_visual.row_activated.connect ((row) => {
                var tr = (Shell.RecorderTrackItem)row;
                _track = tr.track;
                print ("Track Selected: %d\n", _track);
            });
            _sequencer_visual.width_request = 10;
            _sequencer_visual.get_style_context ().add_class ("recorder-background");

            _sequencer_progress_overlay = new Gtk.Overlay ();
            _sequencer_progress_overlay.add (_sequencer_visual);

            _sequencer_progress = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            _sequencer_progress.vexpand = true;
            _sequencer_progress.opacity = 0;
            _sequencer_progress.get_style_context ().add_class ("recorder-progress-line");

            var overlay_grid = new Gtk.Grid ();
            var place_holder_label = new Gtk.Label ("`");
            place_holder_label.width_request = 100;
            overlay_grid.attach (place_holder_label, 0, 0);
            overlay_grid.attach (_sequencer_progress, 1, 0);
            _sequencer_progress_overlay.add_overlay (overlay_grid);
            _sequencer_progress_overlay.set_overlay_pass_through (overlay_grid, true);

            return _sequencer_progress_overlay;
        }

        void track_options_handler (int track, uint option) {
            switch (option) {
                case 0:
                mute_array[track] = !mute_array[track];
                track_visuals[track].set_mute (mute_array[track]);
                if (Application.arranger_core.synthesizer != null) {
                    Application.arranger_core.synthesizer.halt_realtime (true);
                }
                if (track == 0 && Application.arranger_core.style_player != null) {
                    Application.arranger_core.style_player.stop_style ();
                }
                break;
                case 1:
                for (int i = 0; i < 10; i++) {
                    if (i == track) {
                        mute_array[i] = false;
                        track_visuals[i].set_mute (false);
                    } else {
                        mute_array[i] = true;
                        track_visuals[i].set_mute (true);
                    }
                }
                if (Application.arranger_core.synthesizer != null) {
                    Application.arranger_core.synthesizer.halt_realtime (true);
                }
                if (mute_array[0] && Application.arranger_core.style_player != null) {
                    Application.arranger_core.style_player.stop_style ();
                }
                break;
                case 2:
                if (current_state == RecorderState.STOPPED) {
                    track_visuals[track].activate ();
                } else {
                    Gdk.Display.get_default ().beep ();
                }
                break;
                case 3:
                if (current_state == RecorderState.STOPPED) {
                    midi_event_sequence[track] = new List<MidiEvent> ();
                    track_visuals[track].set_track_events (midi_event_sequence[track]);
                    mute_array[track] = false;
                    track_visuals[track].set_mute (false);
                    if (Application.arranger_core.synthesizer != null) {
                        Application.arranger_core.synthesizer.halt_realtime (true);
                    }
                } else {
                    Gdk.Display.get_default ().beep ();
                }
                break;
            }
        }

        public void make_initial_events (MidiEvent event) {
            var new_event = event;
            midi_event_sequence[_track].append (new_event);
        }

        public void record_event (MidiEvent event) {
            if (sync_start && (event.event_type == MidiEvent.EventType.NOTE || event.event_type == MidiEvent.EventType.STYLESTARTSTOP)) {
                sync_start = false;
                play (true);
                var initial_event_voice_r1 = new MidiEvent ();
                initial_event_voice_r1.event_type = MidiEvent.EventType.VOICECHANGE;
                int _bank = 0;
                int _preset = 0;
                Application.arranger_core.synthesizer.get_voice_program_by_channel (17, out _bank, out _preset);
                initial_event_voice_r1.value1 = _bank;
                initial_event_voice_r1.value2 = _preset;
                initial_event_voice_r1.channel = _track + 26;
                initial_event_voice_r1.track = _track;
                print ("Settings voice %d for track %d\n", initial_event_voice_r1.value1, _track);
                make_initial_events (initial_event_voice_r1);
                if (_track == 0) {
                    var initial_event_voice_r2 = new MidiEvent ();
                    initial_event_voice_r2.event_type = MidiEvent.EventType.VOICECHANGE;
                    Application.arranger_core.synthesizer.get_voice_program_by_channel (18, out _bank, out _preset);
                    initial_event_voice_r2.value1 = _bank;
                    initial_event_voice_r2.value2 = _preset;
                    initial_event_voice_r2.channel = 24;
                    initial_event_voice_r2.track = 0;
                    make_initial_events (initial_event_voice_r2);

                    var initial_event_voice_l = new MidiEvent ();
                    initial_event_voice_l.event_type = MidiEvent.EventType.VOICECHANGE;
                    Application.arranger_core.synthesizer.get_voice_program_by_channel (19, out _bank, out _preset);
                    initial_event_voice_l.value1 = _bank;
                    initial_event_voice_l.value2 = _preset;
                    initial_event_voice_l.channel = 25;
                    initial_event_voice_l.track = 0;
                    make_initial_events (initial_event_voice_l);

                    var initial_accomp_event = new MidiEvent ();
                    initial_accomp_event.event_type = MidiEvent.EventType.ACCOMP;
                    initial_accomp_event.value1 = Ensembles.Application.settings.get_boolean ("accomp-on") ? 1 : 0;
                    initial_accomp_event.track = 0;
                    make_initial_events (initial_accomp_event);

                    var initial_style_selection = new MidiEvent ();
                    initial_style_selection.event_type = MidiEvent.EventType.STYLECHANGE;
                    initial_style_selection.value1 = Ensembles.Application.settings.get_int ("style-index");
                    initial_style_selection.track = 0;
                    make_initial_events (initial_style_selection);

                    var initial_tempo = new MidiEvent ();
                    initial_tempo.event_type = MidiEvent.EventType.TEMPO;
                    initial_tempo.value1 = initial_settings_tempo;
                    initial_tempo.track = 0;
                    make_initial_events (initial_tempo);

                    var initial_style_part = new MidiEvent ();
                    initial_style_part.event_type = MidiEvent.EventType.STYLECONTROL;
                    initial_style_part.value1 = initial_settings_style_part_index;
                    initial_style_part.track = 0;
                    make_initial_events (initial_style_part);

                    var initial_chord_event = new MidiEvent ();
                    initial_chord_event.event_type = MidiEvent.EventType.STYLECHORD;
                    initial_chord_event.value1 = Application.arranger_core.synthesizer.chord_main;
                    initial_chord_event.value2 = Application.arranger_core.synthesizer.chord_type;
                    initial_chord_event.track = 0;
                    make_initial_events (initial_chord_event);
                }
            }
            if (recording_timer != null) {
                if (current_state == RecorderState.RECORDING) {
                    if (_track != 0) {
                        if (event.event_type == MidiEvent.EventType.NOTE || event.event_type == MidiEvent.EventType.VOICECHANGE) {
                            recording_timer.stop ();
                            ulong microseconds = (ulong)(recording_timer.elapsed () * 1000000);
                            var new_event = event;
                            new_event.channel = _track + 26;
                            new_event.track = _track;
                            new_event.time_stamp = microseconds;
                            recording_timer.start ();
                            midi_event_sequence[_track].append (new_event);
                            track_visuals[_track].set_track_events (midi_event_sequence[_track]);
                        }
                    } else {
                        recording_timer.stop ();
                        ulong microseconds = (ulong)(recording_timer.elapsed () * 1000000);
                        var new_event = event;
                        new_event.channel = 26;
                        new_event.track = _track;
                        new_event.time_stamp = microseconds;
                        recording_timer.start ();
                        midi_event_sequence[_track].append (new_event);
                        track_visuals[_track].set_track_events (midi_event_sequence[_track]);
                    }
                }

                //  print ("////////////////////////////////////////////\n");
                //  for (int i = 0; i < midi_event_sequence[_track].length (); i++) {
                //      print ("Event Type: %u -> %d %d %d %s %u\n",
                //      midi_event_sequence[_track].nth_data (i).event_type,
                //      midi_event_sequence[_track].nth_data (i).value1,
                //      midi_event_sequence[_track].nth_data (i).value2,
                //      midi_event_sequence[_track].nth_data (i).velocity,
                //      midi_event_sequence[_track].nth_data (i).time_stamp.to_string (),
                //      midi_event_sequence[_track].length ());
                //  }
                //  print ("////////////////////////////////////////////\n");
            }
        }

        public void toggle_sync_start () {
            sync_start = !sync_start;
        }

        public void play (bool? recording = false) {
            Idle.add (() => {
                _sequencer_progress.opacity = 1;
                return false;
            });
            if (recording == true) {
                rcrd_thread = new Thread<void> ("recorder_thread_main", recording_thread);
                rcrd_thread.join ();
            } else {
                play_thread = new Thread<void> ("playback_thread_main", playback_thread);
            }
        }

        public void stop () {
            _sequencer_progress.opacity = 0;
            if (recording_timer != null) {
                recording_timer.stop ();
            }
            for (int i = 0; i < playback_objects.length; i++) {
                if (playback_objects[i] != null) playback_objects[i].stop ();
            }
            if (current_state == RecorderState.RECORDING) {
                save_sequence_to_file ();
            }
            current_state = RecorderState.STOPPED;
            recorder_state_change (current_state);
            set_ui_sensitive (true);
            Idle.add (() => {
                for (int i = 0; i < 10; i++) {
                    track_visuals[i].set_track_events (midi_event_sequence[i]);
                }
                _sequencer_visual.sensitive = true;
                return false;
            });
            Application.arranger_core.synthesizer.halt_realtime (true);
            _sequencer_progress.queue_draw ();
        }


        private void recording_thread () {
            recording_timer = new Timer ();
            playback_objects = new PlayBackObject [10];
            midi_event_sequence[_track] = new List<MidiEvent> ();
            _sequencer_visual.sensitive = false;
            Idle.add (() => {
                recorder_state_change (RecorderState.RECORDING);
                return false;
            });
            for (uint i = 0; i < midi_event_sequence.length; i++) {
                if (i != _track) {
                    playback_objects[i] = new PlayBackObject (midi_event_sequence[i], i, this);
                }
            }
            current_state = RecorderState.RECORDING;
            Idle.add (() => {
                if (_track > 0) {
                    set_ui_sensitive (false);
                }
                return false;
            });
            new Thread<void> ("progress_thread", progress_visual_thread);
        }

        private void playback_thread () {
            playback_objects = new PlayBackObject [10];
            Idle.add (() => {
                recorder_state_change (RecorderState.PLAYING);
                return false;
            });
            for (uint i = 0; i < midi_event_sequence.length; i++) {
                playback_objects[i] = new PlayBackObject (midi_event_sequence[i], i, this);
            }
            current_state = RecorderState.PLAYING;
            Idle.add (() => {
                set_ui_sensitive (false);
                return false;
            });
            new Thread<void> ("progress_thread", progress_visual_thread);
        }

        private void progress_visual_thread () {
            progress_timer = new Timer ();
            progress_timer.start ();
            total_width = 0;
            while (current_state != RecorderState.STOPPED) {
                progress_timer.stop ();
                double value = progress_timer.elapsed () * 10.0;
                total_width += value;
                _sequencer_progress.width_request = (int)total_width;
                progress_change (total_width);
                progress_timer.start ();
                Thread.yield ();
                if (current_state == RecorderState.STOPPED) {
                    break;
                }
                Thread.usleep (100000);
                if (current_state == RecorderState.STOPPED) {
                    break;
                }
            }
        }

        public void save_sequence_to_file () {
            var gen = new Json.Generator ();
            var root = new Json.Node (Json.NodeType.OBJECT);

            var project_object = new Json.Object ();
            project_object.set_string_member ("name", _name);

            var track_array = new Json.Array ();

            for (uint i = 0; i < 10; i++) {
                var event_sequence_array = new Json.Array ();

                for (uint j = 0; j < midi_event_sequence[i].length (); j++) {
                    var event_object = new Json.Object ();
                    event_object.set_int_member ("e", (uint)midi_event_sequence[i].nth_data (j).event_type);
                    event_object.set_int_member ("trck", midi_event_sequence[i].nth_data (j).track);
                    event_object.set_int_member ("v1", midi_event_sequence[i].nth_data (j).value1);
                    event_object.set_int_member ("v2", midi_event_sequence[i].nth_data (j).value2);
                    event_object.set_int_member ("c", midi_event_sequence[i].nth_data (j).channel);
                    event_object.set_int_member ("v", midi_event_sequence[i].nth_data (j).velocity);
                    event_object.set_int_member ("t", midi_event_sequence[i].nth_data (j).time_stamp);

                    event_sequence_array.add_object_element (event_object);
                }

                track_array.add_array_element (event_sequence_array);
            }
            project_object.set_array_member ("event_sequence", track_array);

            root.set_object (project_object);
            gen.set_root (root);
            size_t length;
            string json = gen.to_data (out length);

            try {
                var file = File.new_for_path (_file_path);
                if (file.query_exists ()) {
                    file.delete ();
                }
                var fs = file.create (GLib.FileCreateFlags.NONE);

                var ds = new DataOutputStream (fs);
                ds.put_string (json);
            } catch (Error e) {
                warning (e.message);
            }
        }

        public void open_sequence_from_file (string file) {
            var parser = new Json.Parser ();
            try {
                parser.load_from_file (file);
                var root_node = parser.get_root ().get_object ();

                _name = root_node.get_string_member ("name");
                Timeout.add (1000, () => {
                    project_name_change (_name);
                    return false;
                });

                var track_array = root_node.get_array_member ("event_sequence");
                for (uint i = 0; i < 10; i++) {
                    var event_sequence_array = track_array.get_array_element (i);
                    if (event_sequence_array != null) {
                        for (uint j = 0; j < event_sequence_array.get_length (); j++) {
                            var event_object = event_sequence_array.get_object_element (j);
                            var midi_event = new MidiEvent ();

                            switch (event_object.get_int_member ("e")) {
                                case 0:
                                midi_event.event_type = MidiEvent.EventType.NOTE;
                                break;
                                case 1:
                                midi_event.event_type = MidiEvent.EventType.CONTROL;
                                break;
                                case 2:
                                midi_event.event_type = MidiEvent.EventType.VOICECHANGE;
                                break;
                                case 3:
                                midi_event.event_type = MidiEvent.EventType.REVERB;
                                break;
                                case 4:
                                midi_event.event_type = MidiEvent.EventType.REVERBON;
                                break;
                                case 5:
                                midi_event.event_type = MidiEvent.EventType.CHORUS;
                                break;
                                case 6:
                                midi_event.event_type = MidiEvent.EventType.CHORUSON;
                                break;
                                case 7:
                                midi_event.event_type = MidiEvent.EventType.ACCOMP;
                                break;
                                case 8:
                                midi_event.event_type = MidiEvent.EventType.STYLECHANGE;
                                break;
                                case 9:
                                midi_event.event_type = MidiEvent.EventType.STYLECONTROL;
                                break;
                                case 10:
                                midi_event.event_type = MidiEvent.EventType.STYLECONTROLACTUAL;
                                break;
                                case 11:
                                midi_event.event_type = MidiEvent.EventType.STYLESTARTSTOP;
                                break;
                                case 12:
                                midi_event.event_type = MidiEvent.EventType.STYLECHORD;
                                break;
                                case 13:
                                midi_event.event_type = MidiEvent.EventType.TEMPO;
                                break;
                            }

                            midi_event.channel = (int8)event_object.get_int_member ("c");
                            midi_event.time_stamp = (ulong)event_object.get_int_member ("t");
                            midi_event.track = (int8)event_object.get_int_member ("trck");
                            midi_event.value1 = (int)event_object.get_int_member ("v1");
                            midi_event.value2 = (int)event_object.get_int_member ("v2");
                            midi_event.velocity = (int)event_object.get_int_member ("v");

                            midi_event_sequence[i].append (midi_event);
                        }
                    }
                }
            }
            catch (Error e) {

            }
        }
    }
}
