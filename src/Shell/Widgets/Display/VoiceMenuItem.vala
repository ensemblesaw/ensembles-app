/*
* Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
* SPDX-License-Identifier: GPL-3.0-or-later
*/

using Ensembles.Models;
using Ensembles.Core.Plugins.AudioPlugins;

namespace Ensembles.Shell.Widgets.Display {
    public class VoiceMenuItem : Gtk.ListBoxRow {
        public uint16 index { get; protected set; }

        /** Whether this voice item is a plugin or the SoundFont */
        public bool is_plugin { get; protected set; }

        // If the voice is a plugin
        public unowned AudioPlugin plugin { get; protected set; }
        protected unowned Layouts.Display.VoiceScreen rack_shell { get; protected set; }
        public Gtk.Button show_ui_button;

        // If the voice is from the SoundFont
        public unowned Voice? voice { get; protected set; }

        public bool show_category { get; set; }

        public VoiceMenuItem (
            uint16 index,
            Voice? voice = null,
            AudioPlugin? plugin = null,
            bool show_category = false
        ) {
            Object (
                index: index,
                voice: voice,
                plugin: plugin,
                is_plugin: plugin != null,
                show_category: show_category
            );

            build_ui ();
        }

        private void build_ui () {
            add_css_class ("menu-item");

            var menu_item_grid = new Gtk.Grid ();
            set_child (menu_item_grid);

            var voice_name_label = new Gtk.Label (is_plugin ? plugin.name : voice.name) {
                halign = Gtk.Align.START,
                hexpand = true
            };
            voice_name_label.add_css_class ("menu-item-name");
            menu_item_grid.attach (voice_name_label, 0, 0, 1, 2);

            var index_label = new Gtk.Label (index.to_string ()) {
                halign = Gtk.Align.END
            };
            index_label.add_css_class ("menu-item-description");
            menu_item_grid.attach (index_label, 1, 1, 1, 1);

            var category_label = new Gtk.Label ("");

            if (show_category) {
                var plugin_tech = "";
                if (is_plugin) {
                    switch (plugin.tech) {
                        case AudioPlugin.Tech.LV2:
                            plugin_tech = "LV2";
                            break;
                        case AudioPlugin.Tech.CARLA:
                            plugin_tech = "Carla";
                            break;
                        case AudioPlugin.Tech.LADSPA:
                            plugin_tech = "LADSPA";
                            break;
                        case AudioPlugin.Tech.NATIVE:
                            plugin_tech = "GTK";
                            break;
                    }
                }

                category_label.set_text (
                    is_plugin ? plugin_tech + " Plugins" : voice.category
                );
                category_label.add_css_class ("menu-item-category");
            }

            menu_item_grid.attach (category_label, 1, 0, 2, 1);

            if (is_plugin && plugin.ui != null) {
                show_ui_button = new Gtk.Button.from_icon_name ("preferences-other-symbolic") {
                    margin_top = 6,
                    margin_start = 4,
                    margin_end = 4,
                    width_request = 80,
                    tooltip_text = _("Show Plugin UI")
                };
                menu_item_grid.attach (show_ui_button, 2, 1, 1, 1);
            }
        }
    }
}
