/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

 namespace Ensembles.Core.PlugIns.LADSPAV2 {
    public class SyMap {
        private List<string> symbols;
        public SyMap () {
            symbols = new List<string> ();
        }

        public uint32 map (string sym) {
            uint32 index = symbols.index (sym);
            if (index < 0) {
                symbols.append (sym);
                return symbols.length () - 1;
            }

            return index;
        }

        public string unmap (uint32 index) {
            return symbols.nth_data (index);
        }
    }
}
