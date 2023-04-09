/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.Plugins.AudioPlugins.LADSPAV2 {
    /**
     * The LV2 Manager object manages LV2 Plugins.
     */
    public class LV2Manager : Object {
        internal static Lilv.World world = new Lilv.World ();

        internal static SyMap symap = new SyMap ();
        internal static Mutex symap_lock = Mutex ();

        internal static HashTable<string, Lilv.Node> node_map =
        new HashTable<string, Lilv.Node> (
            str_hash,
            (k1, k2) => {
                return k1 == k2;
            }
        );

        public void load_plugins (PluginManager plugin_manager) {
            assert (world != null);

            Console.log ("Loading LV2 Plugins…");
            world.load_all ();

            var plugins = world.get_all_plugins ();

            for (var iter = plugins.begin (); !plugins.is_end (iter); iter = plugins.next (iter)) {
                var lilv_plugin = plugins.get (iter);

                if (lilv_plugin != null) {
                    Thread.usleep (10000);

                    try {
                        var plugin = new LV2Plugin (lilv_plugin);
                        plugin_manager.audio_plugins.append (plugin);
                    } catch (PluginError e) {
                        Console.log (
                            "Skipped LV2 plugin: " +
                                lilv_plugin.get_uri ().as_uri (),
                            Console.LogLevel.WARNING
                        );
                    }
                }
            }

            Console.log (
                "LV2 Plugins Loaded Successfully!",
                Console.LogLevel.SUCCESS
            );
        }

        internal static unowned Lilv.Node get_node (string uri) {
            if (node_map.contains (uri)) {
                return node_map.get (uri);
            }

            return add_node_uri (uri);
        }

        internal static unowned Lilv.Node add_node_uri (string uri) {
            node_map.insert (uri, new Lilv.Node.uri (world, uri));
            return node_map.get (uri);
        }
    }
}
