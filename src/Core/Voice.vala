/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core {
    public class Voice : Object {
        public int index;
        public int bank;
        public int preset;
        public string name;
        public string category;
        public Voice (int index, int bank, int preset, string name, string category) {
            this.index = index;
            this.bank = bank;
            this.preset = preset;
            this.name = name;
            this.category = category;
        }
    }
}
