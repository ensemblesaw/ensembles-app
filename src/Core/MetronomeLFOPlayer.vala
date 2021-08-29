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
    public class MetronomeLFOPlayer : Object {
        string _lfo_directory_location;
        int _time_signature_n;
        int _time_signature_d = 4;
        string _lfo_file_location;
        int _tempo = 120;
        public bool looping;
        public signal void beat_sync ();
        public MetronomeLFOPlayer (string lfo_directory_location) {
            _lfo_directory_location = lfo_directory_location;
            metronome_lfo_player_init ();
        }
        ~MetronomeLFOPlayer () {
            metronome_lfo_player_destruct ();
        }

        public void play_measure (int time_signature_n, int time_signature_d, bool? initial = false) {
            if (_time_signature_n != time_signature_n ||
                _time_signature_d != time_signature_d ||
                initial) {
                _time_signature_n = time_signature_n;
                _time_signature_d = time_signature_d;
                _lfo_file_location = _lfo_directory_location + "/" +
                                     time_signature_n.to_string () +".mtlfo";
                metronome_lfo_player_change_base (_lfo_file_location, _tempo * _time_signature_d / 4, 1920);
            } else {
                metronome_lfo_player_play ();
            }
        }

        public void set_tempo (int tempo) {
            _tempo = tempo;
            metronome_lfo_player_set_tempo (_tempo * _time_signature_d / 4);
        }

        public void play_loop (int time_signature_n, int time_signature_d) {
            _time_signature_n = time_signature_n;
            _time_signature_d = time_signature_d;
            if (!CentralBus.get_style_looping_on () && !looping) {
                looping = true;
                new Thread<int> ("metronome_loop", loop);
            }
        }

        int loop () {
            play_measure (_time_signature_n, _time_signature_d, true);
            while (looping) {
                Idle.add (() => {
                    beat_sync ();
                    return false;
                });
                Thread.usleep ((ulong)(240000 * _time_signature_n / (_tempo * _time_signature_d)) * 1000);
                metronome_lfo_player_play ();
                Thread.yield ();
            }
            return 0;
        }

        public void stop_loop () {
            looping = false;
        }
    }
}

extern void metronome_lfo_player_init ();
extern void metronome_lfo_player_destruct ();
extern void metronome_lfo_player_change_base (string mid_file, int tempo, int eol);
extern void metronome_lfo_player_play ();
extern void metronome_lfo_player_set_tempo (int tempo);
