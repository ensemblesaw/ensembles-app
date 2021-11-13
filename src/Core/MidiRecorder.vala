namespace Ensembles.Core {
    public class MidiRecorder : Object {
        public enum RecorderState {
            RECORDING,
            PLAYING,
            STOPPED
        }

        private string _name;
        private int _track;
        private Gtk.ListBox _sequencer_visual;
        private Gtk.Overlay _sequencer_progress_overlay;
        private Gtk.Box _sequencer_progress;



        private List<MidiEvent>[] midi_event_sequence;
        private PlayBackObject[] playback_objects;
        private Shell.RecorderTrackItem[] track_visuals;

        private Thread<void> play_thread;
        private Thread<void> rcrd_thread;

        private Timer recording_timer;
        private Timer progress_timer;

        public RecorderState current_state;
        bool sync_start;

        // Initial Settings;
        public int initial_settings_style_part_index = 2;


        // Midi Event Connectors
        public signal void recorder_state_change (RecorderState state);
        public signal void note_event (int channel, int note, int on, int velocity);
        public signal void voice_change (int channel, int bank, int index);
        public signal void style_change (int index);
        public signal void style_part_change (int part_index);
        public signal void style_start_stop (bool stop);

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
            }
        }

        public MidiRecorder (string name) {
            _name = name;
            _track = 0;
            sync_start = false;
            current_state = RecorderState.STOPPED;
            midi_event_sequence = new List<MidiEvent> [10];
        }

        public Gtk.Widget get_sequencer_visual () {
            if (_sequencer_visual == null) {
                _sequencer_visual = new Gtk.ListBox ();
                _sequencer_visual.hexpand = true;
            }

            track_visuals = new Shell.RecorderTrackItem [10];
            for (int i = 0; i < 10; i++) {
                track_visuals[i] = new Shell.RecorderTrackItem (midi_event_sequence[i], i);
                _sequencer_visual.insert (track_visuals[i], -1);
            }

            _sequencer_visual.set_selection_mode (Gtk.SelectionMode.BROWSE);
            _sequencer_visual.row_activated.connect ((row) => {
                var tr = (Shell.RecorderTrackItem)row;
                _track = tr.track;
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

        public void make_initial_events (MidiEvent event) {
            var new_event = event;
            if (_track > 0) {
                new_event.channel = _track + 6;
            }
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

                    var initial_style_selection = new MidiEvent ();
                    initial_style_selection.event_type = MidiEvent.EventType.STYLECHANGE;
                    initial_style_selection.value1 = Shell.EnsemblesApp.settings.get_int ("style-index");
                    make_initial_events (initial_style_selection);

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
                if (_track > 0) {
                    new_event.channel = _track + 6;
                }
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

                print ("////////////////////////////////////////////\n");
                for (int i = 0; i < midi_event_sequence[_track].length (); i++) {
                    print ("Event Type: %u -> %d %d %d %s %u\n",
                    midi_event_sequence[_track].nth_data (i).event_type,
                    midi_event_sequence[_track].nth_data (i).value1,
                    midi_event_sequence[_track].nth_data (i).value2,
                    midi_event_sequence[_track].nth_data (i).velocity,
                    midi_event_sequence[_track].nth_data (i).time_stamp.to_string (),
                    midi_event_sequence[_track].length ());
                }
                print ("////////////////////////////////////////////\n");
            }
        }

        public void toggle_sync_start () {
            sync_start = !sync_start;
        }

        public void play (bool? recording = false) {
            if (recording == true) {
                rcrd_thread = new Thread<void> ("recorder_thread_main", recording_thread);
                rcrd_thread.join ();
            } else {
                play_thread = new Thread<void> ("playback_thread_main", playback_thread);
            }
        }

        public void stop () {
            recording_timer.stop ();
            for (int i = 0; i < playback_objects.length; i++) {
                if (playback_objects[i] != null) playback_objects[i].stop ();
            }
            Idle.add (() => {
                current_state = RecorderState.STOPPED;
                recorder_state_change (RecorderState.STOPPED);
                return false;
            });
        }


        private void recording_thread () {
            recording_timer = new Timer ();
            playback_objects = new PlayBackObject [10];
            midi_event_sequence[_track] = new List<MidiEvent> ();
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
                _sequencer_progress.opacity = 1;
                return false;
            });
            new Thread<void> ("progress_thread", progress_visual_thread);
        }

        private void playback_thread () {
            playback_objects = new PlayBackObject [10];
            Idle.add (() => {
                recorder_state_change (RecorderState.PLAYING);
                current_state = RecorderState.PLAYING;
                return false;
            });
            for (uint i = 0; i < midi_event_sequence.length; i++) {
                playback_objects[i] = new PlayBackObject (midi_event_sequence[i], i, this);
            }
            _sequencer_progress.opacity = 1;
            new Thread<void> ("progress_thread", progress_visual_thread);
        }

        private void progress_visual_thread () {
            progress_timer = new Timer ();
            progress_timer.start ();
            while (current_state != RecorderState.STOPPED) {
                Idle.add (() => {
                    progress_timer.stop ();
                    _sequencer_progress.width_request = (int)((double)progress_timer.elapsed (null) * 10.0);
                    progress_timer.continue ();
                    return false;
                });
                Thread.yield ();
                Thread.usleep (800);
            }
            Idle.add (() => {
                _sequencer_progress.opacity = 0;
                for (int i = 0; i < 10; i++) {
                    track_visuals[i].set_track_events (midi_event_sequence[i]);
                }
                return false;
            });
            Shell.MainWindow.synthesizer.halt_realtime ();
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
            STYLESTARTSTOP,
            TEMPO
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

        public signal void fire_event (MidiEvent event);

        public class PlayBackObject (List<MidiEvent> midi_event_sequence, uint track, MidiRecorder recorder) {
            this.recorder = recorder;
            this.midi_event_sequence = midi_event_sequence.copy ();
            playing = true;
            //print ("Start" + track.to_string () + "\n");
            thread = new Thread<void> ("_play_thread_" + track.to_string (), track_thread);
        }

        private void track_thread () {
            for (uint i = 0; i < midi_event_sequence.length (); i++) {
                MidiEvent event = midi_event_sequence.nth_data (i);
                ulong time_stamp = event.time_stamp;
                Thread.usleep (time_stamp);
                //print ("Fire\n");
                // Fire event
                Idle.add (() => {
                    recorder.multiplex_events (event);
                    return false;
                });

                // Check if playback has been stopped
                if (!playing) {
                    break;
                }
            }
            playing = false;
        }

        public void stop () {
            playing = false;
        }
    }
}
