
/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Models {
    /**
     * Data structure representing voice or timbre data in soundfont
     */
    public struct Voice {
        public uint index;
        public uint8 bank;
        public uint preset;
        public string name;
        public string category;
        public string sf_path;
    }
}
