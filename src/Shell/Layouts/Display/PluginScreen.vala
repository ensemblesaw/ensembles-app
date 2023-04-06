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

        private Gtk.Switch active_switch;
        private Widgets.Knob gain_knob;

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
            build_events ();
        }

        private void build_ui () {
            gain_knob = new Widgets.Knob.with_range (-12, 0, 1) {
                width_request = 40,
                height_request = 40,
                halign = Gtk.Align.CENTER,
                valign = Gtk.Align.CENTER
            };

            gain_knob.value = Utils.Math.convert_gain_to_db (plugin.mix_gain);
            gain_knob.add_mark (-12);
            gain_knob.add_mark (0);
            add_to_header (gain_knob);

            active_switch = new Gtk.Switch () {
                halign = Gtk.Align.CENTER,
                valign =  Gtk.Align.CENTER,
                margin_end = 8
            };
            active_switch.active = plugin.active;
            add_to_header (active_switch);

            var scrollable = new Gtk.ScrolledWindow () {
                vexpand = true,
                hexpand = true
            };
            append (scrollable);

            var plugin_ui = plugin.ui;
            if (plugin_ui != null) {
                scrollable.set_child (plugin_ui);
            }
        }

        private void build_events () {
            active_switch.notify["active"].connect (() => {
                plugin.active = active_switch.active;
            });

            gain_knob.value_changed.connect ((db) => {
                plugin.mix_gain = (float) Utils.Math.convert_db_to_gain (db);
            });
        }
    }
}
