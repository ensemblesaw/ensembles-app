/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.Plugins.AudioPlugins.LADSPAV2 {
    public class LV2Port : Port {
        public string[] properties { get; private set; }
        public string symbol { get; private set; }
        public string turtle_token { get; private set; }

        public LV2Port (string name, uint32 index, owned string[] properties,
            string symbol, string turtle_token = "") {
            base (name, index);
            this.symbol = symbol;
            this.turtle_token = turtle_token;
        }
    }
}
