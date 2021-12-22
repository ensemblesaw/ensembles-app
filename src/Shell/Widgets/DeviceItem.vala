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

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            box.margin = 8;
            box.halign = Gtk.Align.START;

            box.pack_start (radio);
            box.pack_start (device_name);
            this.add (box);
        }
    }
}
