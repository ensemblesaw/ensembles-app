/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Core.Plugins.AudioPlugins;

namespace Ensembles.Shell.Widgets.Plugins {
    public class AudioPluginControl : Gtk.Box {
        private Gtk.IconSize widget_size;
        private float* variable;
        private unowned Port port;

        private Gtk.Label control_label;

        public AudioPluginControl (Port port, float* variable, Gtk.IconSize widget_size = Gtk.IconSize.NORMAL) {
            Object (
                margin_start: 8,
                margin_bottom: 8,
                margin_top: 8,
                margin_end: 8,
                halign: Gtk.Align.CENTER,
                orientation: Gtk.Orientation.VERTICAL
            );

            this.widget_size = widget_size;
            this.variable = variable;
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
            control_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);
            append (control_label);

            if (widget_size == Gtk.IconSize.LARGE) {
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
                    knob.value = *variable;

                    knob.add_mark (lv2_control_port.min_value);
                    knob.add_mark (lv2_control_port.default_value);
                    knob.add_mark (lv2_control_port.max_value);
                }

                knob.value_changed.connect ((value) => {
                    *variable = (float) value;
                });
            } else {
                var scale = new Gtk.Scale (Gtk.Orientation.VERTICAL, null) {
                    height_request = 150,
                    margin_start = 16,
                    margin_end = 16,
                    margin_top = 16,
                    margin_bottom = 16,
                    inverted = true
                };

                append (scale);

                if (port is Core.Plugins.AudioPlugins.LADSPAV2.LV2ControlPort) {
                    var lv2_control_port = (Core.Plugins.AudioPlugins.LADSPAV2.LV2ControlPort) port;
                    scale.adjustment.lower = lv2_control_port.min_value;
                    scale.adjustment.upper = lv2_control_port.max_value;
                    scale.adjustment.step_increment = lv2_control_port.step;
                    scale.adjustment.value = *variable;

                    scale.add_mark (
                        lv2_control_port.min_value, Gtk.PositionType.RIGHT,
                        null
                    );
                    scale.add_mark (
                        lv2_control_port.default_value,
                        Gtk.PositionType.RIGHT,
                        null
                    );
                    scale.add_mark (
                        lv2_control_port.max_value,
                        Gtk.PositionType.RIGHT,
                        null
                    );
                }

                scale.value_changed.connect ((range) => {
                    *variable = (float) range.get_value ();
                });
            }
        }
    }
}
