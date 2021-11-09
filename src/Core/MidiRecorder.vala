namespace Ensembles.Core {
    public class MidiRecorder : Object {
        public enum RecorderState {
            RECORDING,
            PLAYING,
            STOPPED
        }

        private string _name;
        private uint _track;
        private Gtk.Grid _sequencer_visual;

        private List<MidiEvent>[] midi_event_sequence;
        private PlayBackObject[] playback_objects;

        private Thread<void> play_thread;
        private Thread<void> rcrd_thread;

        private Timer recording_timer;

        public RecorderState current_state;
        bool sync_start;



        // Midi Event Connectors
        public signal void recorder_state_change (RecorderState state);
        public signal void note_event (int note, int on, int velocity);

        public void fetch_events (MidiEvent event) {
            note_event (event.value1, event.value2, event.velocity);
        }

        public MidiRecorder (string name) {
            _name = name;
            _track = 0;
            sync_start = false;
            midi_event_sequence = new List<MidiEvent> [16];
        }

        public Gtk.Widget get_sequencer_visual () {
            if (_sequencer_visual == null) {
                _sequencer_visual = new Gtk.Grid ();
            }

            return _sequencer_visual;
        }

        public void record_event (MidiEvent event) {
            if (sync_start && event.event_type == MidiEvent.EventType.NOTE) {
                sync_start = false;
                play (true);
            }
            recording_timer.stop ();
            ulong microseconds = (ulong)(recording_timer.elapsed () * 1000000);
            var new_event = event;
            new_event.time_stamp = microseconds;

            if (current_state == RecorderState.RECORDING)
                midi_event_sequence[_track].append (new_event);
            recording_timer.start ();

            print ("////////////////////////////////////////////\n");
            for (int i = 0; i < midi_event_sequence[_track].length (); i++) {
                print ("Event %d %d %d %s %u\n",
                midi_event_sequence[_track].nth_data (i).value1,
                midi_event_sequence[_track].nth_data (i).value2,
                midi_event_sequence[_track].nth_data (i).velocity,
                midi_event_sequence[_track].nth_data (i).time_stamp.to_string (),
                midi_event_sequence[_track].length ());
            }
            print ("////////////////////////////////////////////\n");
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
            playback_objects = new PlayBackObject [16];
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
        }

        private void playback_thread () {
            playback_objects = new PlayBackObject [16];
            Idle.add (() => {
                recorder_state_change (RecorderState.PLAYING);
                current_state = RecorderState.PLAYING;
                return false;
            });
            for (uint i = 0; i < midi_event_sequence.length; i++) {
                playback_objects[i] = new PlayBackObject (midi_event_sequence[i], i, this);
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
            TEMPO
        }

        public EventType event_type;
        public int value1;       // note value, voice number, style number, control number
        public int value2;
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
                    recorder.fetch_events (event);
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
