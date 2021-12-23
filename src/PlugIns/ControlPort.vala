/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.PlugIns {
    public class ControlPort : Object {
        public string name;
        public uint32 port_index;
        public string properties;
        public float default_value;
        public float min_value;
        public float max_value;
    }
}
