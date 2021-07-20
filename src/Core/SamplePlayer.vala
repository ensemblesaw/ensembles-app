/*-
 * Copyright (c) 2021-2022 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License 
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
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

        ~SamplePlayer() {
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
                warning("Cannot play");
            }
        }

        public void stop_sample () {
            sample_element.set_state (Gst.State.NULL);
        }

        public void set_volume (double volume) {
            sample_element.set ("volume",  volume);
        }
    }
}
