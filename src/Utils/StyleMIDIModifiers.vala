/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Models;

namespace Ensembles {
    public class StyleMIDIModifers {
        public static int modify_key_by_chord (int key, Chord? chord,
            ChordType style_scale_type, bool alt_channels_active) {
            if (style_scale_type == ChordType.MAJOR) {
                switch (chord.type) {
                    case ChordType.MAJOR:
                        return key + chord.root;
                    case ChordType.MINOR:
                        if (
                            !alt_channels_active && ((key - 4) % 12 == 0 || (key - 9) % 12 == 0 || (key - 11) % 12 == 0)
                        ) {
                            return (key + chord.root - 1);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.DIMINISHED:
                        if ((key - 4) % 12 == 0 || (key - 7) % 12 == 0) {
                            return (key + chord.root - 1);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.SUSPENDED_2:
                        if ((key - 4) % 12 == 0) {
                            return (key + chord.root - 2);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.SUSPENDED_4:
                        if ((key - 4) % 12 == 0) {
                            return (key + chord.root + 1);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.AUGMENTED:
                        if ((key - 2) % 12 == 0 || (key - 7) % 12 == 0) {
                            return (key + chord.root + 1);
                        } else if ((key - 5) % 12 == 0 || (key - 9) % 12 == 0) {
                            return (key + chord.root - 1);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.SIXTH:
                        if ((key - 4) % 12 == 0) {
                            if (Random.int_range (0, 3) > 2) {
                                return (key + chord.root);
                            }

                            return (key + chord.root + 5);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.SEVENTH:
                        if ((key - 4) % 12 == 0) {
                            if (Random.int_range (0, 3) > 2) {
                                return (key + chord.root);
                            }

                            return (key + chord.root + 6);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.MAJOR_7TH:
                        if ((key - 4) % 12 == 0) {
                            if (Random.int_range (0, 3) > 2) {
                                return (key + chord.root);
                            }

                            return (key + chord.root - 5);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.MINOR_7TH:
                        if ((key - 4) % 12 == 0) {
                            if (Random.boolean ()) {
                                return (key + chord.root + 6);
                            }

                            return (key + chord.root - 1);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.ADD_9TH:
                        if ((key - 4) % 12 == 0) {
                            if (Random.int_range (0, 3) > 2) {
                                return (key + chord.root);
                            }

                            return (key + chord.root - 2);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.NINTH:
                        if ((key - 4) % 12 == 0) {
                            if (Random.boolean ()) {
                                return (key + chord.root - 2);
                            }

                            return (key + chord.root);
                        } else if ((key - 7) % 12 == 0) {
                            if (Random.boolean ()) {
                                return (key + chord.root + 3);
                            }
                            return (key + chord.root);
                        } else {
                            return (key + chord.root);
                        }
                }
            } else if (style_scale_type == ChordType.MINOR) {
                switch (chord.type) {
                    case ChordType.MINOR:
                        return (key + chord.root);
                    case ChordType.MAJOR:
                        if (
                            !alt_channels_active && ((key - 3) % 12 == 0 || (key - 8) % 12 == 0 || (key - 10) % 12 == 0)
                        ) {
                            return (key + chord.root + 1);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.DIMINISHED:
                        if ((key - 7) % 12 == 0) {
                            return (key + chord.root - 1);
                        } else if ((key - 8) % 12 == 0 || (key - 10) % 12 == 0) {
                            return (key + chord.root + 1);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.SUSPENDED_2:
                        if ((key - 3) % 12 == 0) {
                            return (key + chord.root - 1);
                        } else if ((key - 8) % 12 == 0 || (key - 10) % 12 == 0) {
                            return (key + chord.root + 1);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.SUSPENDED_4:
                        if ((key - 3) % 12 == 0) {
                            return (key + chord.root + 2);
                        } else if ((key - 8) % 12 == 0 || (key - 10) % 12 == 0) {
                            return (key + chord.root + 1);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.AUGMENTED:
                        if ((key - 7) % 12 == 0) {
                            return (key + chord.root - 1);
                        } else if ((key - 8) % 12 == 0 || (key - 10) % 12 == 0) {
                            return (key + chord.root + 1);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.SIXTH:
                        if ((key - 3) % 12 == 0) {
                            if (Random.int_range (0, 3) > 2) {
                                return (key + chord.root + 1);
                            }

                            return (key + chord.root + 6);
                        } else if ((key - 8) % 12 == 0 || (key - 10) % 12 == 0) {
                            return (key + chord.root + 1);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.SEVENTH:
                        if ((key - 3) % 12 == 0) {
                            if (Random.int_range (0, 3) > 2) {
                                return (key + chord.root + 1);
                            }

                            return (key + chord.root + 7);
                        } else if ((key - 8) % 12 == 0) {
                            return (key + chord.root + 1);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.MAJOR_7TH:
                        if ((key - 3) % 12 == 0) {
                            if (Random.int_range (0, 3) > 2) {
                                return (key + chord.root + 1);
                            }

                            return (key + chord.root + 8);
                        } else if ((key - 8) % 12 == 0 || (key - 10) % 12 == 0) {
                            return (key + chord.root + 1);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.MINOR_7TH:
                        if ((key - 3) % 12 == 0) {
                            if (Random.int_range (0, 3) > 2) {
                                return (key + chord.root);
                            }

                            return (key + chord.root + 7);
                        } else if ((key - 8) % 12 == 0) {
                            return (key + chord.root + 1);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.ADD_9TH:
                        if ((key - 3) % 12 == 0) {
                            if (Random.int_range (0, 3) > 2) {
                                return (key + chord.root + 1);
                            }

                            return (key + chord.root - 2);
                        } else if ((key - 8) % 12 == 0 || (key - 10) % 12 == 0) {
                            return (key + chord.root + 1);
                        } else {
                            return (key + chord.root);
                        }
                    case ChordType.NINTH:
                        if ((key - 3) % 12 == 0) {
                            if (Random.boolean ()) {
                                return (key + chord.root - 1);
                            }
                            return (key + chord.root + 1);
                        } else if ((key - 7) % 12 == 0) {
                            if (Random.boolean ()) {
                                return (key + chord.root + 3);
                            }

                            return (key + chord.root);
                        } else if ((key - 8) % 12 == 0) {
                            return (key + chord.root + 1);
                        } else {
                            return (key + chord.root);
                        }
                }
            }
            return 0;
        }
    }
 }
