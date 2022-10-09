/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core {
    public class Harmonizer : Object {
        public signal void generate_notes (int key, bool is_pressed, int velocity);
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
                    stop_notes ();
                    chord_main = chord;
                    if (h_type > 4) {
                        for (int i = 0; i < 60; i++) {
                            if (keys[i] > 0) {
                                harmonize (i + 36, true, keys[i]);
                            }
                        }
                    }
                }
            }
        }

        public void send_notes (int key, bool is_pressed, int velocity) {
            if (is_pressed) {
                keys[key - 36] = velocity;
            } else {
                keys[key - 36] = -1;
            }
            harmonize (key, is_pressed, velocity);
        }

        private void stop_notes () {
            for (int i = 0; i < 60; i++) {
                if (keys[i] >= 0) {
                    generate_notes (i + 36, false, 0);
                    keys[i] = -1;
                }
            }
        }
        private void harmonize (int key, bool is_pressed, int velocity) {
            switch (Ensembles.Application.settings.get_int ("harmonizer-type")) {
                case 1:
                harmonize_duet_a (key, is_pressed, velocity);
                break;
                case 2:
                harmonize_duet_b (key, is_pressed, velocity);
                break;
                case 3:
                harmonize_root (key, is_pressed, velocity);
                break;
                case 4:
                harmonize_country (key, is_pressed, velocity);
                break;
                case 5:
                harmonize_octave (key, is_pressed, velocity);
                break;
                case 6:
                harmonize_fifth (key, is_pressed, velocity);
                break;
            }
        }

        private void harmonize_duet_a (int key, bool is_pressed, int velocity) {
            int root = ((key - 5) / 12) * 12;
            if (root + 9 + chord_main < key) {
                generate_notes (root + 7 + chord_main, is_pressed, (int) (velocity * 0.8));
            } else if (root + 6 + chord_main < key) {
                generate_notes (root + ((chord_type == 0) ? 4 : 3) + chord_main, is_pressed, (int) (velocity * 0.8));
            } else if (root + 2 + chord_main < key) {
                generate_notes (root + chord_main, is_pressed, (int) (velocity * 0.8));
            } else {
                generate_notes (root - 5 + chord_main, is_pressed, (int) (velocity * 0.8));
            }
        }

        private void harmonize_duet_b (int key, bool is_pressed, int velocity) {
            int root = ((key + 15) / 12) * 12;
            if (root - 10 + chord_main > key) {
                generate_notes (root - (chord_type == 0 ? 8 : 9) + chord_main, is_pressed, (int) (velocity * 0.8));
            } else if (root - 7 + chord_main < key) {
                generate_notes (root - 5 + chord_main, is_pressed, (int) (velocity * 0.8));
            } else {
                generate_notes (root + chord_main, is_pressed, (int) (velocity * 0.8));
            }
        }

        private void harmonize_root (int key, bool is_pressed, int velocity) {
            int root = ((key - 5) / 12) * 12;
            generate_notes (root + chord_main, is_pressed, (int) (velocity * 0.8));
        }

        private void harmonize_country (int key, bool is_pressed, int velocity) {
            int root = ((key + 15) / 12) * 12;
            if (root - 10 + chord_main > key) {
                generate_notes (root - (chord_type == 0 ? 8 : 9) + chord_main, is_pressed, (int) (velocity * 0.7));
            }
            if (root - 7 + chord_main < key) {
                generate_notes (root - 5 + chord_main, is_pressed, (int) (velocity * 0.7));
            }
            generate_notes (root + chord_main, is_pressed, (int) (velocity * 0.5));
        }

        private void harmonize_octave (int key, bool is_pressed, int velocity) {
            if (key < 94) {
                generate_notes (key + 12, is_pressed, (int) (velocity));
            } else {
                generate_notes (key - 12, is_pressed, (int) (velocity));
            }
        }

        private void harmonize_fifth (int key, bool is_pressed, int velocity) {
            if (key >= 48) {
                generate_notes (key - 5, is_pressed, (int) (velocity * 0.8));
            } else {
                generate_notes (key + 7, is_pressed, (int) (velocity * 0.8));
            }
        }
    }
}
