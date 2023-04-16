/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
/*
 * This file incorporates work covered by the following copyright and
 * permission notices:
 *
 * ---
 *
  Copyright 2007-2022 David Robillard <http://drobilla.net>

  Permission to use, copy, modify, and/or distribute this software for any
  purpose with or without fee is hereby granted, provided that the above
  copyright notice and this permission notice appear in all copies.

  THIS SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * ---
 */

namespace Ensembles.Core.Plugins.AudioPlugins.Lv2 {
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

        // URI -> Lilv Node Mapping
        internal static unowned Lilv.Node get_node_by_uri (string uri) {
            if (node_map.contains (uri)) {
                return node_map.get (uri);
            }

            return add_node_uri (uri);
        }

        internal static unowned Lilv.Node add_node_uri (string uri) {
            node_map.insert (uri, new Lilv.Node.uri (world, uri));
            return node_map.get (uri);
        }

        // LV2 URID
        internal static LV2.URID.Urid map_uri (void* handle, string uri) {
            Lv2.LV2Manager.symap_lock.lock ();
            LV2.URID.Urid urid = Lv2.LV2Manager.symap.map (uri);
            Lv2.LV2Manager.symap_lock.unlock ();
            return urid;
        }

        internal static string unmap_uri (void* handle, LV2.URID.Urid urid) {
            Lv2.LV2Manager.symap_lock.lock ();
            string uri = Lv2.LV2Manager.symap.unmap ((uint32)urid);
            Lv2.LV2Manager.symap_lock.unlock ();
            return uri;
        }

    }
}
