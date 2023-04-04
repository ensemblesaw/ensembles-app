/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Shell.Widgets.Display;
using Ensembles.Core.Plugins.AudioPlugins;

namespace Ensembles.Shell.Layouts.Display {
    public class PluginScreen : DisplayWindow {
        public unowned AudioPlugin plugin { get; private set; }
        public string? history { get; set; }

        public PluginScreen (AudioPlugin plugin) {
            var plugin_tech = "";
            switch (plugin.tech) {
                case AudioPlugin.Tech.LV2:
                plugin_tech += "L V 2";
                break;
                case AudioPlugin.Tech.CARLA:
                plugin_tech += "C A R L A";
                break;
                case AudioPlugin.Tech.LADSPA:
                plugin_tech += "L A D S P A";
                break;
                case AudioPlugin.Tech.NATIVE:
                plugin_tech += "E N S E M B L E S   G T K";
                break;
            }

            base (_(plugin.name), _(plugin_tech));
            this.plugin = plugin;

            build_ui ();
        }

        private void build_ui () {
            var scrollable = new Gtk.ScrolledWindow () {
                vexpand = true,
                hexpand = true
            };
            append (scrollable);

            var generated_ui = plugin.get_generated_ui ();
            if (generated_ui != null) {
                scrollable.set_child (generated_ui);
            }
        }
    }
}
