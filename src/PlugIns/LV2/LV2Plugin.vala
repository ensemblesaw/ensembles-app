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
        public unowned LV2.Feature*[] features;

        public LV2Plugin () {
            plug_type = "lv2";
        }

        public override void instantiate_plug(bool realtime, float* mixer_value) {
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

        protected override Gtk.Widget get_plugin_ui () {
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
