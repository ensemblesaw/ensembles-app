/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.PlugIns {
    public class PlugIn : Object {
        public bool active = true;
        public bool valid;
        public string plug_type;
        public string plug_uri;
        public string plug_name;
        public bool plug_has_ui;
        public ControlPort[] control_ports;
        public AtomPort[] atom_ports;
        public uint32 source_l_port_index;
        public uint32 sink_l_port_index;
        public uint32 source_r_port_index;
        public uint32 sink_r_port_index;
        public bool stereo_source;
        public bool stereo_sink;
        public string class;

        // LV2
        public unowned Lilv.World world;
        public Lilv.Plugin lv2_plugin;
        private Lilv.Instance? lv2_instance_l_realtime;
        private Lilv.Instance? lv2_instance_r_realtime;
        private Lilv.Instance? lv2_instance_style;
        public string[] port_symbols;
        public unowned LV2.Feature*[] features;

        // UI
        Hdy.Window plugin_window;
        Gtk.HeaderBar headerbar;
        Shell.Knob main_mixing_knob;
        Gtk.Grid main_grid;

        private float* mixing_amount;

        Gtk.Widget[] control_widgets;
        Gtk.Widget[] atom_widgets;

        private float[] control_variables;
        private LV2.Atom.Atom[] atom_variables;

        void make_ui () {
            plugin_window = new Hdy.Window ();
            plugin_window.delete_event.connect (plugin_window.hide_on_delete);
            headerbar = new Gtk.HeaderBar ();
            headerbar.has_subtitle = false;
            headerbar.set_show_close_button (true);
            Gtk.Image app_icon = new Gtk.Image.from_icon_name (
                "com.github.subhadeepjasu.ensembles",
                Gtk.IconSize.DND);
            app_icon.margin_top = 8;
            app_icon.margin_bottom = 8;
            main_mixing_knob = new Shell.Knob ();
            main_mixing_knob.set_value (1);
            main_mixing_knob.change_value.connect ((_value) => {
                if (mixing_amount != null) {
                    *mixing_amount = _value;
                }
            });
            headerbar.pack_start (app_icon);
            headerbar.pack_end (main_mixing_knob);
            Granite.Widgets.ModeButton ui_mode_button = new Granite.Widgets.ModeButton ();

            var header = new Hdy.WindowHandle ();
            header.expand = true;
            var header_title = new Gtk.Label ("𝑓𝑥 " + plug_name + " (" + plug_type + ")");
            header_title.height_request = 48;
            header.add (header_title);
            headerbar.set_custom_title (header);
            headerbar.decoration_layout = "close:";
            headerbar.valign = Gtk.Align.START;

            main_grid = new Gtk.Grid ();
            main_grid.margin = 8;
            main_grid.column_spacing = 4;
            main_grid.row_spacing = 4;
            main_grid.valign = Gtk.Align.CENTER;
            main_grid.halign = Gtk.Align.CENTER;

            // Plugin's own UI system
            var plug_uis = lv2_plugin.get_uis ();

            var plug_ui_grid = new Gtk.Grid ();

            var ui_iter = plug_uis.begin ();
            Lilv.UI main_ui = null;
            Lilv.Node ui_type = null;
            Gtk.Widget suil_widget = null;
            while (!plug_uis.is_end (ui_iter)) {
                var plug_ui = plug_uis.get (ui_iter);
                if (plug_ui != null && native_ui_supported (plug_ui, out ui_type)) {
                    main_ui = plug_ui;
                    break;
                }
                ui_iter = plug_uis.next (ui_iter);
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
                    lv2_plugin.get_uri ().as_uri (),
                    main_ui.get_uri ().as_uri (),
                    ui_type.as_uri (),
                    bundle_path,
                    binary_path,
                    features
                );

                if (ui_instance != null) {
                    suil_widget = (Gtk.Widget)(ui_instance.get_widget ());
                    if (suil_widget != null) {
                        plug_ui_grid.attach (suil_widget, 0, 0);

                        ui_mode_button.append_icon ("preferences-other", Gtk.IconSize.BUTTON);
                        ui_mode_button.append_icon ("media-eq", Gtk.IconSize.BUTTON);
                        ui_mode_button.set_active (0);
                        headerbar.pack_end (ui_mode_button);
                    }
                }

            } else {
                print ("/////UI:None\n");
            }


            var main_stack = new Gtk.Stack ();

            main_stack.add_named (main_grid, "backend_ui");
            main_stack.add_named (plug_ui_grid, "frontend_ui");
            main_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

            ui_mode_button.mode_changed.connect (() => {
                switch (ui_mode_button.selected) {
                    case 0:
                    main_stack.set_visible_child (main_grid);
                    break;
                    case 1:
                    main_stack.set_visible_child (plug_ui_grid);
                    break;
                }
            });


            var scrollable = new Gtk.ScrolledWindow (null, null);
            scrollable.set_size_request (640, 240);
            scrollable.add (main_stack);

            var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            main_box.pack_start (headerbar);
            main_box.pack_end (scrollable);


            plugin_window.add (main_box);

            // Make rest of the plugin UI
            uint controls_len = control_ports.length;
            control_variables = new float [controls_len];
            control_widgets = new Gtk.Widget [controls_len];


            if (controls_len > 0) {
                // Set controls
                var controls_frame = new Gtk.Frame (_("Controls"));
                var controls_grid = new Gtk.Grid ();
                controls_grid.row_spacing = 4;
                controls_grid.margin = 14;
                controls_frame.add (controls_grid);
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
                var atoms_grid = new Gtk.Grid ();
                atoms_grid.row_spacing = 4;
                atoms_grid.margin = 14;
                atoms_frame.add (atoms_grid);
                for (int i = 0; i < atoms_len; i++) {
                    var control_ui = new PlugInAtom (atom_ports[i], &atom_variables[i]);
                    connect_control_port (&atom_variables[i], atom_ports[i].port_index, true);
                    atom_widgets[i] = control_ui;
                    atoms_grid.attach (atom_widgets[i], 0, i);
                }
                main_grid.attach (atoms_frame, 1, 0);
            }
        }

        public Gtk.Window get_ui () {
            return this.plugin_window;
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
            var plugin_handle = (PlugIn)handle;
            for (int i = 0; i < plugin_handle.port_symbols.length; i++) {
                if (plugin_handle.port_symbols[i] == symbol) {
                    return i;
                }
            }
            return -1;
        }

        public void instantiate_plug (bool realtime, float* mixer_value) {
            mixing_amount = mixer_value;
            if (plug_type == "lv2") {
                if (realtime) {
                    lv2_instance_l_realtime = lv2_plugin.instantiate (44100, features);
                    if (!stereo_source) {
                        lv2_instance_r_realtime = lv2_plugin.instantiate (44100, features);
                    }
                } else {
                    lv2_instance_style = lv2_plugin.instantiate (44100, features);
                }
                deactivate_plug (realtime);
                make_ui ();
            }
        }

        private void connect_control_port (void* variable, uint32 index, bool? realtime = false) {
            if (plug_type == "lv2") {
                if (realtime) {
                    lv2_instance_l_realtime.connect_port (index, variable);
                    if (!stereo_source) {
                        lv2_instance_r_realtime.connect_port (index, variable);
                    }
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
