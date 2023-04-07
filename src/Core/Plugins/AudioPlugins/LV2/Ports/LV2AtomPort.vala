/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.Plugins.AudioPlugins.LADSPAV2 {
    public class LV2AtomPort : LV2Port {
        public LV2AtomPort (string name, uint32 index, owned string[] properties,
        string symbol, string turtle_token = "") {
            base (name, index, properties, symbol, turtle_token);
        }
    }
}
