namespace Ensembles.Core {
    public class MidiRecorder : Object {
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

        private string _name;
        private uint _track;
        private Gtk.Grid _sequencer_visual;

        private List<MidiEvent>[] midi_event_sequence;
        private PlayBackObject[] playback_objects;

        private Thread play_thread;
        private Thread rcrd_thread;

        private Timer recording_timer;
        private ulong microseconds;



        // Midi Event Connectors
        public signal void note_event (int note, bool on, int velocity);

        public MidiRecorder (string name) {
            _name = name;
            _track = 0;
            midi_event_sequence = new List<MidiEvent> [16];
        }

        public Gtk.Widget get_sequencer_visual () {
            if (_sequencer_visual == null) {
                _sequencer_visual = new Gtk.Grid ();
            }

            return _sequencer_visual;
        }

        public void record_event (MidiEvent event) {
            recording_timer.elapsed (out microseconds);
            var new_event = event;
            new_event.time_stamp = microseconds;
            midi_event_sequence[_track].append (new_event);
            recording_timer.reset ();
        }

        public void play (bool? recording = false) {
            if (recording == true) {
                rcrd_thread = new Thread<void> ("recorder_thread_main", recording_thread);
                recording_timer = new Timer ();
            } else {
                play_thread = new Thread<void> ("playback_thread_main", playback_thread);
            }
        }

        public void stop () {
            recording_timer.stop ();
            recording_timer.reset ();
            for (int i = 0; i < playback_objects.length; i++) {
                playback_objects[i].stop ();
            }
        }


        private void recording_thread () {
            playback_objects = new PlayBackObject [16];
            midi_event_sequence[_track] = new List<MidiEvent> ();
            for (uint i = 0; i < midi_event_sequence.length; i++) {
                if (i != _track) {
                    playback_objects[i] = new PlayBackObject (midi_event_sequence[i], i);
                }
            }
        }

        private void playback_thread () {
            playback_objects = new PlayBackObject [16];
            for (uint i = 0; i < midi_event_sequence.length; i++) {
                playback_objects[i] = new PlayBackObject (midi_event_sequence[i], i);
            }
        }
    }

    public class MidiEvent {
        public MidiRecorder.EventType event_type;
        public int value;       // note value, voice number, style number, control number
        public int channel;
        public int velocity;
        public ulong time_stamp;
    }

    public class PlayBackObject {
        public Thread thread;
        List<weak MidiEvent> midi_event_sequence;
        bool playing;

        public signal void fire_event (MidiEvent event);

        public class PlayBackObject (List<MidiEvent> midi_event_sequence, uint track) {
            this.midi_event_sequence = midi_event_sequence.copy ();
            playing = true;
            thread = new Thread<void> ("_play_thread_" + track.to_string (), track_thread);
        }

        private void track_thread () {
            for (uint i = 0; i < midi_event_sequence.length (); i++) {
                MidiEvent event = midi_event_sequence.nth_data (i);
                ulong time_stamp = event.time_stamp;
                Thread.usleep (time_stamp);
                // Fire event
                Idle.add (() => {
                    fire_event (event);
                    return false;
                });

                // Check if playback has been stopped
                if (!playing) {
                    break;
                }
            }
        }

        public void stop () {
            playing = false;
        }
    }
}
