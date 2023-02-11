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
        Adw.Window plugin_window;
        Gtk.HeaderBar headerbar;
        Shell.Knob main_mixing_knob;
        Gtk.Grid main_grid;

        private float* mixing_amount;

        protected Gtk.Widget[] control_widgets;
        protected Gtk.Widget[] atom_widgets;

        protected float[] control_variables;
        protected LV2.Atom.Atom[] atom_variables;

        protected virtual Gtk.Widget get_plugin_custom_ui () {
            return null;
        }

        protected virtual Gtk.Grid get_plugin_native_ui () {
            return null;
        }

        void make_ui () {
            plugin_window = new Adw.Window () {
                hide_on_close = true,
                title = (_("Ensembles Plugin: %s")).printf (plug_name)
            };
            headerbar = new Gtk.HeaderBar () {
                show_title_buttons = true
            };
            Gtk.Image app_icon = new Gtk.Image.from_icon_name (
                "com.github.subhadeepjasu.ensembles") {
                    margin_top = 8,
                    margin_bottom = 8
                };

            main_mixing_knob = new Shell.Knob ();
            main_mixing_knob.set_value (1);
            main_mixing_knob.change_value.connect ((_value) => {
                if (mixing_amount != null) {
                    *mixing_amount = _value;
                }
            });
            headerbar.pack_start (app_icon);
            headerbar.pack_end (main_mixing_knob);

            var header = new Gtk.WindowHandle () {
                hexpand = true,
                vexpand = true
            };
            var header_title = new Gtk.Label ("𝑓𝑥 " + plug_name + " (" + plug_type + ")");
            header_title.height_request = 48;
            header.set_child (header_title);
            headerbar.set_title_widget (header);
            headerbar.decoration_layout = "close:";
            headerbar.valign = Gtk.Align.START;

            var main_grid = get_plugin_native_ui ();

            // Plugin's own UI system
            var plug_ui_grid = new Gtk.Grid ();

            var plugin_ui = get_plugin_custom_ui ();

            var main_stack = new Gtk.Stack ();

            main_stack.add_named (main_grid, "backend_ui");

            if (plugin_ui != null) {
                main_stack.add_named (plug_ui_grid, "frontend_ui");
                main_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

                var main_grid_toggle = new Gtk.ToggleButton () {
                    icon_name = "preferences-other"
                };

                var plugin_ui_toggle = new Gtk.ToggleButton () {
                    icon_name = "media-eq",
                    group = main_grid_toggle
                };

                var ui_mode_button = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                ui_mode_button.get_style_context ().add_class ("linked");

                main_grid_toggle.toggled.connect (() => {
                    if (main_grid_toggle.active) {
                        main_stack.set_visible_child (main_grid);
                    } else {
                        main_stack.set_visible_child (plug_ui_grid);
                    }
                });

                headerbar.pack_end (ui_mode_button);
            }


            var scrollable = new Gtk.ScrolledWindow ();
            scrollable.set_size_request (640, 240);
            scrollable.set_child (main_stack);

            var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            main_box.append (headerbar);
            main_box.append (scrollable);


            plugin_window.set_child (main_box);
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
