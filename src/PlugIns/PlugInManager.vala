/*-
 * Copyright (c) 2021-2022 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
 */

namespace Ensembles.PlugIns {
    public class PlugInManager : Object {
        private PlugIns.LADSPAV2.LV2Manager lv2_manager;
        public PlugIns.PlugIn[] plugins;
        public signal void all_plugins_loaded ();
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
                    } else if (plugins[i].class == "Reverb Plugin" ||
                            plugins[i].class == "Amplifier Plugin") {
                        Core.EffectRack.populate_rack (plugins[i]);
                    }
                }
                Core.EffectRack.create_plugins ();
                Idle.add (() => {
                    all_plugins_loaded ();
                    return false;
                });
            });
            lv2_manager.discover ();
        }
    }
}
