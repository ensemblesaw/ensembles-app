/*-
 * Copyright (c) 2021-2022 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License 
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
 */

namespace Ensembles.Shell { 
    public class DeviceItem : Gtk.ListBoxRow {
        public Ensembles.Core.ControllerDevice device;
        Gtk.Label device_name;
        public Gtk.CheckButton radio;
        public DeviceItem(Ensembles.Core.ControllerDevice device) {
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