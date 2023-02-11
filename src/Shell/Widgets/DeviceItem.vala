/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class DeviceItem : Gtk.ListBoxRow {
        public Ensembles.Core.MidiDevice device;
        Gtk.Label device_name;
        public Gtk.CheckButton radio;
        public DeviceItem (Ensembles.Core.MidiDevice device) {
            this.device = device;
            device_name = new Gtk.Label (this.device.name);
            radio = new Gtk.CheckButton ();
            radio.margin_end = 8;
            radio.set_active (false);
            radio.set_sensitive (false);

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                margin_start = 8,
                margin_end = 8,
                margin_top = 8,
                margin_bottom = 8,
                halign = Gtk.Align.START
            };

            box.append (radio);
            box.append (device_name);
            this.set_child (box);
        }
    }
}
