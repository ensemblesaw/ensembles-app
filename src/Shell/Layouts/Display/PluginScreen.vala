/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Shell.Widgets.Display;
using Ensembles.Core.Plugins.AudioPlugins;

namespace Ensembles.Shell.Layouts.Display {
    /**
     * Shows the plugin UI.
     */
    public class PluginScreen : DisplayWindow {
        public unowned AudioPlugin plugin { get; private set; }
        public string? history { get; set; }

        private Gtk.Switch active_switch;
        private Widgets.Knob gain_knob;

        public PluginScreen (AudioPlugin plugin) {
            var protocol_name = "";
            switch (plugin.protocol) {
                case AudioPlugin.Protocol.LV2:
                protocol_name += "L V 2";
                break;
                case AudioPlugin.Protocol.CARLA:
                protocol_name += "C A R L A";
                break;
                case AudioPlugin.Protocol.LADSPA:
                protocol_name += "L A D S P A";
                break;
                case AudioPlugin.Protocol.NATIVE:
                protocol_name += "E N S E M B L E S   G T K";
                break;
            }

            base (_(plugin.name), _(protocol_name));
            this.plugin = plugin;

            build_ui ();
            build_events ();
        }

        private void build_ui () {
            gain_knob = new Widgets.Knob.with_range (-12, 0, 1) {
                width_request = 40,
                height_request = 40,
                halign = Gtk.Align.CENTER,
                valign = Gtk.Align.CENTER,
                tooltip_text = _("Dry / Wet Mix")
            };
            gain_knob.add_css_class ("small");

            gain_knob.value = Utils.Math.convert_gain_to_db (plugin.mix_gain);
            gain_knob.add_mark (-12);
            gain_knob.add_mark (0);
            add_to_header (gain_knob);

            active_switch = new Gtk.Switch () {
                halign = Gtk.Align.CENTER,
                valign = Gtk.Align.CENTER,
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
