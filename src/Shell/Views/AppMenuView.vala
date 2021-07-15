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
    public class AppMenuView : Gtk.Popover {

        Ensembles.Core.ControllerDevice[] controller_devices;
        Gtk.ListBox device_list_box;

        public signal void change_enable_midi_input (bool enable);
        public signal void change_active_input_device (Ensembles.Core.ControllerDevice device);

        public AppMenuView (Gtk.Widget? relative_to) {
            this.relative_to = relative_to;
            make_ui ();
        }

        void make_ui () {
            Gdk.Pixbuf header_logo = new Gdk.Pixbuf (Gdk.Colorspace.RGB, true, 8, 2, 2);
            try {
                header_logo = new Gdk.Pixbuf.from_resource ("/com/github/subhadeepjasu/ensembles/images/ensembles_logo.svg");
            } catch (Error e) {
                warning (e.message);
            }
            header_logo = header_logo.scale_simple (256, 59, Gdk.InterpType.BILINEAR);

            var subheader = new Gtk.Label ("v1.0.0");
            subheader.margin = 8;
            subheader.margin_top = 2;
            subheader.get_style_context ().add_class ("h3");
            var header_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

            var menu_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            menu_box.pack_start (new Gtk.Image.from_pixbuf (header_logo));
            menu_box.pack_start (subheader);
            menu_box.pack_start (header_separator);

            var device_input_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            var device_list_header = new Gtk.Label ("Midi Input");
            device_list_header.halign = Gtk.Align.START;
            device_list_header.margin_start = 8;
            device_list_header.get_style_context ().add_class ("h4");
            var device_monitor_toggle = new Gtk.Switch ();
            device_monitor_toggle.halign = Gtk.Align.END;
            device_monitor_toggle.margin = 8;
            device_input_box.pack_start (device_list_header);
            device_input_box.pack_end (device_monitor_toggle);

            var revealer = new Gtk.Revealer ();
            revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;

            device_monitor_toggle.notify["active"].connect (() => {
                revealer.reveal_child = device_monitor_toggle.active;
                change_enable_midi_input (device_monitor_toggle.active);
            });

            device_list_box = new Gtk.ListBox ();
            device_list_box.set_activate_on_single_click (false);
            device_list_box.set_selection_mode (Gtk.SelectionMode.BROWSE);
            device_list_box.row_activated.connect ((row) => {
                DeviceItem device_item = row as DeviceItem;
                change_active_input_device (device_item.device);
                deselect_all_devices ();
                device_item.radio.set_active (true);
            });

            revealer.add (device_list_box);

            menu_box.pack_start (device_input_box);
            menu_box.pack_start (revealer);

            menu_box.show_all ();
            this.add (menu_box);
        }

        void deselect_all_devices () {
            var items = device_list_box.get_children ();
            foreach (var item in items) {
                DeviceItem _item = item as DeviceItem;
                _item.radio.set_active (false);
            }
        }


        public void update_devices (Ensembles.Core.ControllerDevice[] devices) {
            controller_devices = null;
            controller_devices = devices;

            print ("Updating Device list\n");

            var previous_items = device_list_box.get_children ();
            foreach (var item in previous_items) {
                device_list_box.remove (item);
            }

            for (int i = 0; i < devices.length; i++) {
                if (devices[i].available) {
                    device_list_box.insert (new DeviceItem (devices[i]), -1);
                }
            }

            device_list_box.show_all ();
        }
    }
}
