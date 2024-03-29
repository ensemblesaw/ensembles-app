/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.PlugIns {
    public class PlugInManager : Object {
        private PlugIns.LADSPAV2.LV2Manager lv2_manager;
        public PlugIns.PlugIn[] plugins;
        public PlugInManager () {
            lv2_manager = new PlugIns.LADSPAV2.LV2Manager ();
            lv2_manager.lv2_plugins_found.connect ((plugs) => {
                plugins = new PlugIns.PlugIn [plugs.length ()];
                for (uint i = 0; i < plugs.length (); i++) {
                    plugins[i] = plugs.nth_data (i);
                    if (plugins[i].class == "Instrument Plugin") {
                        /*
                         * @Todo:
                         * Make instrument plugin support
                         */
                         Core.InstrumentRack.populate_rack (plugins[i]);
                    } else if (plugins[i].class == "Reverb Plugin" ||
                            plugins[i].class == "Amplifier Plugin") {
                        Core.EffectRack.populate_rack (plugins[i]);
                    }
                }
                Core.EffectRack.create_plugins ();
            });
        }

        public void discover () {
            lv2_manager.discover ();
        }
    }
}
