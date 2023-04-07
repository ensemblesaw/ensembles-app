
/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Models {
    public struct Registry {
        public Voice voice_r1;
        public Voice voice_r2;
        public Voice voice_l;
        public Style style;
        public uint8 tempo;
        public int8 transpose;
        public bool transpose_active;
        public int8 octave_shift;
        public bool octave_shift_active;
        public uint8 reverb_level;
        public bool reverb_active;
        public uint8 chorus_level;
        public bool chorus_active;
        public bool accomp_active;
        public bool layer_active;
        public bool split_active;
        public uint8 harmonizer_type;
        public bool harmnonizer_active;
        public uint8 arpeggiator_type;
        public bool arperggiator_active;
    }
}
