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

            var audio_input_buttons = new Granite.Widgets.ModeButton () {
                margin = 8
            };
            audio_input_buttons.append_text (_("Mic"));
            audio_input_buttons.append_text (_("System"));
            audio_input_buttons.append_text (_("Both"));


            switch (Ensembles.Application.settings.get_enum ("device")) {
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
                    Ensembles.Application.settings.set_enum ("device", Core.SampleRecorder.SourceDevice.MIC);
                    break;
                    case 1:
                    Ensembles.Application.settings.set_enum ("device", Core.SampleRecorder.SourceDevice.SYSTEM);
                    break;
                    case 2:
                    Ensembles.Application.settings.set_enum ("device", Core.SampleRecorder.SourceDevice.BOTH);
                    break;
                }
            });
            audio_input_box.pack_start (audio_input_label);
            audio_input_box.pack_end (audio_input_buttons);
            menu_box.pack_start (audio_input_box);

            // Song note visualization channel selection ////////////////////////////////
            var song_note_channel_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

            var song_note_channel_label = new Gtk.Label (_("Visualize Song Layer")) {
                halign = Gtk.Align.START
            };
            song_note_channel_label.get_style_context ().add_class ("h4");

            var channel_spinner = new Gtk.SpinButton.with_range (0, 15, 1) {
                margin = 8
            };
            channel_spinner.value_changed.connect (() => {
                Core.SongPlayer.set_note_watch_channel ((int)(channel_spinner.get_value ()));
            });

            song_note_channel_box.pack_start (song_note_channel_label);
            song_note_channel_box.pack_end (channel_spinner);

            menu_box.pack_start (song_note_channel_box);


            var header_separator_b = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            menu_box.pack_start (header_separator_b);

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
            midi_box.pack_start (device_list_box);
            midi_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
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

            midi_box.pack_end (midi_split_switch);

            revealer.add (midi_box);

            menu_box.pack_start (device_input_item);
            menu_box.pack_start (revealer);

            // Open manual / user guide button ///////////////////////////////////////////////
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

            // Open settings ui button ///hold/////////////////////////////////////////////////
            var preferences_button = new Gtk.ModelButton () {
                text = _("Settings")
            };
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
