/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Shell.Widgets.Display;
using Ensembles.Models;

namespace Ensembles.Shell.Layouts.Display {
    public class DSPScreen : DisplayWindow {
        private Gtk.Button plugin_picker_button;
        private Gtk.Switch dsp_switch;
        private Adw.Flap main_flap;
        private Gtk.ListBox main_list_box;
        private AudioPluginPicker plugin_picker;

        public DSPScreen () {
            base (_("Main DSP Rack"), _("Add Effects to the Rack to apply them globally"));
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
            add_to_header (dsp_switch);

            plugin_picker_button = new Gtk.Button.from_icon_name ("plugin-add-symbolic") {
                width_request = 36
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
            main_flap.set_content (scrollable);

            main_list_box = new Gtk.ListBox () {
                selection_mode = Gtk.SelectionMode.SINGLE
            };
            main_list_box.add_css_class ("menu-box");
            scrollable.set_child (main_list_box);
        }

        private void build_events () {
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
        }
    }
}
