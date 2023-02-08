/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.PlugIns.LADSPAV2 {
    public class LV2URID {
        public static LV2.URID.Urid map_uri (void* handle, string uri) {
            LADSPAV2.LV2Manager.symap_lock.lock();
            LV2.URID.Urid urid = LADSPAV2.LV2Manager.symap.map (uri);
            LADSPAV2.LV2Manager.symap_lock.unlock ();
            return urid;
        }

        public static string unmap_uri (void* handle, LV2.URID.Urid urid) {
            LADSPAV2.LV2Manager.symap_lock.lock();
            string uri = LADSPAV2.LV2Manager.symap.unmap ((uint32)urid);
            LADSPAV2.LV2Manager.symap_lock.unlock();
            return uri;
        }
    }
}
