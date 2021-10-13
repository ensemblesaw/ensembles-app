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
    public class PlugIn : Object {
        public bool active = true;
        public string plug_type;
        public string plug_uri;
        public string plug_name;
        public bool plug_has_ui;
        public ControlPort[] control_ports;
        public uint32 source_l_port_index;
        public uint32 sink_l_port_index;
        public uint32 source_r_port_index;
        public uint32 sink_r_port_index;
        public bool stereo_source;
        public bool stereo_sink;
        public string class;

        // LV2
        public Lilv.Plugin lv2_plugin;
        private Lilv.Instance? lv2_instance_l_realtime;
        private Lilv.Instance? lv2_instance_r_realtime;
        private Lilv.Instance? lv2_instance_style;
        private LV2.Feature*[] features;

        // UI
        Hdy.Window plugin_window;
        Gtk.HeaderBar headerbar;
        Shell.Knob main_mixing_knob;
        Gtk.Grid main_grid;

        private float* mixing_amount;

        Gtk.Widget[] widgets;

        private float[] control_variables;

        void make_ui () {
            plugin_window = new Hdy.Window ();
            plugin_window.delete_event.connect (plugin_window.hide_on_delete);
            headerbar = new Gtk.HeaderBar ();
            headerbar.has_subtitle = false;
            headerbar.set_show_close_button (true);
            Gtk.Image app_icon = new Gtk.Image.from_icon_name (
                "com.github.subhadeepjasu.ensembles",
                Gtk.IconSize.DND);
            main_mixing_knob = new Shell.Knob ();
            main_mixing_knob.set_value (1);
            main_mixing_knob.change_value.connect ((_value) => {
                if (mixing_amount != null) {
                    *mixing_amount = _value;
                }
            });
            headerbar.pack_start (app_icon);
            headerbar.pack_end (main_mixing_knob);
            var ui_mode_button = new Granite.Widgets.ModeButton ();
            ui_mode_button.margin_top = 12;
            ui_mode_button.margin_bottom = 12;
            ui_mode_button.append_icon ("preferences-other", Gtk.IconSize.BUTTON);
            ui_mode_button.append_icon ("media-eq", Gtk.IconSize.BUTTON);
            headerbar.pack_end (ui_mode_button);
            var header = new Hdy.WindowHandle ();
            header.expand = true;
            header.add(new Gtk.Label ("𝑓𝑥 " + plug_name + " (" + plug_type + ")"));
            headerbar.set_custom_title (header);
            headerbar.decoration_layout = "close:";
            headerbar.valign = Gtk.Align.START;

            main_grid = new Gtk.Grid ();
            main_grid.margin = 8;
            main_grid.column_spacing = 4;
            main_grid.row_spacing = 4;
            main_grid.valign = Gtk.Align.CENTER;
            main_grid.halign = Gtk.Align.CENTER;

            var scrollable = new Gtk.ScrolledWindow (null, null);
            scrollable.set_size_request (640, 240);
            scrollable.add (main_grid);

            var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            main_box.pack_start (headerbar);
            main_box.pack_end (scrollable);


            plugin_window.add (main_box);

            // Make rest of the plugin UI
            var controls_frame = new Gtk.Frame (_("Controls"));
            var controls_grid = new Gtk.Grid ();
            controls_grid.row_spacing = 4;
            controls_grid.margin = 14;
            controls_frame.add (controls_grid);
            uint len = control_ports.length;
            control_variables = new float [len];
            widgets = new Gtk.Widget [len];

            // Set controls
            for (int i = 0; i < len; i++) {
                var control_ui = new PlugInControl (control_ports[i], &control_variables[i]);
                connect_control_port (&control_variables[i], control_ports[i].port_index, true);
                widgets[i] = control_ui;
                controls_grid.attach (widgets[i], 0, i);
            }
            main_grid.attach (controls_frame, 0, 0);
        }

        public Gtk.Window get_ui () {
            return this.plugin_window;
        }

        public void instantiate_plug (bool realtime, float* mixer_value) {
            mixing_amount = mixer_value;
            if (plug_type == "lv2") {
                if (features_are_supported ()) {
                    if (realtime) {
                        lv2_instance_l_realtime = lv2_plugin.instantiate (44100, features);
                        if (!stereo_source) {
                            lv2_instance_r_realtime = lv2_plugin.instantiate (44100, features);
                        }
                    } else {
                        lv2_instance_style = lv2_plugin.instantiate (44100, features);
                    }
                    make_ui ();
                }
            }
        }

        private void connect_control_port (float* variable, uint32 index, bool? realtime = false) {
            if (plug_type == "lv2") {
                if (realtime) {
                    lv2_instance_l_realtime.connect_port (index, variable);
                    if (!stereo_source) {
                        lv2_instance_r_realtime.connect_port (index, variable);
                    }
                }
            }
        }

        private bool features_are_supported () {
            var lilv_features = lv2_plugin.get_required_features ();
            var feat_iter = lilv_features.begin ();
            while (!lilv_features.is_end (feat_iter)) {
                string feat = lilv_features.get (feat_iter).as_uri ();
                if (feat == "http://lv2plug.in/ns/lv2core#isLive" ||
                    feat == "http://lv2plug.in/ns/lv2core#inPlaceBroken") {
                        return false;
                    }
                feat_iter = lilv_features.next (feat_iter);
            }
            return true;
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
            active = true;
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
            active = false;
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
