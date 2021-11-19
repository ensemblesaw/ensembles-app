namespace Ensembles.Core {
    public class MidiRecorder : Object {
        public enum RecorderState {
            RECORDING,
            PLAYING,
            STOPPED
        }

        private string _name;
        private string _file_path;
        private int _track;
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
        public signal void note_event (int channel, int note, int on, int velocity);
        public signal void voice_change (int channel, int bank, int index);
        public signal void style_change (int index);
        public signal void style_part_change (int part_index);
        public signal void style_start_stop (bool stop);
        public signal void tempo_change (int tempo);
        public signal void accomp_change (bool on);
        public signal void split_change (bool on);
        public signal void layer_change (bool on);

        public void multiplex_events (MidiEvent event) {
            switch (event.event_type) {
                case MidiEvent.EventType.NOTE:
                note_event (event.channel, event.value1, event.value2, event.velocity);
                break;
                case MidiEvent.EventType.VOICECHANGE:
                voice_change (event.channel, event.value1, event.value2);
                break;
                case MidiEvent.EventType.STYLECHANGE:
                style_change (event.value1);
                break;
                case MidiEvent.EventType.STYLECONTROL:
                style_part_change (event.value1);
                break;
                case MidiEvent.EventType.STYLESTARTSTOP:
                style_start_stop (event.value1 == 1 ? true : false);
                break;
                case MidiEvent.EventType.TEMPO:
                tempo_change (event.value1);
                break;
                case MidiEvent.EventType.ACCOMP:
                accomp_change (event.value1 == 1);
                break;
                case MidiEvent.EventType.SPLIT:
                split_change (event.value1 == 1);
                break;
                case MidiEvent.EventType.LAYER:
                layer_change (event.value1 == 1);
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
            for (int i = 0; i < 10; i++) {
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
                if (Shell.MainWindow.synthesizer != null) {
                    Shell.MainWindow.synthesizer.halt_realtime ();
                }
                if (track == 0 && Shell.MainWindow.style_player != null) {
                    Shell.MainWindow.style_player.stop_style ();
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
                if (Shell.MainWindow.synthesizer != null) {
                    Shell.MainWindow.synthesizer.halt_realtime ();
                }
                if (mute_array[0] && Shell.MainWindow.style_player != null) {
                    Shell.MainWindow.style_player.stop_style ();
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
                    if (Shell.MainWindow.synthesizer != null) {
                        Shell.MainWindow.synthesizer.halt_realtime ();
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
                initial_event_voice_r1.value1 = Shell.EnsemblesApp.settings.get_int ("voice-r1-bank");
                initial_event_voice_r1.value2 = Shell.EnsemblesApp.settings.get_int ("voice-r1-preset");
                if (_track == 0) {
                    initial_event_voice_r1.channel = 6;
                } else {
                    initial_event_voice_r1.channel = _track + 6;
                }
                print ("Settings voice %d for track %d\n", initial_event_voice_r1.value1, _track);
                make_initial_events (initial_event_voice_r1);
                if (_track == 0) {
                    var initial_event_voice_r2 = new MidiEvent ();
                    initial_event_voice_r2.event_type = MidiEvent.EventType.VOICECHANGE;
                    initial_event_voice_r2.value1 = Shell.EnsemblesApp.settings.get_int ("voice-r2-bank");
                    initial_event_voice_r2.value2 = Shell.EnsemblesApp.settings.get_int ("voice-r2-preset");
                    initial_event_voice_r2.channel = 1;
                    make_initial_events (initial_event_voice_r2);

                    var initial_event_voice_l = new MidiEvent ();
                    initial_event_voice_l.event_type = MidiEvent.EventType.VOICECHANGE;
                    initial_event_voice_l.value1 = Shell.EnsemblesApp.settings.get_int ("voice-l-bank");
                    initial_event_voice_l.value2 = Shell.EnsemblesApp.settings.get_int ("voice-l-preset");
                    initial_event_voice_l.channel = 2;
                    make_initial_events (initial_event_voice_l);

                    var initial_layer_event = new MidiEvent ();
                    initial_layer_event.event_type = MidiEvent.EventType.LAYER;
                    initial_layer_event.value1 = Shell.EnsemblesApp.settings.get_boolean ("layer-on") ? 1 : 0;
                    make_initial_events (initial_layer_event);

                    var initial_split_event = new MidiEvent ();
                    initial_split_event.event_type = MidiEvent.EventType.SPLIT;
                    initial_split_event.value1 = Shell.EnsemblesApp.settings.get_boolean ("split-on") ? 1 : 0;
                    make_initial_events (initial_split_event);

                    var initial_accomp_event = new MidiEvent ();
                    initial_accomp_event.event_type = MidiEvent.EventType.ACCOMP;
                    initial_accomp_event.value1 = Shell.EnsemblesApp.settings.get_boolean ("accomp-on") ? 1 : 0;
                    make_initial_events (initial_accomp_event);

                    var initial_style_selection = new MidiEvent ();
                    initial_style_selection.event_type = MidiEvent.EventType.STYLECHANGE;
                    initial_style_selection.value1 = Shell.EnsemblesApp.settings.get_int ("style-index");
                    make_initial_events (initial_style_selection);

                    var initial_tempo = new MidiEvent ();
                    initial_tempo.event_type = MidiEvent.EventType.TEMPO;
                    initial_tempo.value1 = initial_settings_tempo;
                    make_initial_events (initial_tempo);

                    var initial_style_part = new MidiEvent ();
                    initial_style_part.event_type = MidiEvent.EventType.STYLECONTROL;
                    initial_style_part.value1 = initial_settings_style_part_index;
                    make_initial_events (initial_style_part);
                }
            }
            if (recording_timer != null) {
                recording_timer.stop ();
                ulong microseconds = (ulong)(recording_timer.elapsed () * 1000000);
                var new_event = event;
                if (_track == 0) {
                    new_event.channel = 6;
                } else {
                    new_event.channel = _track + 6;
                }
                new_event.track = _track;
                new_event.time_stamp = microseconds;

                if (current_state == RecorderState.RECORDING) {
                    if (_track != 0) {
                        if (event.event_type == MidiEvent.EventType.NOTE || event.event_type == MidiEvent.EventType.VOICECHANGE) {
                            midi_event_sequence[_track].append (new_event);
                            track_visuals[_track].set_track_events (midi_event_sequence[_track]);
                        }
                    } else {
                        midi_event_sequence[_track].append (new_event);
                        track_visuals[_track].set_track_events (midi_event_sequence[_track]);
                    }
                }
                recording_timer.start ();

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
            Shell.MainWindow.synthesizer.halt_realtime ();
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
                Thread.usleep (10000);
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
                print ("%s\n", _name);
                Timeout.add (1000, () => {
                    project_name_change (_name);
                    return false;
                });

                var track_array = root_node.get_array_member ("event_sequence");
                for (uint i = 0; i < 10; i++) {
                    var event_sequence_array = track_array.get_array_element (i);
                    print ("%u------\n", i);
                    if (event_sequence_array != null) {
                        for (uint j = 0; j < event_sequence_array.get_length (); j++) {
                            print ("%u....\n", j);
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
                                midi_event.event_type = MidiEvent.EventType.TRANSPOSE;
                                break;
                                case 4:
                                midi_event.event_type = MidiEvent.EventType.TRANSPOSEON;
                                break;
                                case 5:
                                midi_event.event_type = MidiEvent.EventType.OCTAVE;
                                break;
                                case 6:
                                midi_event.event_type = MidiEvent.EventType.OCTAVEON;
                                break;
                                case 7:
                                midi_event.event_type = MidiEvent.EventType.REVERB;
                                break;
                                case 8:
                                midi_event.event_type = MidiEvent.EventType.REVERBON;
                                break;
                                case 9:
                                midi_event.event_type = MidiEvent.EventType.CHORUS;
                                break;
                                case 10:
                                midi_event.event_type = MidiEvent.EventType.CHORUSON;
                                break;
                                case 11:
                                midi_event.event_type = MidiEvent.EventType.ACCOMP;
                                break;
                                case 12:
                                midi_event.event_type = MidiEvent.EventType.STYLECHANGE;
                                break;
                                case 13:
                                midi_event.event_type = MidiEvent.EventType.STYLECONTROL;
                                break;
                                case 14:
                                midi_event.event_type = MidiEvent.EventType.STYLECONTROLACTUAL;
                                break;
                                case 15:
                                midi_event.event_type = MidiEvent.EventType.STYLESTARTSTOP;
                                break;
                                case 16:
                                midi_event.event_type = MidiEvent.EventType.TEMPO;
                                break;
                                case 17:
                                midi_event.event_type = MidiEvent.EventType.SPLIT;
                                break;
                                case 18:
                                midi_event.event_type = MidiEvent.EventType.LAYER;
                                break;
                            }

                            midi_event.channel = (int)event_object.get_int_member ("c");
                            midi_event.time_stamp = (ulong)event_object.get_int_member ("t");
                            midi_event.track = (int)event_object.get_int_member ("trck");
                            midi_event.value1 = (int)event_object.get_int_member ("v1");
                            midi_event.value2 = (int)event_object.get_int_member ("v2");
                            midi_event.velocity = (int)event_object.get_int_member ("v");

                            midi_event_sequence[i].append (midi_event);
                        }
                        print ("settings\n");
                    }
                }
            }
            catch (Error e) {

            }
        }
    }

    public class MidiEvent {
        public enum EventType {
            NOTE,
            CONTROL,
            VOICECHANGE,
            TRANSPOSE,
            TRANSPOSEON,
            OCTAVE,
            OCTAVEON,
            REVERB,
            REVERBON,
            CHORUS,
            CHORUSON,
            ACCOMP,
            STYLECHANGE,
            STYLECONTROL,
            STYLECONTROLACTUAL,
            STYLESTARTSTOP,
            TEMPO,
            SPLIT,
            LAYER
        }

        public EventType event_type;
        public int track;        // Which track this event belongs to
        public int value1;       // note value, voice number, style number, control number
        public int value2;       // note on
        public int channel;
        public int velocity;
        public ulong time_stamp;
    }

    public class PlayBackObject {
        public Thread<void> thread;
        List<weak MidiEvent> midi_event_sequence;
        MidiRecorder recorder;
        bool playing;
        uint _track;

        public signal void fire_event (MidiEvent event);

        public class PlayBackObject (List<MidiEvent> midi_event_sequence, uint track, MidiRecorder recorder) {
            this.recorder = recorder;
            this.midi_event_sequence = midi_event_sequence.copy ();
            playing = true;
            _track = track;
            //print ("Start" + track.to_string () + "\n");
            thread = new Thread<void> ("_play_thread_" + track.to_string (), track_thread);
        }

        private void track_thread () {
            for (uint i = 0; i < midi_event_sequence.length (); i++) {
                MidiEvent event = midi_event_sequence.nth_data (i);
                ulong time_stamp = event.time_stamp;
                Thread.usleep (time_stamp);
                // Check if playback has been stopped before firing event
                if (!playing) {
                    break;
                }
                // Fire event
                if (!recorder.mute_array[_track]) {
                    recorder.multiplex_events (event);
                }
            }
            playing = false;
        }

        public void stop () {
            playing = false;
        }
    }
}
