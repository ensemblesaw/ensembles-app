/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

 namespace Ensembles.Core.Plugins.AudioPlugins.LADSPAV2 {
    public class LV2ControlPort : LV2Port {
        public float default_value { get; private set; }
        public float min_value { get; private set; }
        public float max_value { get; private set; }
        public float step { get; private set; }

        public LV2ControlPort (string name, uint32 index, owned string[] properties,
        string symbol, string turtle_token = "", float min_value = 0, float max_value = 1,
        float default_value = 0, float step = 0.1f) {
            base (name, index, properties, symbol, turtle_token);
            this.default_value = default_value;
            this.min_value = min_value;
            this.max_value = max_value;
            this.step = step;
        }
    }
}
