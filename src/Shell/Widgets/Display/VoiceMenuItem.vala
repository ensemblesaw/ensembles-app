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
        public Voice voice { get; protected set; }

        public bool show_category { get; set; }

        public VoiceMenuItem (
            uint16 index,
            Voice voice,
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

            var menu_item_grid = new Gtk.Grid () {
                 column_spacing = 16,
                 row_spacing = 0
            };
            set_child (menu_item_grid);

            if (show_category) {
                var category_label = new Gtk.Label ("") {
                    xalign = 0
                };
                var protocol_name = "";
                if (is_plugin) {
                    switch (plugin.protocol) {
                        case AudioPlugin.Protocol.LV2:
                            protocol_name = "LV2";
                            break;
                        case AudioPlugin.Protocol.CARLA:
                            protocol_name = "Carla";
                            break;
                        case AudioPlugin.Protocol.LADSPA:
                            protocol_name = "LADSPA";
                            break;
                        case AudioPlugin.Protocol.NATIVE:
                            protocol_name = "GTK";
                            break;
                    }
                }

                category_label.set_text (
                    is_plugin ? protocol_name.up () + " PLUGINS" : voice.category.up ()
                );
                category_label.add_css_class ("menu-item-category");
                menu_item_grid.attach (category_label, 0, 0, 3, 1);
            }

            var index_label = new Gtk.Label ("%03d".printf (index)) {
                width_chars = 3,
                xalign = 0
            };
            index_label.add_css_class ("menu-item-index");
            menu_item_grid.attach (index_label, 0, 1);

            var voice_name_label = new Gtk.Label (is_plugin ? plugin.name : voice.name) {
                halign = Gtk.Align.START,
                hexpand = true,
                height_request = 48
            };
            voice_name_label.add_css_class ("menu-item-name");
            menu_item_grid.attach (voice_name_label, 1, 1);

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
