/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core {
    public class SamplePlayer : Object {
        Gst.Element sample_element;
        string file_path;
        bool recorded_audio;

        public SamplePlayer (string file, bool? recorded = false) {
            recorded_audio = recorded;
            sample_element = Gst.ElementFactory.make ("playbin", "player");
            file_path = file;
            sample_element.set ("uri", "file://" + file_path);
            sample_element.set ("volume", 0.9);
        }

        public void delete_file () {
            if (recorded_audio) {
                try {
                    File.new_for_path (file_path).delete ();
                } catch (Error e) {
                    warning (e.message);
                }
            }
        }

        public void play_sample () {
            sample_element.set_state (Gst.State.NULL);
            if (sample_element.set_state (Gst.State.PLAYING) == Gst.StateChangeReturn.FAILURE) {
                warning ("Cannot play");
            }
        }

        public void stop_sample () {
            sample_element.set_state (Gst.State.NULL);
        }

        public void set_volume (double volume) {
            sample_element.set ("volume", volume);
        }
    }
}
