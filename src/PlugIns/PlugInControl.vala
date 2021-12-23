/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.PlugIns {
    public class PlugInControl : Gtk.Grid {
        float* control_value;
        Gtk.Label label;
        Gtk.Scale scale;
        public PlugInControl (ControlPort port, float* value) {
            control_value = value;
            label = new Gtk.Label (port.name);
            label.width_chars = 15;
            label.margin = 8;
            label.xalign = 0;
            label.get_style_context ().add_class ("h3");
            scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, port.min_value, port.max_value, 1.0);
            scale.hexpand = true;
            scale.margin = 8;
            scale.set_value ((double)port.default_value);
            attach (label, 0, 0);
            attach (scale, 1, 0);

            scale.change_value.connect (value_change_handler);
            this.show_all ();
            this.width_request = 400;
            this.row_spacing = 4;
            this.get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
        }

        private bool value_change_handler (Gtk.ScrollType scroll, double value) {
            if (control_value != null) {
                *control_value = (float)value;
            }
            return false;
        }
    }
}
