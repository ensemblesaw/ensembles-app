/*
* Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
* SPDX-License-Identifier: GPL-3.0-or-later
*/

using Ensembles.Models;
using Ensembles.Core.Plugins.AudioPlugins;

namespace Ensembles.Shell.Widgets.Display {
    public class DSPInstanceMenuItem : Gtk.ListBoxRow {
        public unowned AudioPlugin plugin { get; set; }
        protected unowned  Layouts.Display.DSPScreen rack_shell { get; set; }
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

            var menu_item_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            set_child (menu_item_box);

            active_switch = new Gtk.CheckButton () {
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.CENTER,
                margin_end = 16
            };
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
                height_request = 40
            };
            // Convert from digital signal gain to decibel
            gain_knob.value = 10 * Math.log10 (plugin.mix_gain);
            gain_knob.add_mark (-12);
            gain_knob.add_mark (0);
            menu_item_box.append (gain_knob);

            var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                homogeneous = true,
                width_request = 120
            };
            button_box.add_css_class (Granite.STYLE_CLASS_LINKED);
            menu_item_box.append (button_box);

            if (plugin.ui != null) {
                show_ui_button = new Gtk.Button.from_icon_name ("preferences-other-symbolic");
                button_box.append (show_ui_button);
            }

            delete_instance_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic");
            button_box.append(delete_instance_button);
        }

        private void build_events () {
            gain_knob.value_changed.connect (() => {
                // Convert from decibels to digital signal gain
                plugin.mix_gain = (float) Math.pow (10, gain_knob.value / 20);
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
