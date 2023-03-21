/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.Plugins.AudioPlugins.LADSPAV2 {
    public class LV2Manager : Object {
        Lilv.World world;

        internal static SyMap symap = new SyMap ();
        internal static Mutex symap_lock = Mutex ();

        List<LV2Plugin> lv2_plugins;

        construct {
            world = new Lilv.World ();
        }

        public void load_plugins (List<unowned AudioPlugin> audio_plugin_list) {
            assert (world != null);

            lv2_plugins = new List<LV2Plugin> ();

            Console.log ("Loading LV2 Plugins...");
            world.load_all ();

            var plugins = world.get_all_plugins ();

            for (var iter = plugins.begin (); !plugins.is_end (iter); iter = plugins.next (iter)) {
                var lilv_plugin = plugins.get (iter);

                if (lilv_plugin != null) {
                    Thread.usleep (10000);

                    try {
                        var plugin = new LV2Plugin (lilv_plugin);
                        lv2_plugins.append (plugin);
                        audio_plugin_list.append (plugin);
                    } catch (PluginError e) {
                        Console.log ("Skipped LV2 plugin: " + lilv_plugin.get_uri ().as_uri (),
                        Console.LogLevel.WARNING);
                    }
                }
            }

            Console.log ("LV2 Plugins Loaded Successfully!", Console.LogLevel.SUCCESS);
        }
    }
}
