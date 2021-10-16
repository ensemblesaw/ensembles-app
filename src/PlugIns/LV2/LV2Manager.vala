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
        LV2.Feature*[] supported_features;

        public signal void lv2_plugins_found (List<PlugIns.PlugIn> plugins);

        private static SyMap symap;

        public static LV2.URID.Urid map_uri (void* handle, string uri) {
            return symap.map (uri);
        }

        public static string unmap_uri (void* handle, LV2.URID.Urid urid) {
            return symap.unmap ((uint32)urid);
        }

        LV2.Feature map_feat;

        LV2.URID.UridMap urid_map;

        public LV2Manager () {
            world = new Lilv.World ();
            symap = new SyMap ();

            urid_map = LV2.URID.UridMap ();
            urid_map.handle = this;
            urid_map.map = map_uri;


            supported_features = new LV2.Feature* [1];
            map_feat = LV2.Feature () {
                URI = "http://lv2plug.in/ns/ext/urid#map",
                data = &urid_map
            };

            supported_features[0] = &map_feat;
        }

        public void discover () {
            if (world != null) {
                get_lv2_plugins ();
            }
        }

        int get_lv2_plugins () {
            // print ("get plugs\n");
            var detected_plugins = new List<PlugIns.PlugIn> ();
            world.load_all ();
            var plugins = world.get_all_plugins ();
            var iter = plugins.begin ();
            while (!plugins.is_end (iter)) {
                var plugin = plugins.get (iter);
                if (plugin != null) {
                    string uri = plugin.get_uri ().as_uri ();
                    var plug_name = plugin.get_name ().as_string ();
                    var plug_class = plugin.get_class ().get_label ().as_string ();
                    //var features = plugin.get_required_features ();
                    print ("--------------------------------------------------------\n");
                    print ("%s\n %s, %s\n", uri, plug_name, plug_class);
                    var valid = features_are_supported (plugin);

                    var n_ports = plugin.get_num_ports ();
                    List<Lilv.Port> all_ports = new List<Lilv.Port> ();
                    var control_ports = new ControlPort [0];
                    var atom_ports = new AtomPort [0];
                    uint32 source_l_port_index = -1;
                    uint32 sink_l_port_index = -1;
                    uint32 source_r_port_index = -1;
                    uint32 sink_r_port_index = -1;
                    uint32 source_audio_port_count = 0;
                    uint32 sink_audio_port_count = 0;
                    bool stereo_source = false;
                    bool stereo_sink = false;
                    string[] port_symbols = new string[n_ports];
                    for (uint i = 0; i < n_ports; i++) {
                        var port = plugin.get_port_by_index (i);
                        all_ports.append (port);
                        print (" Port >>%s | %s\n", plugin.port_get_name (port).as_string (), plugin.port_get_symbol (port).as_string ());
                        print (" Properties:\n");
                        port_symbols[i] = plugin.port_get_symbol (port).as_string ();
                        var properties = plugin.port_get_properties (port);
                        var prop_iter = properties.begin ();
                        string prop_string = "";
                        while (!properties.is_end (prop_iter)) {
                            var prop = properties.get (prop_iter).as_string ();
                            print ("  %s\n", prop);
                            prop_string += prop + ",";
                            prop_iter = properties.next (prop_iter);
                        }
                        Lilv.Node default_value;
                        Lilv.Node min_value;
                        Lilv.Node max_value;
                        plugin.port_get_range (port, out default_value, out min_value, out max_value);
                        print (" Classes:\n");
                        unowned Lilv.Nodes classes = plugin.port_get_classes (port);
                        var class_iter = classes.begin ();
                        bool audio_port = false;
                        bool input_port = false;
                        bool output_port = false;
                        bool control_port = false;
                        bool atom_port = false;
                        while (!classes.is_end (class_iter)) {
                            var clas = classes.get (class_iter).as_string ();
                            print ("  %s\n", clas);
                            if (clas == "http://lv2plug.in/ns/lv2core#AudioPort") {
                                audio_port = true;
                            }
                            if (clas == "http://lv2plug.in/ns/lv2core#InputPort") {
                                input_port = true;
                            }
                            if (clas == "http://lv2plug.in/ns/lv2core#OutputPort") {
                                output_port = true;
                            }
                            if (clas == "http://lv2plug.in/ns/lv2core#ControlPort") {
                                control_port = true;
                            }
                            if (clas == "http://lv2plug.in/ns/ext/atom#AtomPort") {
                                atom_port = true;
                            }
                            class_iter = classes.next (class_iter);
                        }

                        if (audio_port) {
                            if (input_port) {
                                if (source_audio_port_count > 0) {
                                    source_r_port_index = i;
                                    stereo_source = true;
                                } else {
                                    source_l_port_index = i;
                                }
                                source_audio_port_count++;
                            } else if (output_port) {
                                if (sink_audio_port_count > 0) {
                                    sink_r_port_index = i;
                                    stereo_sink = true;
                                } else {
                                    sink_l_port_index = i;
                                }
                                sink_audio_port_count++;
                            }
                        }
                        if (control_port && input_port) {
                            control_ports.resize (control_ports.length + 1);
                            control_ports[control_ports.length - 1] = new ControlPort () {
                                name = plugin.port_get_name (port).as_string (),
                                port_index = i,
                                properties = prop_string,
                                default_value = default_value.as_float (),
                                min_value = min_value.as_float (),
                                max_value = max_value.as_float ()
                            };
                        }
                        if (atom_port && input_port) {
                            atom_ports.resize (atom_ports.length + 1);
                            atom_ports[atom_ports.length - 1] = new AtomPort () {
                                name = plugin.port_get_name (port).as_string (),
                                port_index = i,
                                properties = prop_string
                            };
                        }
                    }

                    var detected_plug = new PlugIns.PlugIn () {
                        world = world,
                        valid = valid,
                        plug_name = plug_name,
                        plug_uri = uri,
                        plug_type = "lv2",
                        lv2_plugin = plugin,
                        class = plug_class,
                        source_l_port_index = source_l_port_index,
                        sink_l_port_index = sink_l_port_index,
                        source_r_port_index = source_r_port_index,
                        sink_r_port_index = sink_r_port_index,
                        stereo_source = stereo_source,
                        control_ports = control_ports,
                        atom_ports = atom_ports,
                        port_symbols = port_symbols,
                        features = supported_features
                    };

                    detected_plugins.append (detected_plug);
                }
                iter = plugins.next (iter);
            }
            if (detected_plugins.length () > 0) {
                lv2_plugins_found (detected_plugins);
            }
            return 0;
        }

        private bool features_are_supported (Lilv.Plugin? plugin) {
            var lilv_features = plugin.get_required_features ();
            var feat_iter = lilv_features.begin ();
            while (!lilv_features.is_end (feat_iter)) {
                string feat = lilv_features.get (feat_iter).as_uri ();
                print (">>>>%s\n", feat);
                if (feat == "") {
                        return false;
                    }
                feat_iter = lilv_features.next (feat_iter);
            }
            return true;
        }
    }
 }
