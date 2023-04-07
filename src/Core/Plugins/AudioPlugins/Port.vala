/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.Plugins.AudioPlugins {
    public class Port : Object {
        public string name { get; private set; }
        public uint32 index { get; private set; }

        public Port (string name, uint32 index) {
            this.name = name;
            this.index = index;
        }
    }
}
