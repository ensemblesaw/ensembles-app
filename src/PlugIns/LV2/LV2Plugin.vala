/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

 namespace Ensembles.PlugIns.LADSPAV2 {
    public class LV2Plugin : PlugIn {

        public unowned Lilv.World world;
        public Lilv.Plugin lilv_plugin;
        private Lilv.Instance? lv2_instance_l_realtime;
        private Lilv.Instance? lv2_instance_r_realtime;
        private Lilv.Instance? lv2_instance_style;
        public string[] port_symbols;
        public LV2.Feature*[] features;

        LV2.Feature map_feat;
        LV2.Feature unmap_feat;
        LV2.Feature options_feat;
        LV2.Feature sched_feature;


        LV2.URID.UridMap urid_map;
        LV2.URID.UridUnmap urid_unmap;


        public LV2Plugin () {
            plug_type = "lv2";
        }

        /*
         * Create plugin features
         */
         private void create_features () {
            urid_map = LV2.URID.UridMap ();
            urid_map.handle = this;
            urid_map.map = LV2URID.map_uri;
            urid_unmap = LV2.URID.UridUnmap ();
            urid_unmap.handle = this;
            urid_unmap.unmap = LV2URID.unmap_uri;

            features = new LV2.Feature* [2];
            map_feat = register_feature (LV2.URID._map, &urid_map);
            unmap_feat = register_feature (LV2.URID._unmap, &urid_unmap);

            features[0] = &map_feat;
            features[1] = &unmap_feat;
        }

        private LV2.Feature register_feature (string uri, void* data) {
            return LV2.Feature() {
                URI = uri,
                data = data
            };
        }

        public override void instantiate_plug(bool realtime, float* mixer_value) {
            create_features ();
            if (realtime) {
                lv2_instance_l_realtime = lilv_plugin.instantiate (44100, features);
                if (!stereo_source) {
                    lv2_instance_r_realtime = lilv_plugin.instantiate (44100, features);
                }
            } else {
                lv2_instance_style = lilv_plugin.instantiate (44100, features);
            }
            base.instantiate_plug (realtime, mixer_value);
        }

        public override void connect_control_port (void* variable, uint32 index, bool? realtime = false) {
            if (realtime) {
                lv2_instance_l_realtime.connect_port (index, variable);
                if (!stereo_source) {
                    lv2_instance_r_realtime.connect_port (index, variable);
                }
            }
        }

        public override void activate_plug (bool realtime) {
            if (realtime) {
                if (lv2_instance_l_realtime != null) {
                    lv2_instance_l_realtime.activate ();
                }

                if (lv2_instance_r_realtime != null) {
                    lv2_instance_r_realtime.activate ();
                }
            }

            base.activate_plug (realtime);
        }

        public override void deactivate_plug (bool realtime) {
            if (realtime) {
                    if (lv2_instance_l_realtime != null) {
                        lv2_instance_l_realtime.deactivate ();
                    }

                    if (lv2_instance_r_realtime != null) {
                        lv2_instance_r_realtime.deactivate ();
                    }
            }

            base.deactivate_plug (realtime);
        }

        public override void connect_source_buffer (void* buffer_l, void* buffer_r) {
            if (stereo_source) {
                if (lv2_instance_l_realtime != null) {
                    lv2_instance_l_realtime.connect_port (source_l_port_index, buffer_l);
                    lv2_instance_l_realtime.connect_port (source_r_port_index, buffer_r);
                }
            } else {
                if (lv2_instance_l_realtime != null) {
                    lv2_instance_l_realtime.connect_port (source_l_port_index, buffer_l);
                    lv2_instance_r_realtime.connect_port (source_l_port_index, buffer_r);
                }
            }
        }

        public override void connect_sink_buffer (void* buffer_l, void* buffer_r) {
            if (stereo_source) {
                if (lv2_instance_l_realtime != null) {
                    lv2_instance_l_realtime.connect_port (sink_l_port_index, buffer_l);
                    lv2_instance_l_realtime.connect_port (sink_r_port_index, buffer_r);
                }
            } else {
                if (lv2_instance_l_realtime != null) {
                    lv2_instance_l_realtime.connect_port (sink_l_port_index, buffer_l);
                    lv2_instance_r_realtime.connect_port (sink_l_port_index, buffer_r);
                }
            }
        }

        public override void process (uint32 sample_count) {
            if (stereo_source) {
                if (lv2_instance_l_realtime != null) {
                    lv2_instance_l_realtime.run (sample_count);
                }
            } else {
                if (lv2_instance_l_realtime != null && lv2_instance_r_realtime != null) {
                    lv2_instance_l_realtime.run (sample_count);
                    lv2_instance_r_realtime.run (sample_count);
                }
            }
        }

        protected override Gtk.Grid get_plugin_native_ui () {
            var main_grid = new Gtk.Grid () {
                column_spacing = 4,
                row_spacing = 4,
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.CENTER
            };

            // Make rest of the plugin UI
            uint controls_len = control_ports.length;
            control_variables = new float [controls_len];
            control_widgets = new Gtk.Widget [controls_len];


            if (controls_len > 0) {
                // Set controls
                var controls_frame = new Gtk.Frame (_("Controls"));
                var controls_grid = new Gtk.Grid () {
                    row_spacing = 4,
                    margin_top = 14,
                    margin_bottom = 14,
                    margin_start = 14,
                    margin_end = 14
                };
                controls_frame.set_child (controls_grid);
                for (int i = 0; i < controls_len; i++) {
                    var control_ui = new PlugInControl (control_ports[i], &control_variables[i]);
                    connect_control_port (&control_variables[i], control_ports[i].port_index, true);
                    control_widgets[i] = control_ui;
                    controls_grid.attach (control_widgets[i], 0, i);
                }
                main_grid.attach (controls_frame, 0, 0);
            }

            uint atoms_len = atom_ports.length;
            atom_variables = new LV2.Atom.Atom [atoms_len];
            atom_widgets = new Gtk.Widget [atoms_len];

            if (atoms_len > 0) {
                // Set Atoms
                var atoms_frame = new Gtk.Frame (_("Atoms"));
                var atoms_grid = new Gtk.Grid () {
                    row_spacing = 4,
                    margin_top = 14,
                    margin_bottom = 14,
                    margin_start = 14,
                    margin_end = 14
                };
                atoms_frame.set_child (atoms_grid);
                for (int i = 0; i < atoms_len; i++) {
                    var control_ui = new PlugInAtom (atom_ports[i], &atom_variables[i]);
                    connect_control_port (&atom_variables[i], atom_ports[i].port_index, true);
                    atom_widgets[i] = control_ui;
                    atoms_grid.attach (atom_widgets[i], 0, i);
                }
                main_grid.attach (atoms_frame, 1, 0);
            }

            return main_grid;
        }

        protected override Gtk.Widget get_plugin_custom_ui () {
            var plug_uis = lilv_plugin.get_uis ();

            Lilv.UI main_ui = null;
            Lilv.Node ui_type = null;
            Gtk.Widget suil_widget = null;
            for (var ui_iter = plug_uis.begin (); !plug_uis.is_end (ui_iter); ui_iter = plug_uis.next (ui_iter)) {
                var plug_ui = plug_uis.get (ui_iter);
                if (plug_ui != null && native_ui_supported (plug_ui, out ui_type)) {
                    main_ui = plug_ui;
                    break;
                }
            }
            if (main_ui != null) {
                unowned Lilv.Node ui_uri = main_ui.get_uri ();
                print ("/////UI:%s\n", ui_uri.as_uri ());
                string bundle = main_ui.get_bundle_uri ().as_uri ();
                string binary = main_ui.get_binary_uri ().as_uri ();
                string bundle_path = Lilv.Node.file_uri_parse (bundle, null);
                string binary_path = Lilv.Node.file_uri_parse (binary, null);

                var host = new Suil.Host (ui_write, port_index_by_symbol, null, null);

                Suil.Instance ui_instance = new Suil.Instance (
                    host,
                    (Suil.Controller)this,
                    "http://lv2plug.in/ns/extensions/ui#Gtk3UI",
                    lilv_plugin.get_uri ().as_uri (),
                    main_ui.get_uri ().as_uri (),
                    ui_type.as_uri (),
                    bundle_path,
                    binary_path,
                    features
                );

                if (ui_instance != null) {
                    suil_widget = (Gtk.Widget)(ui_instance.get_widget ());
                    if (suil_widget != null) {
                        return suil_widget;
                    }
                }

            } else {
                print ("/////UI:None\n");
            }

            return null;
        }

        private bool native_ui_supported (Lilv.UI ui, out Lilv.Node ui_type) {
            var ui_type_node = new Lilv.Node.uri (world, "http://lv2plug.in/ns/extensions/ui#Gtk3UI");
            uint supported = ui.is_supported (Suil.ui_supported, ui_type_node, out ui_type);
            return supported == 0 ? false : true;
        }

        private static void ui_write (
            Suil.Controller handle,
            uint32 port_index,
            uint32 buffer_size,
            uint32 protocol,
            void* buffer
        ) {
            /* Not Implemented */
            if (protocol != 0) {
                return;
            }
        }

        private static uint32 port_index_by_symbol (Suil.Controller handle, string symbol) {
            var plugin_handle = (LV2Plugin)handle;
            for (int i = 0; i < plugin_handle.port_symbols.length; i++) {
                if (plugin_handle.port_symbols[i] == symbol) {
                    return i;
                }
            }
            return -1;
        }
    }
 }
