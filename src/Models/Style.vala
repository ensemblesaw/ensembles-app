
/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Models {
    /**
     * Data structure representing auto accompaniment styles
     */
    public struct Style {
        public string name;
        public string genre;
        public uint8 tempo;
        public uint8 time_signature_n;
        public uint8 time_signature_d;
        public string enstl_path;
        public string copyright_notice;
    }
}
