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
    public class PlugIn : Gtk.Grid {
        public string plug_type;
        public string plug_uri;
        public string plug_name;
        public bool plug_has_ui;
        public uint32 source_l_port_index;
        public uint32 sink_l_port_index;
        public uint32 source_r_port_index;
        public uint32 sink_r_port_index;
        public bool stereo_source;
        public bool stereo_sink;
        public string class;

        // LV2
        public Lilv.Plugin lv2_plugin;
        public List<weak Lilv.Port> lv2_ports;
        private Lilv.Instance? lv2_instance_l_realtime;
        private Lilv.Instance? lv2_instance_r_realtime;
        private Lilv.Instance? lv2_instance_style;

        private Gtk.Widget[] widgets;

        private float gain = -10;

        construct {
            widgets = new Gtk.Widget [0];
        }

        public void instantiate_plug (bool realtime) {
            if (realtime) {
                if (plug_type == "lv2") {
                    lv2_instance_l_realtime = lv2_plugin.instantiate (44100, null);
                    lv2_instance_l_realtime.connect_port (0, &gain);
                    if (!stereo_source) {
                        lv2_instance_r_realtime = lv2_plugin.instantiate (44100, null);
                        lv2_instance_r_realtime.connect_port (0, &gain);
                    }
                }
            } else {
                if (plug_type == "lv2") {
                    lv2_instance_style = lv2_plugin.instantiate (44100, null);
                }
            }
        }

        public void activate_plug (bool realtime) {
            if (realtime) {
                if (plug_type == "lv2") {
                    if (lv2_instance_l_realtime != null) {
                        lv2_instance_l_realtime.activate ();
                    }
                    if (lv2_instance_r_realtime != null) {
                        lv2_instance_r_realtime.activate ();
                    }
                }
            }
        }

        public void deactivate_plug (bool realtime) {
            if (realtime) {
                if (plug_type == "lv2") {
                    if (lv2_instance_l_realtime != null) {
                        lv2_instance_l_realtime.deactivate ();
                    }
                    if (lv2_instance_r_realtime != null) {
                        lv2_instance_r_realtime.deactivate ();
                    }
                }
            }
        }

        public void process (uint32 sample_count) {
            if (plug_type == "lv2") {
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
        }

        public void connect_source_buffer (void* buffer_l, void* buffer_r) {
            if (plug_type == "lv2") {
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
        }

        public void connect_sink_buffer (void* buffer_l, void* buffer_r) {
            if (plug_type == "lv2") {
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
        }
    }
}
