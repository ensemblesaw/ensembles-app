/*
* Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
* SPDX-License-Identifier: GPL-3.0-or-later
*/

using Ensembles.Models;
using Ensembles.Core.Plugins.AudioPlugins;

namespace Ensembles.Shell.Widgets.Display {
    public class DSPInstanceMenuItem : Gtk.ListBoxRow {
        public unowned AudioPlugin plugin { get; set; }
        protected unowned Layouts.Display.DSPScreen rack_shell { get; set; }
        public bool show_category { get; set; }
        public Knob gain_knob;
        public Gtk.CheckButton active_switch;
        public Gtk.Button show_ui_button;
        public Gtk.Button delete_instance_button;

        public DSPInstanceMenuItem (AudioPlugin plugin, Layouts.Display.DSPScreen rack_shell) {
            Object (
                plugin: plugin,
                rack_shell: rack_shell
            );

            build_ui ();
            build_events ();
        }

        private void build_ui () {
            add_css_class ("menu-item");
            add_css_class ("p-8");

            var menu_item_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            set_child (menu_item_box);

            active_switch = new Gtk.CheckButton () {
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.CENTER,
                margin_end = 16
            };
            active_switch.add_css_class ("audio-switch");
            active_switch.active = plugin.active;
            menu_item_box.append (active_switch);

            var plugin_name_label = new Gtk.Label (plugin.name) {
                halign = Gtk.Align.START,
                hexpand = true
            };
            plugin_name_label.add_css_class ("menu-item-name");
            menu_item_box.append (plugin_name_label);

            gain_knob = new Shell.Widgets.Knob.with_range (-12, 0, 1) {
                width_request = 40,
                height_request = 40,
                tooltip_text = _("Dry / Wet Mix")
            };
            gain_knob.add_css_class ("small");
            gain_knob.value = Utils.Math.convert_gain_to_db (plugin.mix_gain);
            gain_knob.add_mark (-12);
            gain_knob.add_mark (0);
            menu_item_box.append (gain_knob);

            var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                homogeneous = true,
                height_request = 36,
                width_request = 80
            };
            button_box.add_css_class (Granite.STYLE_CLASS_LINKED);
            menu_item_box.append (button_box);

            if (plugin.ui != null) {
                show_ui_button = new Gtk.Button.from_icon_name (
                    "preferences-other-symbolic"
                ) {
                    tooltip_text = _("Show Plugin UI")
                };
                button_box.append (show_ui_button);
            }

            delete_instance_button = new Gtk.Button.from_icon_name (
                "edit-delete-symbolic"
            ) {
                tooltip_text = _("Remove Plugin from Rack")
            };
            button_box.append (delete_instance_button);
        }

        private void build_events () {
            gain_knob.value_changed.connect ((db) => {
                plugin.mix_gain = (float) Utils.Math.convert_db_to_gain (db);
            });

            active_switch.notify["active"].connect (() => {
                plugin.active = active_switch.active;
            });

            if (plugin.ui != null) {
                show_ui_button.clicked.connect (() => {
                    Application.event_bus.show_plugin_ui (plugin);
                });
            }

            delete_instance_button.clicked.connect (() => {
                rack_shell.delete_plugin_item (this);
            });

            plugin.notify["active"].connect (() => {
                active_switch.active = plugin.active;
            });

            plugin.notify["mix-gain"].connect (() => {
                gain_knob.value = Utils.Math.convert_gain_to_db (plugin.mix_gain);
            });
        }

        public void capture_attention () {
            Timeout.add (100, () => {
                add_css_class ("capture-attention");

                Timeout.add_seconds (1, () => {
                    remove_css_class ("capture-attention");
                    return false;
                });

                return false;
            });
        }
    }
}
