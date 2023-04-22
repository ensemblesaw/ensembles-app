/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Models;

namespace Ensembles.Core.Analysers {
    public class ChordAnalyser : Object {
        private uint8[] key_track;
        private uint8[] chord_possibility;

        public enum ChordDetectionMode {
            SPLIT_LONG = 0,
            SPLIT_SHORT = 1,
            FULL_RANGE = 2
        }

        construct {
            key_track = new uint8[13];
            chord_possibility = new uint8[144];
        }

        /** This function returns an inferred {@link Ensembles.Models.Chord} based on subsequent
          * invocations of note-on and note-off events
          *
          * @param key Key or note number
          * @param on Whether the key is pressed or released
          * @return A {@link Ensembles.Models.Chord} as determined from subsequent keypresses
          */
        public Chord infer (uint8 key, bool on) {
            key_track [key % 12] = on ? 1 : 0;

            uint8 n_keys = 0;
            int16 probable_root = -1;

            for (uint8 i = 0; i < 12; i++) {
                n_keys += key_track[i];
                if (probable_root < 0 && key_track[i] == 1) {
                    probable_root = i;
                }
            }

            for (uint8 i = 0; i < 144; i++) {
                chord_possibility[i] = 0;
            }

            uint8 i = 0;

            if (n_keys < 4) {
                // Major
                for (; i < 5; i++) {
                    chord_possibility [i] = 6 * key_track[i] + key_track[i + 4] + key_track[i + 7]; // One way to play it
                }
                /*                          ^
                 *                          |
                 *                          |
                 *                      Root contribution
                 */
                for (; i < 9; i++) {
                    chord_possibility [i] = key_track[i - 5] + 6 * key_track[i] + key_track[i + 4]; // Another way to play it
                }
                for (; i < 12; i++) {
                    chord_possibility [i] = key_track[i - 8] + key_track[i - 5] + 6 * key_track[i]; // Yet another way to play it
                }

                // minor
                for (; i < 17; i++) {
                    chord_possibility [i] = 6 * key_track[i - 12] + key_track[i - 12 + 3] + key_track[i - 12 + 7];
                }
                for (; i < 21; i++) {
                    chord_possibility [i] = key_track[i - 12 - 5] + 6 * key_track[i - 12] + key_track[i - 12 + 3];
                }
                for (; i < 24; i++) {
                    chord_possibility [i] = key_track[i - 12 - 9] + key_track[i - 12 - 5] + 6 * key_track[i - 12];
                }

                // diminished
                for (; i < 29; i++) {
                    chord_possibility [i] = 6 * key_track[i - 24] + key_track[i - 24 + 3] + key_track[i - 24 + 6];
                }
                for (; i < 33; i++) {
                    chord_possibility [i] = key_track[i - 24 + 6] + 6 * key_track[i - 24] + key_track[i - 24 + 3];
                }
                for (; i < 36; i++) {
                    chord_possibility [i] = key_track[i - 24 - 9] + key_track[i - 24 - 6] + 6 * key_track[i - 24];
                }

                // suspended 2
                for (; i < 41; i++) {
                    chord_possibility [i] = 6 * key_track[i - 36] + key_track[i - 36 + 2] + key_track[i - 36 + 7];
                }
                for (; i < 45; i++) {
                    chord_possibility [i] = key_track[i - 36 - 5] + 6 * key_track[i - 36] + key_track[i - 36 + 2];
                }
                for (; i < 48; i++) {
                    chord_possibility [i] = key_track[i - 36 - 10] + key_track[i - 36 - 5] + 6 * key_track[i - 36];
                }

                // suspended 4
                for (; i < 53; i++) {
                    chord_possibility [i] = (i - 48 == probable_root && n_keys > 2 ? 7 : 6) * key_track[i - 48] +
                    key_track[i - 48 + 5] + key_track[i - 48 + 7];
                }
                for (; i < 57; i++) {
                    chord_possibility [i] = key_track[i - 48 - 5] +
                    (i - 48 == probable_root && n_keys > 2 ? 7 : 6) * key_track[i - 48] + key_track[i - 48 + 5];
                }
                for (; i < 60; i++) {
                    chord_possibility [i] = key_track[i - 48 - 7] + key_track[i - 48 - 5] +
                    (i - 48 == probable_root && n_keys > 2 ? 7 : 6) * key_track[i - 48];
                }

                // augmented
                for (; i < 65; i++) {
                    chord_possibility [i] = 6 * key_track[i - 60] + key_track[i - 60 + 4] + key_track[i - 60 + 8];
                }
                for (; i < 69; i++) {
                    chord_possibility [i] = key_track[i - 60 - 4] + 6 * key_track[i - 60] + key_track[i - 60 + 4];
                }
                for (; i < 72; i++) {
                    chord_possibility [i] = key_track[i - 60 - 8] + key_track[i - 60 - 4] + 6 * key_track[i - 60];
                }
            } else if (n_keys == 4) {
                // Dominant Sixth
                for (i = 72; i < 77; i++) {
                    chord_possibility [i] = 6 * key_track[i - 72] + key_track[i - 72 + 4] +
                    key_track[i - 72 + 7] + key_track[i - 72 + 9];
                }
                for (; i < 81; i++) {
                    chord_possibility [i] = key_track[i - 72 - 5] +
                    key_track[i - 72 - 3] + 6 * key_track[i - 72] + key_track[i - 72 + 4];
                }
                for (; i < 84; i++) {
                    chord_possibility [i] = key_track[i - 72 - 8] +
                    key_track[i - 72 - 5] + key_track[i - 72 - 3] + 6 * key_track[i - 72];
                }

                // Dominant Seventh
                for (; i < 89; i++) {
                    chord_possibility [i] = 6 * key_track[i - 84] + key_track[i - 84 + 4] +
                    key_track[i - 84 + 7] + key_track[i - 84 + 10];
                }
                for (; i < 93; i++) {
                    chord_possibility [i] = key_track[i - 84 - 5] +
                    key_track[i - 84 - 2] + 6 * key_track[i - 84] + key_track[i - 84 + 4];
                }
                for (; i < 96; i++) {
                    chord_possibility [i] = key_track[i - 84 - 8] +
                    key_track[i - 84 - 5] + key_track[i - 84 - 2] + 6 * key_track[i - 84];
                }

                // Major Seventh
                for (; i < 101; i++) {
                    chord_possibility [i] = 6 * key_track[i - 96] +
                    key_track[i - 96 + 4] + key_track[i - 96 + 7] + key_track[i - 96 + 11];
                }
                for (; i < 105; i++) {
                    chord_possibility [i] = key_track[i - 96 - 5] +
                    key_track[i - 96 - 1] + 6 * key_track[i - 96] + key_track[i - 96 + 4];
                }
                for (; i < 108; i++) {
                    chord_possibility [i] = key_track[i - 96 - 8] +
                    key_track[i - 96 - 5] + key_track[i - 96 - 1] + 6 * key_track[i - 96];
                }

                // minor seventh
                for (; i < 113; i++) {
                    chord_possibility [i] = 6 * key_track[i - 108] +
                    key_track[i - 108 + 3] + key_track[i - 108 + 7] + key_track[i - 108 + 10];
                }
                for (; i < 117; i++) {
                    chord_possibility [i] = key_track[i - 108 - 5] +
                    key_track[i - 108 - 2] + 6 * key_track[i - 108] + key_track[i - 108 + 3];
                }
                for (; i < 120; i++) {
                    chord_possibility [i] = key_track[i - 108 - 9] +
                    key_track[i - 108 - 5] + key_track[i - 108 - 2] + 6 * key_track[i - 108];
                }

                // add9
                for (; i < 125; i++) {
                    chord_possibility [i] = 6 * key_track[i - 120] +
                    key_track[i - 120 + 4] + key_track[i - 120 + 7] + key_track[i - 120 + 2];
                }
                for (; i < 129; i++) {
                    chord_possibility [i] = key_track[i - 120 - 5] +
                    key_track[i - 120 + 2] + 6 * key_track[i - 120] + key_track[i - 120 + 4];
                }
                for (; i < 132; i++) {
                    chord_possibility [i] = key_track[i - 120 - 8] +
                    key_track[i - 120 - 5] + key_track[i - 120 - 10] + 6 * key_track[i - 120];
                }
            } else if (n_keys == 5) {
                // Dominant 9th
                for (; i < 137; i++) {
                    chord_possibility [i] = 6 * key_track[i - 132] +
                    key_track[i - 132 + 4] + key_track[i - 132 + 7] + key_track[i - 132 + 10] + key_track[i - 132 + 2];
                }
                for (; i < 141; i++) {
                    chord_possibility [i] = key_track[i - 132 - 5] + key_track[i - 132 - 2] +
                    key_track[i - 120 + 2] + 6 * key_track[i - 132] + key_track[i - 132 + 4];
                }
                for (; i < 144; i++) {
                    chord_possibility [i] = key_track[i - 132 - 8] +
                    key_track[i - 132 - 5] + key_track[i - 132 - 2] + 6 * key_track[i - 132] + key_track[i - 120 - 10];
                }
            }

            i = n_keys < 4 ? 0 : n_keys == 4 ? 72 : 132;
            uint8 max_i = n_keys < 4 ? 72 : n_keys == 4 ? 132 : 144;
            int16 max = -1;
            int16 max_index = 0;
            for (; i < max_i; i++) {
                // printf("%d ", chord_possibility[i]);
                if (max < chord_possibility[i]) {
                    max = chord_possibility[i];
                    max_index = i;
                }
            }

            var chord = Chord ();

            // Set the chord type
            if (max_index < 12) {
                chord.type = ChordType.MAJOR;
            } else if (max_index < 24) {
                chord.type = ChordType.MINOR;
            } else if (max_index < 36) {
                chord.type = ChordType.DIMINISHED;
            } else if (max_index < 48) {
                chord.type = ChordType.SUSPENDED_2;
            } else if (max_index < 60) {
                chord.type = ChordType.SUSPENDED_4;
            } else if (max_index < 72) {
                chord.type = ChordType.AUGMENTED;
            } else if (max_index < 84) {
                chord.type = ChordType.SIXTH;
            } else if (max_index < 96) {
                chord.type = ChordType.SEVENTH;
            } else if (max_index < 108) {
                chord.type = ChordType.MAJOR_7TH;
            } else if (max_index < 120) {
                chord.type = ChordType.MINOR_7TH;
            } else if (max_index < 132) {
                chord.type = ChordType.ADD_9TH;
            } else {
                chord.type = ChordType.NINTH;
            }

            // Set the root note
            if (max > 0) {
                if (max_index >= 0 && max_index <= 6) {
                    chord.root = convert_to_chord (max_index);
                } else if (max_index >= 7 && max_index <= 18) {
                    chord.root = convert_to_chord (max_index - 12);
                } else if (max_index >= 19 && max_index <= 30) {
                    chord.root = convert_to_chord (max_index - 24);
                } else if (max_index >= 31 && max_index <= 42) {
                    chord.root = convert_to_chord (max_index - 36);
                } else if (max_index >= 43 && max_index <= 54) {
                    chord.root = convert_to_chord (max_index - 48);
                } else if (max_index >= 55 && max_index <= 66) {
                    chord.root = convert_to_chord (max_index - 60);
                } else if (max_index >= 67 && max_index <= 78) {
                    chord.root = convert_to_chord (max_index - 72);
                } else if (max_index >= 79 && max_index <= 90) {
                    chord.root = convert_to_chord (max_index - 84);
                } else if (max_index >= 91 && max_index <= 102) {
                    chord.root = convert_to_chord (max_index - 96);
                } else if (max_index >= 103 && max_index <= 114) {
                    chord.root = convert_to_chord (max_index - 108);
                } else if (max_index >= 115 && max_index <= 126) {
                    chord.root = convert_to_chord (max_index - 120);
                } else if (max_index >= 127 && max_index <= 138) {
                    chord.root = convert_to_chord (max_index - 132);
                } else if (max_index >= 139 && max_index <= 156) {
                    chord.root = convert_to_chord (max_index - 150);
                } else {
                    chord.root = ChordRoot.NONE;
                }
            }

            return chord;
        }

        private ChordRoot convert_to_chord (int16 root) {
            switch (root) {
                case 0:
                return ChordRoot.C;
                case 1:
                return ChordRoot.CS;
                case 2:
                return ChordRoot.D;
                case 3:
                return ChordRoot.EF;
                case 4:
                return ChordRoot.E;
                case 5:
                return ChordRoot.F;
                case 6:
                return ChordRoot.FS;
                case -5:
                return ChordRoot.G;
                case -4:
                return ChordRoot.AF;
                case -3:
                return ChordRoot.A;
                case -2:
                return ChordRoot.BF;
                case -1:
                return ChordRoot.B;
            }

            return ChordRoot.NONE;
        }
    }
}
