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
        public uint32 sample_rate;
        public bool stereo_source;
        public bool stereo_sink;
        public string class;

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

        protected virtual Gtk.Widget get_plugin_ui () {
            return null;
        }

        void make_ui () {
            plugin_window = new Hdy.Window ();
            plugin_window.title = "Ensembles Plugin: " + plug_name;
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

            main_grid = new Gtk.Grid () {
                margin = 0,
                column_spacing = 4,
                row_spacing = 4,
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.CENTER
            };

            // Plugin's own UI system
            var plug_ui_grid = new Gtk.Grid ();

            var plugin_ui = get_plugin_ui ();

            if (plugin_ui != null) {
                plug_ui_grid.attach (plugin_ui, 0, 0);

                ui_mode_button.append_icon ("preferences-other", Gtk.IconSize.BUTTON);
                ui_mode_button.append_icon ("media-eq", Gtk.IconSize.BUTTON);
                ui_mode_button.set_active (0);
                headerbar.pack_end (ui_mode_button);
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

        public virtual void instantiate_plug (bool realtime, float* mixer_value) {
            mixing_amount = mixer_value;
            deactivate_plug (realtime);
            make_ui ();
        }

        public virtual void connect_control_port (void* variable, uint32 index, bool? realtime = false) {
        }

        public virtual void activate_plug (bool realtime) {
            active = true;
        }

        public virtual void deactivate_plug (bool realtime) {
            active = false;
        }

        public virtual void process (uint32 sample_count) {
        }

        public virtual void connect_source_buffer (void* buffer_l, void* buffer_r) {
        }

        public virtual void connect_sink_buffer (void* buffer_l, void* buffer_r) {
        }
    }
}
