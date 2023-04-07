/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Shell.Widgets.Display;
using Ensembles.Models;
using Ensembles.Core.Plugins.AudioPlugins;
using Ensembles.Core.Racks;

namespace Ensembles.Shell.Layouts.Display {
    public class DSPScreen : DisplayWindow {
        private Gtk.Button plugin_picker_button;
        private Gtk.Switch dsp_switch;
        private Adw.Flap main_flap;
        private Gtk.ListBox main_list_box;
        private AudioPluginPicker plugin_picker;

        private unowned DSPRack rack;

        public DSPScreen (DSPRack rack) {
            base (_("Main DSP Rack"), _("Add Effects to the Rack to apply them globally"));

            this.rack = rack;
        }

        construct {
            build_ui ();
            build_events ();
        }

        private void build_ui () {
            dsp_switch = new Gtk.Switch () {
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.CENTER
            };
            dsp_switch.active = true;
            add_to_header (dsp_switch);

            plugin_picker_button = new Gtk.Button.from_icon_name ("plugin-add-symbolic") {
                width_request = 36,
                tooltip_text = _("Add plugin to DSP Rack")
            };
            add_to_header (plugin_picker_button);

            main_flap = new Adw.Flap () {
                fold_policy = Adw.FlapFoldPolicy.ALWAYS,
                flap_position = Gtk.PackType.END
            };
            main_flap.add_css_class ("plugin-flap");
            append (main_flap);

            plugin_picker = new AudioPluginPicker (Core.Plugins.AudioPlugins.AudioPlugin.Category.DSP);
            main_flap.set_flap (plugin_picker);

            var scrollable = new Gtk.ScrolledWindow () {
                hexpand = true,
                vexpand = true,
                margin_start = 8,
                margin_end = 8,
                margin_top = 8,
                margin_bottom = 8
            };
            scrollable.add_css_class ("can-be-blurred");
            main_flap.set_content (scrollable);

            main_list_box = new Gtk.ListBox () {
                selection_mode = Gtk.SelectionMode.NONE
            };
            main_list_box.add_css_class ("menu-box");
            scrollable.set_child (main_list_box);
        }

        private void build_events () {
            dsp_switch.notify["active"].connect (() => {
                rack.active = dsp_switch.active;
            });

            plugin_picker_button.clicked.connect (() => {
                main_flap.reveal_flap = !main_flap.reveal_flap;
            });

            main_flap.notify.connect ((param) => {
                if (param.name == "reveal-flap") {
                    Idle.add (() => {
                        if (main_flap.reveal_flap) {
                            main_flap.get_content ().add_css_class ("blurred");
                        } else {
                            main_flap.get_content ().remove_css_class ("blurred");
                        }

                        return false;
                    });
                }
            });

            Application.event_bus.rack_reconnected.connect ((rack, change_index) => {
                if (rack.rack_type == AudioPlugin.Category.DSP) {
                    populate (rack.get_plugins (), change_index);
                }

                main_flap.reveal_flap = false;
            });
        }

        public void populate (List<AudioPlugin> plugins, int highlight_index) {
            while (main_list_box.get_first_child () != null) {
                main_list_box.remove (main_list_box.get_first_child ());
            }

            for (uint16 i = 0; i < plugins.length (); i++) {
                var menu_item = new DSPInstanceMenuItem (plugins.nth_data (i), this);
                main_list_box.insert (menu_item, -1);

                if (highlight_index == i) {
                    menu_item.capture_attention ();
                }
            }

            min_value = 0;
            max_value = (int) plugins.length () - 1;
        }

        public void delete_plugin_item (DSPInstanceMenuItem item) {
            unowned AudioPlugin plugin = item.plugin;
            main_list_box.remove (item);
            rack.remove_data (plugin);
        }
    }
}
