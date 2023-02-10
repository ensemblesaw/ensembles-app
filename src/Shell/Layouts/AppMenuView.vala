/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/*
 * This file is part of Ensembles
 */

namespace Ensembles.Shell {
    // The menu that opens when you click the "gear" icon
    public class AppMenuView : Gtk.Popover {

        Ensembles.Core.MidiDevice[] midi_devices;
        Gtk.ListBox device_list_box;

        public signal void open_preferences_dialog ();

        construct {
            make_ui ();
        }

        void make_ui () {
            // Create the main box to house all of it
            var menu_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            // Audio input source selection box /////////////////////////////////////////////
            var audio_input_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

            var audio_input_label = new Gtk.Label (_("Sampler Source")) {
                halign = Gtk.Align.START
            };
            audio_input_label.get_style_context ().add_class ("h4");

            var audio_input_buttons = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0) {
                margin_top = 8,
                margin_bottom = 8,
                margin_start = 8,
                margin_end = 8
            };

            audio_input_buttons.get_style_context ().add_class ("linked");

            var mic_toggle_button = new Gtk.ToggleButton.with_label (_("Mic"));
            audio_input_buttons.append (mic_toggle_button);
            var system_toggle_button = new Gtk.ToggleButton.with_label (_("System")) {
                group = mic_toggle_button
            };
            audio_input_buttons.append (system_toggle_button);
            var both_toggle_button = new Gtk.ToggleButton.with_label (_("Both")) {
                group = mic_toggle_button
            };
            audio_input_buttons.append (both_toggle_button);


            switch (Ensembles.Application.settings.get_enum ("device")) {
                case Core.SampleRecorder.SourceDevice.MIC:
                mic_toggle_button.active = true;
                system_toggle_button.active = false;
                both_toggle_button.active = false;
                break;
                case Core.SampleRecorder.SourceDevice.SYSTEM:
                mic_toggle_button.active = false;
                system_toggle_button.active = true;
                both_toggle_button.active = false;
                break;
                case Core.SampleRecorder.SourceDevice.BOTH:
                mic_toggle_button.active = false;
                system_toggle_button.active = false;
                both_toggle_button.active = true;
                break;
            }
            mic_toggle_button.toggled.connect (() => {
                if (mic_toggle_button.active) {
                    Ensembles.Application.settings.set_enum ("device", Core.SampleRecorder.SourceDevice.MIC);
                } else if (system_toggle_button.active) {
                    Ensembles.Application.settings.set_enum ("device", Core.SampleRecorder.SourceDevice.SYSTEM);
                } else if (both_toggle_button.active) {
                    Ensembles.Application.settings.set_enum ("device", Core.SampleRecorder.SourceDevice.BOTH);
                }
            });
            audio_input_box.append (audio_input_label);
            audio_input_box.append (audio_input_buttons);

            menu_box.append (audio_input_box);

            // Song note visualization channel selection ////////////////////////////////
            var song_note_channel_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

            var song_note_channel_label = new Gtk.Label (_("Visualize Song Layer")) {
                halign = Gtk.Align.START
            };
            song_note_channel_label.get_style_context ().add_class ("h4");

            var channel_spinner = new Gtk.SpinButton.with_range (0, 15, 1) {
                margin_top = 8,
                margin_bottom = 8,
                margin_start = 8,
                margin_end = 8
            };
            channel_spinner.value_changed.connect (() => {
                Core.SongPlayer.set_note_watch_channel ((int)(channel_spinner.get_value ()));
            });

            song_note_channel_box.append (song_note_channel_label);
            song_note_channel_box.append (channel_spinner);

            menu_box.append (song_note_channel_box);


            var header_separator_b = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            menu_box.append (header_separator_b);

            // MIDI Input device selection /////////////////////////////////////////////
            var device_input_item = new Granite.SwitchModelButton (_("Midi Input"));
            device_input_item.get_style_context ().add_class ("h4");

            var revealer = new Gtk.Revealer ();
            revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;

            // Show list of detected devices when the user enables MIDI Input
            device_input_item.notify["active"].connect (() => {
                revealer.reveal_child = device_input_item.active;
                if (device_input_item.active) {
                    var devices_found = Application.arranger_core.midi_input_host.refresh ();
                    update_devices (devices_found);
                } else {
                    Application.arranger_core.midi_input_host.destroy ();
                }
            });

            var midi_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            device_list_box = new Gtk.ListBox () {
                activate_on_single_click = true,
                selection_mode = Gtk.SelectionMode.NONE
            };
            midi_box.append (device_list_box);
            midi_box.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            device_list_box.row_activated.connect ((row) => {
                DeviceItem device_item = row as DeviceItem;
                device_item.radio.active = !device_item.radio.active;

                if (device_item.radio.active) {
                    Application.arranger_core.midi_input_host.connect_device (device_item.device.id);
                } else {
                    Application.arranger_core.midi_input_host.disconnect_device (device_item.device.id);
                }
            });

            var midi_split_switch = new Granite.SwitchModelButton (_("Split By Channel"));
            midi_split_switch.get_style_context ().add_class ("h4");
            midi_split_switch.notify["active"].connect (() => {
                Application.settings.set_boolean ("midi-split", midi_split_switch.active);
            });
            midi_split_switch.active = Application.settings.get_boolean ("midi-split");

            midi_box.append (midi_split_switch);

            revealer.set_child (midi_box);

            menu_box.append (device_input_item);
            menu_box.append (revealer);

            // Open manual / user guide button ///////////////////////////////////////////////
            var manual_button = new Gtk.MenuButton () {
                label = (_("Open Manual"))
            };
            manual_button.get_style_context ().add_class ("h4");
            manual_button.activate.connect (() => {
                var file = File.new_for_path (Constants.PKGDATADIR + "/docs/ensembles_manual.pdf");
                if (file.query_exists ()) {
                    try {
                        AppInfo.launch_default_for_uri (file.get_uri (), null);
                    } catch (Error e) {
                        warning ("Unable to open manual");
                    }
                }
            });

            // Open settings ui button ///hold/////////////////////////////////////////////////
            var preferences_button = new Gtk.MenuButton () {
                label = _("Settings")
            };
            preferences_button.get_style_context ().add_class ("h4");
            preferences_button.activate.connect (() => {
                open_preferences_dialog ();
            });
            menu_box.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            menu_box.append (preferences_button);
            menu_box.append (manual_button);
            menu_box.show ();
            set_child (menu_box);
        }

        //  void deselect_all_devices () {
        //      var items = device_list_box.get_children ();
        //      foreach (var item in items) {
        //          DeviceItem _item = item as DeviceItem;
        //          _item.radio.set_active (false);
        //      }
        //  }


        public void update_devices (Ensembles.Core.MidiDevice[] devices) {
            midi_devices = null;
            midi_devices = devices;

            debug ("Updating Device list\n");

            var previous_items = new List<Gtk.ListBoxRow> ();
            int c = 0;
            Gtk.ListBoxRow current_item = null;
            while (current_item != null) {
                current_item = device_list_box.get_row_at_index (c++);
                if (previous_items != null) {
                    previous_items.append (current_item);
                }
            }

            foreach (var item in previous_items) {
                device_list_box.remove (item);
            }

            for (int i = 0; i < devices.length; i++) {
                if (devices[i].available) {
                    device_list_box.insert (new DeviceItem (devices[i]), -1);
                }
            }

            device_list_box.show ();
        }
    }
}
