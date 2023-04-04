/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Core.Plugins.AudioPlugins;

namespace Ensembles.Shell.Widgets.Plugins {
    public class AudioPluginControl : Gtk.Box {
        private unowned float[] variables;
        private unowned Port port;

        private Gtk.Label control_label;

        public AudioPluginControl (float[] variables, Port port) {
            Object (
                margin_start: 8,
                margin_bottom: 8,
                margin_top: 8,
                margin_end: 8,
                halign: Gtk.Align.CENTER,
                orientation: Gtk.Orientation.VERTICAL
            );

            this.variables = variables;
            this.port = port;

            build_ui ();
        }

        private void build_ui () {
            add_css_class (Granite.STYLE_CLASS_CARD);

            control_label = new Gtk.Label (port.name) {
                margin_top = 16,
                margin_start = 16,
                margin_end = 16
            };
            control_label.add_css_class (Granite.STYLE_CLASS_H2_LABEL);
            append (control_label);

            if (variables.length < 4) {
                var knob = new Knob () {
                    width_request = 150,
                    height_request = 150,
                    margin_start = 16,
                    margin_end = 16,
                    margin_top = 16,
                    margin_bottom = 16,
                    draw_value = true
                };

                append (knob);

                if (port is Core.Plugins.AudioPlugins.LADSPAV2.LV2ControlPort) {
                    var lv2_control_port = (Core.Plugins.AudioPlugins.LADSPAV2.LV2ControlPort) port;
                    knob.adjustment.lower = lv2_control_port.min_value;
                    knob.adjustment.upper = lv2_control_port.max_value;
                    knob.adjustment.step_increment = lv2_control_port.step;
                    knob.value = lv2_control_port.default_value;

                    knob.add_mark (lv2_control_port.min_value);
                    knob.add_mark (lv2_control_port.max_value);
                }
            }
        }
    }
}
