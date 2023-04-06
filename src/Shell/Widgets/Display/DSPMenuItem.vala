/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
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
            menu_item_grid.attach (extra_info_box, 0, 1);

            var extra_info_labels = new string[0];
            if (plugin.author_name != null && plugin.author_name.length > 0) {
                extra_info_labels.resize (1);
                extra_info_labels[0] = plugin.author_name;
            }

            if (plugin.author_homepage != null && plugin.author_homepage.length > 0) {
                extra_info_labels.resize (extra_info_labels.length + 1);
                extra_info_labels[extra_info_labels.length - 1] = plugin.author_homepage;
            }

            if (extra_info_labels.length > 0) {
                extra_info_box.append (
                    new Gtk.Label (string.joinv (" ⏺ ", extra_info_labels)) {
                        opacity = 0.5,
                        max_width_chars = 40,
                        ellipsize = Pango.EllipsizeMode.END
                    }
                );
            }

            var plugin_tech_icon = "";
            switch (plugin.tech) {
                case AudioPlugin.Tech.LV2:
                plugin_tech_icon = "lv2";
                break;
                case AudioPlugin.Tech.CARLA:
                plugin_tech_icon = "carla";
                break;
                case AudioPlugin.Tech.LADSPA:
                plugin_tech_icon = "ladspa";
                break;
                case AudioPlugin.Tech.NATIVE:
                plugin_tech_icon = "native";
                break;
            }

            if (plugin_tech_icon.length > 0) {
                plugin_tech_icon =
                "/com/github/subhadeepjasu/ensembles/icons/scalable/emblems/plugin-audio-" +
                plugin_tech_icon + "-symbolic.svg";

                var icon = new Gtk.Image.from_resource (plugin_tech_icon);
                icon.add_css_class ("plugin-item-tech");
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
