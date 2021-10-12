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

 namespace Ensembles.PlugIns.LADSPAV2 {
    public class LV2Manager : Object {
        Lilv.World world;

        public signal void lv2_plugins_found (List<PlugIns.PlugIn> plugins);
        public LV2Manager () {
            world = new Lilv.World ();
        }

        public void discover () {
            if (world != null) {
                get_lv2_plugins ();
            }
        }

        int get_lv2_plugins () {
            print ("get plugs\n");
            var detected_plugins = new List<PlugIns.PlugIn> ();
            world.load_all ();
            var plugins = world.get_all_plugins ();
            var iter = plugins.begin ();
            while (!plugins.is_end (iter)) {
                var plugin = plugins.get (iter);
                if (plugin != null) {
                    string uri = plugin.get_uri ().as_uri ();
                    string name = plugin.get_name ().as_string ();
                    var plug_class = plugin.get_class ().get_label ().as_string ();
                    var features = plugin.get_supported_features ();
                    print ("--------------------------------------------------------\n");
                    print ("%s\n %s, %s\n", uri, name, plug_class);

                    var feature_iter = features.begin ();
                    while (!features.is_end (feature_iter)) {
                        var feature = features.get (feature_iter).as_string ();
                        print (" Feature >>%s\n", feature);
                        feature_iter = features.next (feature_iter);
                    }

                    var n_ports = plugin.get_num_ports ();
                    for (uint i = 0; i < n_ports; i++) {
                        var port = plugin.get_port_by_index (i);
                        print (" Port >>%s | %s\n", plugin.port_get_name (port).as_string (), plugin.port_get_symbol (port).as_string ());
                        print (" Properties:\n");
                        var properties = plugin.port_get_properties (port);
                        var prop_iter = properties.begin ();
                        while (!properties.is_end (prop_iter)) {
                            var prop = properties.get (prop_iter).as_string ();
                            print ("  %s\n", prop);
                            prop_iter = properties.next (prop_iter);
                        }
                        print (" Classes:\n");
                        unowned Lilv.Nodes classes = plugin.port_get_classes (port);
                        var class_iter = classes.begin ();
                        while (!classes.is_end (class_iter)) {
                            var clas = classes.get (class_iter).as_string ();
                            print ("  %s\n", clas);
                            class_iter = classes.next (class_iter);
                        }
                    }

                    var detected_plug = new PlugIns.PlugIn () {
                        name = name,
                        uri = uri,
                        type = "lv2",
                        lv2_plugin = plugin,
                        class = plug_class
                    };

                    detected_plugins.append (detected_plug);
                }
                iter = plugins.next (iter);
            }
            print ("helloooooo\n");
            if (detected_plugins.length () > 0) {
                print ("helloooooo000\n");
                lv2_plugins_found (detected_plugins);
            }
            return 0;
        }
    }
 }
