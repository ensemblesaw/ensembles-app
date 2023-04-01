/*
* Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
* SPDX-License-Identifier: GPL-3.0-or-later
*/

using Ensembles.Models;
using Ensembles.Core.Plugins.AudioPlugins;

namespace Ensembles.Shell.Widgets.Display {
    public class DSPInstanceMenuItem : Gtk.ListBoxRow {
        public unowned AudioPlugin plugin { get; set; }
        public bool show_category { get; set; }

        public DSPInstanceMenuItem (AudioPlugin plugin) {
            Object (
                plugin: plugin
            );

            build_ui ();
        }

        private void build_ui () {
            add_css_class ("menu-item");

            var menu_item_grid = new Gtk.Grid ();
            set_child (menu_item_grid);

            var plugin_name_label = new Gtk.Label (plugin.name) {
                halign = Gtk.Align.START,
                hexpand = true
            };
            plugin_name_label.add_css_class ("menu-item-name");
            menu_item_grid.attach (plugin_name_label, 0, 0, 1, 1);

            var gain_knob = new Shell.Widgets.Knob () {
                width_request = 40,
                height_request = 40
            };
            menu_item_grid.attach (gain_knob, 1, 0);
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
