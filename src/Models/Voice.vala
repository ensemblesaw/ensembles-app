
/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles {
    /**
     * Describes which hand is playing the voice
     */
    public enum VoiceHandPosition {
        /** Playing on left hand of split */
        LEFT,
        /** Playing on right hand of split as the main voice*/
        RIGHT,
        /** Playing on the right side of split layered with main voice */
        RIGHT_LAYERED
    }

    namespace Models {
        /**
        * Data structure representing voice or timbre data in soundfont
        */
        public struct Voice {
            public uint index;
            public uint8 bank;
            public uint8 preset;
            public string name;
            public string category;
            public string sf_path;
        }
    }
}
