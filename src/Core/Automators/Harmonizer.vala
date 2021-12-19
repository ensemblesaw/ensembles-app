/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core {
    public class Harmonizer : Object {
        public signal void generate_notes (int key, int on, int velocity);
        public signal void halt_notes ();

        int chord_main;
        int chord_type;

        int[] keys;

        public Harmonizer () {
            keys = new int [60];
        }
        public void set_chord (int chord, int type) {
            chord_type = type;
            int h_type = Ensembles.Application.settings.get_int ("harmonizer-type");

            if (Ensembles.Application.settings.get_boolean ("harmonizer-on")) {
                if (chord_main != chord) {
                    if (h_type > 4) {
                        halt_notes ();
                    }
                    //  for (int i = 0; i < 60; i++) {
                    //      if (keys[i] >= 0) {
                    //          halt_notes ();
                    //          break;
                    //      }
                    //  }
                    chord_main = chord;
                    if (h_type > 4) {
                        for (int i = 0; i < 60; i++) {
                            if (keys[i] > 0) {
                                harmonize (i + 36, 144, keys[i]);
                            }
                        }
                    }
                }
            }
        }

        public void send_notes (int key, int on, int velocity) {
            if (on == 144) {
                keys[key - 36] = velocity;
            } else {
                keys[key - 36] = -1;
            }
            harmonize (key, on, velocity);
        }
        private void harmonize (int key, int on, int velocity) {
            switch (Ensembles.Application.settings.get_int ("harmonizer-type")) {
                case 1:
                harmonize_duet_a (key, on, velocity);
                break;
                case 2:
                harmonize_duet_b (key, on, velocity);
                break;
                case 3:
                harmonize_root (key, on, velocity);
                break;
                case 4:
                harmonize_country (key, on, velocity);
                break;
                case 5:
                harmonize_octave (key, on, velocity);
                break;
                case 6:
                harmonize_fifth (key, on, velocity);
                break;
            }
        }

        private void harmonize_duet_a (int key, int on, int velocity) {
            int root = ((key - 5) / 12) * 12;
            if (root + 9 + chord_main < key) {
                generate_notes (root + 7 + chord_main, on, (int) (velocity * 0.8));
            } else if (root + 6 + chord_main < key) {
                generate_notes (root + ((chord_type == 0) ? 4 : 3) + chord_main, on, (int) (velocity * 0.8));
            } else if (root + 2 + chord_main < key) {
                generate_notes (root + chord_main, on, (int) (velocity * 0.8));
            } else {
                generate_notes (root - 5 + chord_main, on, (int) (velocity * 0.8));
            }
        }

        private void harmonize_duet_b (int key, int on, int velocity) {
            int root = ((key + 15) / 12) * 12;
            if (root - 10 + chord_main > key) {
                generate_notes (root - (chord_type == 0 ? 8 : 9) + chord_main, on, (int) (velocity * 0.8));
            } else if (root - 7 + chord_main < key) {
                generate_notes (root - 5 + chord_main, on, (int) (velocity * 0.8));
            } else {
                generate_notes (root + chord_main, on, (int) (velocity * 0.8));
            }
        }

        private void harmonize_root (int key, int on, int velocity) {
            int root = ((key - 5) / 12) * 12;
            generate_notes (root + chord_main, on, (int) (velocity * 0.8));
        }

        private void harmonize_country (int key, int on, int velocity) {
            int root = ((key + 15) / 12) * 12;
            if (root - 10 + chord_main > key) {
                generate_notes (root - (chord_type == 0 ? 8 : 9) + chord_main, on, (int) (velocity * 0.7));
            }
            if (root - 7 + chord_main < key) {
                generate_notes (root - 5 + chord_main, on, (int) (velocity * 0.7));
            }
            generate_notes (root + chord_main, on, (int) (velocity * 0.5));
        }

        private void harmonize_octave (int key, int on, int velocity) {
            if (key < 94) {
                generate_notes (key + 12, on, (int) (velocity));
            } else {
                generate_notes (key - 12, on, (int) (velocity));
            }
        }

        private void harmonize_fifth (int key, int on, int velocity) {
            if (key >= 48) {
                generate_notes (key - 5, on, (int) (velocity * 0.8));
            } else {
                generate_notes (key + 7, on, (int) (velocity * 0.8));
            }
        }
    }
}
