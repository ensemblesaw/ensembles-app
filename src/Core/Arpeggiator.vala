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
    public class Arpeggiator : Object {
        public signal void generate_notes (int key, int on, int velocity);
        public signal void halt_notes ();
        int[] keys;
        int[] active_keys;
        bool arpeggio_playing = false;

        int tempo = 30;

        public Arpeggiator () {
            keys = new int[60];
        }

        public void change_tempo (int tempo) {
            this.tempo = tempo;
        }

        public void send_notes (int key, int on, int velocity) {
            if (on == 144) {
                keys[key - 36] = velocity;
                if (!arpeggio_playing) {
                    switch (Shell.EnsemblesApp.settings.get_int ("arpeggiator-type")) {
                        case 1:
                        arpeggio (2, true);
                        break;
                        case 2:
                        arpeggio (3, true);
                        break;
                        case 3:
                        arpeggio (4, true);
                        break;
                        case 4:
                        arpeggio (2, false);
                        break;
                        case 5:
                        arpeggio (3, false);
                        break;
                        case 6:
                        arpeggio (4, false);
                        break;
                        case 7:
                        arpeggio_sine (2);
                        break;
                        case 8:
                        arpeggio_sine (3);
                        break;
                        case 9:
                        arpeggio_sine (4);
                        break;
                        case 10:
                        arpeggio_random (2);
                        break;
                        case 11:
                        arpeggio_random (3);
                        break;
                        case 12:
                        arpeggio_random (4);
                        break;
                    }
                }
            } else {
                keys[key - 36] = -1;
                halt_notes ();
                arpeggio_playing = false;
            }
        }

        public void arpeggio (int subdivision, bool direction) {
            arpeggio_playing = true;
            active_keys = find_keys ();
            int n = active_keys.length;
            int i = direction ? 0 : int.MAX;
            halt_notes ();
            generate_notes (active_keys[i % n] + 36, 144, keys[active_keys[i % n]]);
            if (direction)
                i++;
            else
                i--;
            Timeout.add ((uint)((60000 / subdivision) / tempo), () => {
                active_keys = find_keys ();
                n = active_keys.length;
                if (!arpeggio_playing) {
                    return false;
                }
                halt_notes ();
                generate_notes (active_keys[i % n] + 36, 144, keys[active_keys[i % n]]);
                if (direction)
                    i++;
                else
                    i--;
                return arpeggio_playing;
            });
        }
        public void arpeggio_sine (int subdivision) {
            arpeggio_playing = true;
            active_keys = find_keys ();
            int n = active_keys.length;
            int i = 0;
            halt_notes ();
            generate_notes (active_keys[0] + 36, 144, keys[active_keys[0]]);
            bool direction = true;
            if (direction)
                i++;
            else
                i--;
            Timeout.add ((uint)((60000 / subdivision) / tempo), () => {
                active_keys = find_keys ();
                n = active_keys.length;
                if (!arpeggio_playing) {
                    return false;
                }
                halt_notes ();
                generate_notes (active_keys[i % n] + 36, 144, keys[active_keys[i % n]]);
                if (direction)
                    i++;
                else
                    i--;

                if (i == 0 || i == n - 1) {
                    direction = !direction;
                }
                return arpeggio_playing;
            });
        }

        public void arpeggio_random (int subdivision) {
            arpeggio_playing = true;
            active_keys = find_keys ();
            int n = active_keys.length;
            int i = 0;
            halt_notes ();
            generate_notes (active_keys[0] + 36, 144, keys[active_keys[0]]);
            Timeout.add ((uint)((60000 / subdivision) / tempo), () => {
                active_keys = find_keys ();
                n = active_keys.length;
                if (!arpeggio_playing) {
                    return false;
                }
                halt_notes ();
                i = Random.int_range (0, n);
                generate_notes (active_keys[i % n] + 36, 144, keys[active_keys[i % n]]);
                return arpeggio_playing;
            });
        }

        private int[] find_keys () {
            int[] active_keys = {};
            for (int i = 0; i < 60; i++) {
                if (keys[i] > 0) {
                    active_keys += i;
                }
            }
            return active_keys;
        }
    }
}
