/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.Plugins.AudioPlugins.LADSPAV2 {
    /**
     * An LV2 Plugin that can be used for DSP or as voices, expanding
     * the standard set of sampled voices that Ensembles come with.
     */
    public class LV2Plugin : Plugins.AudioPlugins.AudioPlugin {
        public Lilv.Plugin lilv_plugin;
        public string plug_uri;

        public unowned Lilv.World world;

        public LV2.Feature*[] features;

        LV2.Feature map_feat;
        LV2.Feature unmap_feat;
        //  LV2.Feature options_feat;
        //  LV2.Feature sched_feature;


        LV2.URID.UridMap urid_map;
        LV2.URID.UridUnmap urid_unmap;

        private Lilv.Instance? lv2_instance_l; // Stereo audio / Mono L Processor
        private Lilv.Instance? lv2_instance_r; // Mono R Processor

        public LV2ControlPort[] control_in_ports;
        public LV2ControlPort[] control_out_ports;

        public LV2Plugin (owned Lilv.Plugin lilv_plugin) throws PluginError {
            if (!features_are_supported ()) {
                throw new PluginError.UNSUPPORTED_FEATURE ("Feature not supported");
            }

            this.lilv_plugin = lilv_plugin;
            name = lilv_plugin.get_name ().as_string ();
            plug_uri = lilv_plugin.get_uri ().as_uri ();
            author_name = lilv_plugin.get_author_name ().as_string ();
            author_email = lilv_plugin.get_author_email ().as_string ();
            author_homepage = lilv_plugin.get_author_homepage ().as_string ();

            type = Type.LV2;
            category = get_category_from_class (lilv_plugin.get_class ().get_label ().as_string ());

            // Get all ports from plugin
            fetch_ports ();

            base ();
        }

        protected override void instantiate () {
            create_features ();

            lv2_instance_l = lilv_plugin.instantiate (44100, features);

            // Check if stereo source
            if (audio_in_ports.length > 1) {
                lv2_instance_r = lilv_plugin.instantiate (44100, features);
            }
        }

        protected override void activate () {
            if (lv2_instance_l != null) {
                lv2_instance_l.activate ();
            }

            if (lv2_instance_r != null) {
                lv2_instance_r.activate ();
            }
        }

        protected override void deactivate () {
            if (lv2_instance_l != null) {
                lv2_instance_l.deactivate ();
            }

            if (lv2_instance_r != null) {
                lv2_instance_r.deactivate ();
            }
        }

        public override void connect_source_buffer (void* in_l, void* in_r) {
            for (uint8 i = 0; i < audio_in_ports.length; i++) {
                if (i % 2 == 0) {
                    if (lv2_instance_l != null) {
                        lv2_instance_l.connect_port (audio_in_ports[i].index, in_l);
                    }
                } else {
                    if (lv2_instance_r != null) {
                        lv2_instance_r.connect_port (audio_in_ports[i].index, in_r);
                    }
                }
            }
        }

        public override void connect_sink_buffer (void* out_l, void* out_r) {
            for (uint8 i = 0; i < audio_out_ports.length; i++) {
                if (i % 2 == 0) {
                    if (lv2_instance_l != null) {
                        lv2_instance_l.connect_port (audio_out_ports[i].index, out_l);
                    }
                } else {
                    if (lv2_instance_r != null) {
                        lv2_instance_r.connect_port (audio_out_ports[i].index, out_r);
                    }
                }
            }
        }

        public override void connect_port (Port port, void* data_pointer) {
            if (lv2_instance_l != null) {
                lv2_instance_l.connect_port (port.index, data_pointer);
            }

            if (lv2_instance_r != null) {
                lv2_instance_r.connect_port (port.index, data_pointer);
            }
        }

        public override void process (uint32 sample_count) {
            if (lv2_instance_l != null) {
                lv2_instance_l.run (sample_count);
            }

            if (lv2_instance_r != null) {
                lv2_instance_r.run (sample_count);
            }
        }

        private Category get_category_from_class (string plugin_class) {
            switch (plugin_class) {
                case "Instrument Plugin":
                    return Category.VOICE;
                case "Amplifier Plugin":
                case "Utility Plugin":
                    return Category.DSP;
            }

            return Category.UNSUPPORTED;
        }

        /**
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

        private bool features_are_supported () {
            var lilv_features = lilv_plugin.get_required_features ();
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

        private LV2.Feature register_feature (string uri, void* data) {
            return LV2.Feature() {
                URI = uri,
                data = data
            };
        }

        private void fetch_ports () {
            var n_ports = lilv_plugin.get_num_ports ();
            for (uint32 i = 0; i < n_ports; i++) {
                // Get port from plugin
                var port = lilv_plugin.get_port_by_index (i);

                // Plugin class flags
                bool is_audio_port = false;
                bool is_input_port = false;
                bool is_output_port = false;
                bool is_control_port = false;
                bool is_atom_port = false;

                // Get all classes associated with this port
                var port_classes = lilv_plugin.port_get_classes (port);

                for (var class_iter = port_classes.begin ();
                !port_classes.is_end (class_iter);
                port_classes.next (class_iter)) {
                    switch (port_classes.get (class_iter).as_string ()) {
                        case LV2.Core._AudioPort:
                            is_audio_port = true;
                        break;
                        case LV2.Core._ControlPort:
                            is_control_port = true;
                        break;
                        case LV2.Atom._AtomPort:
                            is_atom_port = true;
                        break;
                        case LV2.Core._InputPort:
                            is_input_port = true;
                        break;
                        case LV2.Core._OutputPort:
                            is_output_port = true;
                        break;
                    }
                }

                var audio_in_port_list = new List<Port> ();
                var audio_out_port_list = new List<Port> ();
                var control_in_port_list = new List<LV2ControlPort> ();
                var control_out_port_list = new List<LV2ControlPort> ();

                if (is_audio_port) {
                    if (is_input_port) {
                        audio_in_port_list.append (new Port (
                            lilv_plugin.port_get_name (port).as_string (),
                            i
                        ));
                    } else if (is_output_port) {
                        if (audio_out_ports == null) {
                            audio_out_ports = new Port[1];
                        } else {
                            audio_out_ports.resize (audio_out_ports.length + 1);
                        }

                        audio_out_port_list.append (new Port (
                            lilv_plugin.port_get_name (port).as_string (),
                            i
                        ));
                    }
                } else if (is_control_port) {
                    Lilv.Node default_value;
                    Lilv.Node min_value;
                    Lilv.Node max_value;

                    lilv_plugin.port_get_range (port, out default_value, out min_value, out max_value);

                    if (is_input_port) {
                        control_in_port_list.append (new LV2ControlPort (
                            lilv_plugin.port_get_name (port).as_string (),
                            i,
                            get_port_properties (port),
                            lilv_plugin.port_get_symbol (port).as_string (),
                            min_value.as_float (),
                            max_value.as_float (),
                            default_value.as_float ()
                        ));
                    } else if (is_output_port) {
                        control_out_port_list.append (new LV2ControlPort (
                            lilv_plugin.port_get_name (port).as_string (),
                            i,
                            get_port_properties (port),
                            lilv_plugin.port_get_symbol (port).as_string (),
                            min_value.as_float (),
                            max_value.as_float (),
                            default_value.as_float ()
                        ));
                    }
                } else if (is_atom_port) {

                }
            }
        }

        private string[] get_port_properties (Lilv.Port port) {
            var prop_list = new List<string> ();;

            var properties = lilv_plugin.port_get_properties (port);

            for (var props_iter = properties.begin ();
            !properties.is_end (props_iter);
            props_iter = properties.next (props_iter)) {
                var prop = properties.get (props_iter).as_string ();
                print ("  %s\n", prop);
                prop_list.append (prop);
            }

            var n = prop_list.length ();

            var props = new string[n];
            for (uint32 i = 0; i < n; i++) {
                props[i] = prop_list.nth_data (i);
            }
            return props;
        }
    }
}
