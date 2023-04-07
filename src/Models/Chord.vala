/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Models {
    /**
     * Represents root note of chord
     */
    public enum ChordRoot {
        C = 0,
        CS = 1,
        D = 2,
        EF = 3,
        E = 4,
        F = 5,
        FS = 6,
        G = -5,
        AF = -4,
        A = -3,
        BF = -2,
        B = -1,
        NONE = -6;
    }

    /**
     * Represents the type of chord
     */
    public enum ChordType {
        MAJOR = 0,
        MINOR = 1,
        DIMINISHED = 2,
        SUSPENDED_2 = 3,
        SUSPENDED_4 = 4,
        AUGMENTED = 5,
        SIXTH = 6,
        SEVENTH = 7,
        MAJOR_7TH = 8,
        MINOR_7TH = 9,
        ADD_9TH = 10,
        NINTH = 11
    }

    /**
     * Represents musical chords
     */
    public struct Chord {
        public ChordRoot root;
        public ChordType type;
    }
}
