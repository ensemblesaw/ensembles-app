/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.Plugins.AudioPlugins.LADSPAV2 {
    public class LV2AtomPort : LV2Port {
        [Flags]
        public enum Flags {
            NONE,
            SEQUENCE,
            SUPPORTS_MIDI_EVENT
        }

        public Flags flags { get; private set; }

        public LV2AtomPort (string name, uint32 index, owned string[] properties,
        string symbol, string turtle_token = "", Flags flags) {
            base (name, index, properties, symbol, turtle_token);
            this.flags = flags;
        }
    }
}
