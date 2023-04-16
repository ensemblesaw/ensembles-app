/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

 using Ensembles.Core.Plugins.AudioPlugins;

namespace Ensembles.Shell.Widgets.Display {
    public class DSPMenuItem : Gtk.ListBoxRow {
        public unowned AudioPlugin plugin { get; set; }

        private Gtk.Button insert_button;

        public DSPMenuItem (AudioPlugin plugin, Core.Racks.DSPRack dsp_rack) {
            Object (
                plugin: plugin,
                height_request: 68
            );

            build_ui ();

            insert_button.clicked.connect (() => {
                try {
                    dsp_rack.append (plugin.duplicate ());
                } catch (PluginError e) {
                    Console.log ("Failed to add plugin %s with error %s".printf (plugin.name, e.message),
                    Console.LogLevel.WARNING);
                }
            });
        }

        private void build_ui () {
            add_css_class ("plugin-item");

            var menu_item_grid = new Gtk.Grid ();
            set_child (menu_item_grid);

            var plugin_name_label = new Gtk.Label (plugin.name) {
                halign = Gtk.Align.START,
                hexpand = true
            };
            plugin_name_label.add_css_class ("plugin-item-name");
            menu_item_grid.attach (plugin_name_label, 0, 0);

            var extra_info_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);
            extra_info_box.add_css_class ("plugin-item-info");
            menu_item_grid.attach (extra_info_box, 0, 1);

            var extra_info_labels = new string[0];
            if (plugin.author_name != null && plugin.author_name.length > 0) {
                extra_info_labels.resize (1);
                if (plugin.author_name.length > 32) {
                    extra_info_labels[0] = plugin.author_name.substring (0, 32) + "…";
                } else {
                    extra_info_labels[0] = plugin.author_name;
                }
            }

            if (plugin.author_homepage != null && plugin.author_homepage.length > 0) {
                extra_info_labels.resize (extra_info_labels.length + 1);

                if (plugin.author_homepage.length > 36) {
                    extra_info_labels[extra_info_labels.length - 1] =
                    plugin.author_homepage.substring (0, 36) + "…";
                } else {
                    extra_info_labels[extra_info_labels.length - 1] = plugin.author_homepage;
                }

            }

            if (extra_info_labels.length > 0) {
                extra_info_box.append (
                    new Gtk.Label (string.joinv (" ⏺ ", extra_info_labels)) {
                        opacity = 0.5
                    }
                );
            }

            var plugin_protocol_icon = "";
            switch (plugin.protocol) {
                case AudioPlugin.Protocol.LV2:
                plugin_protocol_icon = "lv2";
                break;
                case AudioPlugin.Protocol.CARLA:
                plugin_protocol_icon = "carla";
                break;
                case AudioPlugin.Protocol.LADSPA:
                plugin_protocol_icon = "ladspa";
                break;
                case AudioPlugin.Protocol.NATIVE:
                plugin_protocol_icon = "native";
                break;
            }

            if (plugin_protocol_icon.length > 0) {
                plugin_protocol_icon =
                "/com/github/subhadeepjasu/ensembles/icons/scalable/emblems/plugin-audio-" +
                plugin_protocol_icon + "-symbolic.svg";

                var icon = new Gtk.Image.from_resource (plugin_protocol_icon);
                icon.add_css_class ("plugin-item-protocol");
                extra_info_box.append (icon);
            }

            insert_button = new Gtk.Button.from_icon_name ("insert-object-symbolic") {
                valign = Gtk.Align.START
            };
            insert_button.add_css_class ("plugin-item-insert-button");
            menu_item_grid.attach (insert_button, 1, 0, 1, 2);
        }
    }
}
