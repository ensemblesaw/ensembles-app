/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core {
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
