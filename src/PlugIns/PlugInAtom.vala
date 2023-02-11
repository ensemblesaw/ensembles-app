/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.PlugIns {
    public class PlugInAtom : Gtk.Grid {
        LV2.Atom.Atom* atom_value;
        Gtk.Label label;
        public PlugInAtom (AtomPort port, LV2.Atom.Atom* value) {
            atom_value = value;
            label = new Gtk.Label (port.name) {
                width_chars = 15,
                margin_start = 8,
                margin_end = 8,
                margin_top = 8,
                margin_bottom = 8,
                xalign = 0
            };
            label.get_style_context ().add_class ("h3");
            attach (label, 0, 0);

            this.show ();
            this.width_request = 400;
            this.row_spacing = 4;
            this.get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
        }
    }
}
