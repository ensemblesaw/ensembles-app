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
        public signal void open_preferences_dialog ();

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

            var fluid_version = Core.Synthesizer.get_fluidsynth_version ();
            var subheader = new Gtk.Label (("Powered by FluidSynth v%1.1f").printf (fluid_version));
            subheader.get_style_context ().add_class ("h4");
            subheader.halign = Gtk.Align.START;
            var header_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

            var header_logo_image = new Gtk.Image.from_pixbuf (header_logo);
            header_logo_image.margin_start = 4;
            header_logo_image.margin_top = 4;
            header_logo_image.halign = Gtk.Align.START;

            var menu_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            menu_box.pack_start (header_logo_image);
            menu_box.pack_start (subheader);
            menu_box.pack_start (header_separator);

            var audio_input_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            var audio_input_label = new Gtk.Label (_("Sampler Source"));
            audio_input_label.halign = Gtk.Align.START;
            audio_input_label.get_style_context ().add_class ("h4");
            var audio_input_buttons = new Granite.Widgets.ModeButton ();
            audio_input_buttons.append_text (_("Mic"));
            audio_input_buttons.append_text (_("System"));
            audio_input_buttons.append_text (_("Both"));
            audio_input_buttons.margin = 8;
            switch (EnsemblesApp.settings.get_enum ("device")) {
                case Core.SampleRecorder.SourceDevice.MIC:
                audio_input_buttons.selected = 0;
                break;
                case Core.SampleRecorder.SourceDevice.SYSTEM:
                audio_input_buttons.selected = 1;
                break;
                case Core.SampleRecorder.SourceDevice.BOTH:
                audio_input_buttons.selected = 2;
                break;
            }
            audio_input_buttons.mode_changed.connect (() => {
                switch (audio_input_buttons.selected) {
                    case 0:
                    EnsemblesApp.settings.set_enum ("device", Core.SampleRecorder.SourceDevice.MIC);
                    break;
                    case 1:
                    EnsemblesApp.settings.set_enum ("device", Core.SampleRecorder.SourceDevice.SYSTEM);
                    break;
                    case 2:
                    EnsemblesApp.settings.set_enum ("device", Core.SampleRecorder.SourceDevice.BOTH);
                    break;
                }
            });
            audio_input_box.pack_start (audio_input_label);
            audio_input_box.pack_end (audio_input_buttons);
            menu_box.pack_start (audio_input_box);

            var header_separator_b = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            menu_box.pack_start (header_separator_b);

            var device_input_item = new Granite.SwitchModelButton (_("Midi Input"));
            device_input_item.get_style_context ().add_class ("h4");

            var revealer = new Gtk.Revealer ();
            revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;

            device_input_item.notify["active"].connect (() => {
                revealer.reveal_child = device_input_item.active;
                change_enable_midi_input (device_input_item.active);
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

            menu_box.pack_start (device_input_item);
            menu_box.pack_start (revealer);

            var manual_button = new Gtk.ModelButton ();
            manual_button.text = (_("Open Manual"));
            manual_button.get_style_context ().add_class ("h4");
            manual_button.clicked.connect (() => {
                var file = File.new_for_path (Constants.PKGDATADIR + "/docs/ensembles_manual.pdf");
                if (file.query_exists ()) {
                    try {
                        AppInfo.launch_default_for_uri (file.get_uri (), null);
                    } catch (Error e) {
                        warning ("Unable to open manual");
                    }
                }
            });

            var preferences_button = new Gtk.ModelButton ();
            preferences_button.text = (_("Settings"));
            preferences_button.get_style_context ().add_class ("h4");
            preferences_button.clicked.connect (() => {
                open_preferences_dialog ();
            });
            menu_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            menu_box.pack_start (preferences_button);
            menu_box.pack_start (manual_button);
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

            debug ("Updating Device list\n");

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
