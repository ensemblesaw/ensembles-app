/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class EffectItem : Gtk.ListBoxRow {
        weak PlugIns.PlugIn plugin_reference;
        public EffectItem (PlugIns.PlugIn plugin_reference, bool show_category) {
            this.plugin_reference = plugin_reference;

            var effect_label = new Gtk.Label (plugin_reference.plug_name);
            effect_label.get_style_context ().add_class ("menu-item-label");
            effect_label.halign = Gtk.Align.START;
            effect_label.hexpand = true;

            var type_label = new Gtk.Label (plugin_reference.plug_type.up ());
            type_label.get_style_context ().add_class ("menu-item-description");
            type_label.halign = Gtk.Align.END;
            var category_label = new Gtk.Label ("");
            var effect_grid = new Gtk.Grid ();
            if (show_category) {
                category_label.set_text (plugin_reference.class);
                category_label.get_style_context ().add_class ("menu-item-annotation");
            }
            var active_switch = new Gtk.Switch ();
            active_switch.halign = Gtk.Align.CENTER;
            active_switch.valign = Gtk.Align.CENTER;
            active_switch.margin_end = 4;
            active_switch.active = plugin_reference.active;

            active_switch.notify["active"].connect (() => {
                if (active_switch.active) {
                    plugin_reference.activate_plug (true);
                } else {
                    plugin_reference.deactivate_plug (true);
                }
            });

            effect_grid.attach (active_switch, 0, 0, 1, 2);
            effect_grid.attach (effect_label, 1, 0, 1, 2);
            effect_grid.attach (category_label, 2, 0, 1, 1);
            effect_grid.attach (type_label, 2, 1, 1, 1);
            this.set_child (effect_grid);

            if (!plugin_reference.valid) {
                this.sensitive = false;
            }
        }
    }
}
