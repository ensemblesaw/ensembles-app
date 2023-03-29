/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

 using Ensembles.Core.Plugins.AudioPlugins;

namespace Ensembles.Shell.Widgets.Display {
    public class DSPMenuItem : Gtk.ListBoxRow {
        public unowned AudioPlugin plugin { get; set; }

        private Gtk.Button insert_button;

        public DSPMenuItem (AudioPlugin plugin) {
            Object (
                plugin: plugin,
                height_request: 68
            );

            build_ui ();
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

            insert_button = new Gtk.Button.from_icon_name ("insert-object-symbolic");
            insert_button.add_css_class ("plugin-item-insert-button");
            menu_item_grid.attach (insert_button, 1, 0);
        }
    }
}
