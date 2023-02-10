/*
 * Copyright © 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright © 2019 Alain M. (https://github.com/alainm23/planner)<alainmh23@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Dialogs.Preferences {
    public class Preferences : Gtk.Dialog {
        public string view { get; construct; }
        private Gtk.Stack stack;
        private Gtk.Stack header_stack;
        //private uint timeout_id = 0;
        private Gtk.InfoBar infobar;
        private List<ItemInput> input_binding_items;
        private ItemInput selected_input_item;
        private Gtk.EventControllerKey event_controller_key;

        //  private const Gtk.TargetEntry[] TARGET_ENTRIES_LABELS = {
        //      {"LABELROW", Gtk.TargetFlags.SAME_APP, 0}
        //  };

        public Preferences (string view = "home") {
            Object (
                view: view,
                transient_for: Ensembles.Application.main_window,
                deletable: true,
                resizable: false,
                use_header_bar: 1,
                destroy_with_parent: true,
                //  window_position: Gtk.WindowPosition.CENTER_ON_PARENT,
                modal: true,
                title: _("Preferences"),
                width_request: 525,
                height_request: 400
            );
        }

        construct {
            event_controller_key = new Gtk.EventControllerKey ();
            add_controller ((Gtk.ShortcutController)event_controller_key);
            get_header_bar ().show_title_buttons = false;

            get_style_context ().add_class ("app");

            header_stack = new Gtk.Stack () {
                transition_type = Gtk.StackTransitionType.CROSSFADE,
                transition_duration = 500,
                width_request = 450
            };

            get_header_bar ().set_title_widget (header_stack);

            stack = new Gtk.Stack () {
                hexpand = true,
                vexpand = true,
                transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT
            };

            // Add the views to stack
            stack.add_named (get_home_widget (), "home");
            stack.add_named (get_audio_widget (), "audio");
            stack.add_named (get_about_widget (), "about");
            stack.add_named (get_keyboard_widget (), "input");
            stack.add_named (get_midi_widget (), "midi");
            stack.add_named (get_appearance_widget (), "appearance");

            // Show the intended view
            Timeout.add (125, () => {
                stack.visible_child_name = view;
                return GLib.Source.REMOVE;
            });

            var stack_scrolled = new Gtk.ScrolledWindow () {
                hexpand = true,
                vexpand = true,
                hscrollbar_policy = Gtk.PolicyType.NEVER,
                vscrollbar_policy = Gtk.PolicyType.NEVER
            };
            stack_scrolled.set_child (stack);

            var info_label = new Gtk.Label (_("Restart to apply changes"));
            info_label.show ();

            infobar = new Gtk.InfoBar () {
                message_type = Gtk.MessageType.WARNING,
            };
            infobar.add_child (info_label);

            var restart_button = infobar.add_button (_("Restart"), 0);

            infobar.response.connect ((response) => {
                if (response == 0) {
                    try {
                        Ensembles.Application.main_window.app_exit (true);
                    } catch (GLib.Error e) {
                        if (!(e is IOError.CANCELLED)) {
                            info_label.label = _("Requesting a restart failed. Restart manually to apply changes");
                            infobar.message_type = Gtk.MessageType.ERROR;
                            restart_button.visible = false;
                        }
                    }
                }
            });

            var main_grid = new Gtk.Grid () {
                hexpand = true,
                vexpand = true,
                orientation = Gtk.Orientation.VERTICAL
            };
            main_grid.attach (infobar, 0, 0);
            main_grid.attach (stack_scrolled, 0, 1);

            set_child (main_grid);

            event_controller_key.key_pressed.connect ((keyval) => {
                if (keyval == 65307) {
                    return true;
                }

                return false;
            });
        }

        private Gtk.Widget get_home_widget () {
            var header = new Adw.HeaderBar () {
                decoration_layout = ""
            };
            header.get_style_context ().add_class ("flat");
            header_stack.add_named (header, "home");

            var settings_icon = new Gtk.Image.from_icon_name ("open-menu-symbolic");
            settings_icon.halign = Gtk.Align.CENTER;
            settings_icon.valign = Gtk.Align.CENTER;

            var settings_label = new Gtk.Label (_("Settings"));
            settings_label.get_style_context ().add_class ("h3");

            var done_button = new Gtk.Button.with_label (_("Done"));
            done_button.get_style_context ().add_class ("flat");

            var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                margin_start = 3,
                margin_end = 3,
                margin_top = 3,
                margin_bottom = 3,
                hexpand = true
            };
            header_box.append (settings_icon);
            header_box.append (settings_label);
            header_box.append (done_button);

            header.set_title_widget (header_box);

            /* General */
            var audio_item = new Shell.Dialogs.Preferences.Item ("audio-card", _("Audio"));
            audio_item.icon_image.get_style_context ().add_class ("audio-card");

            var files_item = new Shell.Dialogs.Preferences.Item ("audio-x-generic", _("Files"));
            files_item.icon_image.get_style_context ().add_class ("audio-x-generic");

            var theme_item = new Shell.Dialogs.Preferences.Item ("applications-graphics", _("Appearance"), true);
            theme_item.icon_image.get_style_context ().add_class ("applications-graphics");

            var plugin_item = new Shell.Dialogs.Preferences.Item ("extension", _("Plugins"));
            plugin_item.icon_image.get_style_context ().add_class ("extension");

            var input_item = new Shell.Dialogs.Preferences.Item ("input-keyboard", _("PC Input Map"));
            input_item.icon_image.get_style_context ().add_class ("input-keyboard");

            var midi_input_item = new Shell.Dialogs.Preferences.Item ("input-gaming", _("MIDI Input Presets"));
            input_item.icon_image.get_style_context ().add_class ("input-midi");

            var general_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                valign = Gtk.Align.START,
                margin_top = 18
            };
            general_box.get_style_context ().add_class ("preferences-view");
            general_box.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            general_box.append (audio_item);
            general_box.append (files_item);
            general_box.append (plugin_item);
            general_box.append (input_item);
            general_box.append (midi_input_item);
            general_box.append (theme_item);
            general_box.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

            /* Others */
            var about_item = new Shell.Dialogs.Preferences.Item ("help-about", _("About"), true);
            about_item.icon_image.get_style_context ().add_class ("help-about");

            var others_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                margin_top = 18,
                margin_bottom = 3,
                valign = Gtk.Align.START
            };
            others_box.get_style_context ().add_class ("preferences-view");
            others_box.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            others_box.append (about_item);
            // others_box.append (fund_item);
            others_box.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                valign = Gtk.Align.START
            };
            box.append (general_box);
            box.append (others_box);

            var main_scrolled = new Gtk.ScrolledWindow () {
                hscrollbar_policy = Gtk.PolicyType.NEVER,
                hexpand = true,
                vexpand = true
            };
            main_scrolled.set_child (box);

            var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                hexpand = true,
                vexpand = true
            };
            main_box.append (main_scrolled);

            audio_item.activated.connect (() => {
                stack.visible_child_name = "audio";
                header_stack.visible_child_name = "audio";
            });

            files_item.activated.connect (() => {
                stack.visible_child_name = "files";
                header_stack.visible_child_name = "files";
            });

            theme_item.activated.connect (() => {
                stack.visible_child_name = "appearance";
                header_stack.visible_child_name = "theme";
            });

            plugin_item.activated.connect (() => {
                stack.visible_child_name = "plugin";
                header_stack.visible_child_name = "plugin";
            });

            input_item.activated.connect (() => {
                stack.visible_child_name = "input";
                header_stack.visible_child_name = "input";
            });

            midi_input_item.activated.connect (() => {
                stack.visible_child_name = "midi";
                header_stack.visible_child_name = "midi";
            });

            about_item.activated.connect (() => {
                stack.visible_child_name = "about";
                header_stack.visible_child_name = "about";
            });

            //  backups_item.activated.connect (() => {
            //      stack.visible_child_name = "backups";
            //  });

            done_button.clicked.connect ((response_id) => {
                destroy ();
            });

            return main_box;
        }

        private Gtk.Widget get_audio_widget () {
            var top_box = new Shell.Dialogs.Preferences.TopBox ("audio-card", _("Audio"));

            var driver_list = new List<string> ();
            if (Core.AudioDriverSniffer.alsa_driver_found) {
                driver_list.append ("Alsa");
            }
            if (Core.AudioDriverSniffer.pulseaudio_driver_found) {
                driver_list.append ("PulseAudio");
            }
            if (Core.AudioDriverSniffer.pipewire_driver_found) {
                driver_list.append ("PipeWire");
            }
            if (Core.AudioDriverSniffer.pipewire_pulse_driver_found) {
                driver_list.append ("PipeWire Pulse");
            }
            if (Core.AudioDriverSniffer.jack_driver_found) {
                driver_list.append ("Jack");
            }

            int saved_driver = 0;

            switch (Ensembles.Application.settings.get_string ("driver")) {
                case "alsa":
                for (int i = 0; i < driver_list.length (); i++) {
                    if (driver_list.nth_data (i) == "Alsa") {
                        saved_driver = i;
                        break;
                    }
                }
                break;
                case "pulseaudio":
                for (int i = 0; i < driver_list.length (); i++) {
                    if (driver_list.nth_data (i) == "PulseAudio") {
                        saved_driver = i;
                        break;
                    }
                }
                break;
                case "pipewire":
                for (int i = 0; i < driver_list.length (); i++) {
                    if (driver_list.nth_data (i) == "PipeWire") {
                        saved_driver = i;
                        break;
                    }
                }
                break;
                case "pipewire-pulse":
                for (int i = 0; i < driver_list.length (); i++) {
                    if (driver_list.nth_data (i) == "PipeWire Pulse") {
                        saved_driver = i;
                        break;
                    }
                }
                break;
                case "jack":
                for (int i = 0; i < driver_list.length (); i++) {
                    if (driver_list.nth_data (i) == "Jack") {
                        saved_driver = i;
                        break;
                    }
                }
                break;
            }


            var driver_select = new Dialogs.Preferences.ItemSelect (
                _("Driver"),
                saved_driver,
                driver_list,
                false
            );
            driver_select.margin_top = 12;

            string buffer_length_text = _("Buffer length [%d frames]");

            var buffer_length = new Dialogs.Preferences.ItemScale (
                buffer_length_text.printf (Ensembles.Application.settings.get_int ("previous-buffer-length")),
                Ensembles.Application.settings.get_double ("buffer-length"),
                0,
                1,
                0.01,
                true
            );

            driver_select.activated.connect ((index) => {
                string driver_string = "";
                string selected_driver = driver_list.nth_data (index);
                switch (selected_driver) {
                    case "Alsa":
                    driver_string = "alsa";
                    break;
                    case "PulseAudio":
                    driver_string = "pulseaudio";
                    break;
                    case "PipeWire":
                    driver_string = "pipewire";
                    break;
                    case "PipeWire Pulse":
                    driver_string = "pipewire-pulse";
                    break;
                    case "Jack":
                    driver_string = "jack";
                    break;
                }
                infobar.set_visible (true);
                buffer_length.set_sensitive (false);
                Ensembles.Application.settings.set_string ("driver", driver_string);
            });

            var pavuctrl_button = new Gtk.Button.with_label (_("System Mixer")) {
                margin_top = 4,
                margin_bottom = 4,
                margin_start = 4,
                margin_end = 4
            };
            pavuctrl_button.clicked.connect (() => {
                string info;
                try {
                    Process.spawn_command_line_sync ("pavucontrol", out info);
                } catch (Error e) {
                    warning (e.message);
                    var error_dialog = new Shell.Dialogs.ErrorDialog (_("System Mixer not found"),
                                                                      _("Cannot find PulseAudio Volume Control"),
                                                                      e.message,
                                                                      false);
                    error_dialog.transient_for = Application.main_window;
                    error_dialog.show ();
                    error_dialog.present ();
                }
            });

            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                margin_top = 6,
                valign = Gtk.Align.START,
                hexpand = true
            };
            box.append (driver_select);
            box.append (buffer_length);

            buffer_length.changed.connect ((value) => {
                Ensembles.Application.settings.set_double ("buffer-length", value);
                var display_value = Ensembles.Application.arranger_core.synthesizer.set_driver_configuration (
                    Ensembles.Application.settings.get_string ("driver"),
                    value
                );
                buffer_length.title = buffer_length_text.printf (display_value);
                Ensembles.Application.settings.set_int ("previous-buffer-length", display_value);
            });

            var box_scrolled = new Gtk.ScrolledWindow () {
                hscrollbar_policy = Gtk.PolicyType.NEVER,
                hexpand = true,
                vexpand = true
            };
            box_scrolled.set_child (box);

            var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                hexpand = true,
                vexpand = true
            };

            header_stack.add_named (top_box, "audio");
            main_box.append (box_scrolled);
            main_box.append (pavuctrl_button);

            top_box.back_activated.connect (() => {
                stack.visible_child_name = "home";
                header_stack.visible_child_name = "home";
            });

            top_box.done_activated.connect (() => {
                hide_destroy ();
            });

            return main_box;
        }

        delegate void BindingUpdate ();

        private Gtk.Widget get_keyboard_widget () {
            var top_box = new Dialogs.Preferences.TopBox ("input-keyboard", _("PC Input Map"));
            top_box.back_activated.connect (() => {
                stack.visible_child_name = "home";
                header_stack.visible_child_name = "home";
            });

            top_box.done_activated.connect (() => {
                hide_destroy ();
            });

            var default_binding_preset_path = Application.user_config_dir + "/input_presets";
            File preset_file;
            if (DirUtils.create_with_parents (Application.user_config_dir, 2000) != -1) {
                if (DirUtils.create_with_parents (
                    default_binding_preset_path, 2000) != -1) {
                    debug ("Made input presets folder\n");

                    preset_file = File.new_for_path (default_binding_preset_path + "/dell_en_all_keys_generic.csv");

                    if (!preset_file.query_exists ()) {
                        var csv_data = new string[1, 60];
                        var array = Ensembles.Application.settings.get_strv ("pc-input-maps");

                        for (int i = 0; i < array.length; i++) {
                            csv_data[0, i] = array[i];
                        }

                        Utils.save_csv (preset_file, csv_data);
                    }
                }
            }

            Gtk.FileChooserNative mapping_file_chooser =
            new Gtk.FileChooserNative (_("Export PC Keyboard Input Mapping"),
                                                                Application.main_window,
                                                                Gtk.FileChooserAction.SAVE,
                                                                _("Export"),
                                                                _("Cancel")
                                                                );
            mapping_file_chooser.set_current_folder (preset_file);
            mapping_file_chooser.set_current_name ("Untitled.csv");
            var file_filter_csv = new Gtk.FileFilter ();
            file_filter_csv.add_mime_type ("text/csv");
            file_filter_csv.set_filter_name (_("Comma Separated Values File"));
            mapping_file_chooser.set_filter (file_filter_csv);

            mapping_file_chooser.response.connect ((response_id) => {
                if (response_id == -3) {
                    KeyboardConstants.save_mapping (Application.settings, mapping_file_chooser.get_file ());
                }
            });

            Gtk.FileChooserNative mapping_file_open_chooser =
            new Gtk.FileChooserNative (_("Import PC Keyboard Input Mapping"),
                                                                Application.main_window,
                                                                Gtk.FileChooserAction.OPEN,
                                                                _("Import"),
                                                                _("Cancel")
                                                                );

            mapping_file_open_chooser.set_filter (file_filter_csv);
            mapping_file_open_chooser.set_current_folder (preset_file);

            var input_key_box = new Gtk.ListBox ();
            input_key_box.selection_mode = Gtk.SelectionMode.SINGLE;
            input_key_box.get_style_context ().add_class ("input-key-box");
            input_key_box.set_activate_on_single_click (true);
            input_binding_items = new List<ItemInput> ();

            KeyboardConstants.load_mapping (Application.settings);
            int j = 0;
            for (int i = 3; i < 8; i++) {
                var c_note_item = new ItemInput (j, "C " + i.to_string (), KeyboardConstants.key_bindings[j++], false);
                input_binding_items.append (c_note_item);
                input_key_box.insert (c_note_item, -1);
                var cs_note_item = new ItemInput (j, "C♯ " + i.to_string (), KeyboardConstants.key_bindings[j++], true);
                input_binding_items.append (cs_note_item);
                input_key_box.insert (cs_note_item, -1);
                var d_note_item = new ItemInput (j, "D " + i.to_string (), KeyboardConstants.key_bindings[j++], false);
                input_binding_items.append (d_note_item);
                input_key_box.insert (d_note_item, -1);
                var ds_note_item = new ItemInput (j, "E♭ " + i.to_string (), KeyboardConstants.key_bindings[j++], true);
                input_binding_items.append (ds_note_item);
                input_key_box.insert (ds_note_item, -1);
                var e_note_item = new ItemInput (j, "E " + i.to_string (), KeyboardConstants.key_bindings[j++], false);
                input_binding_items.append (e_note_item);
                input_key_box.insert (e_note_item, -1);
                var f_note_item = new ItemInput (j, "F " + i.to_string (), KeyboardConstants.key_bindings[j++], false);
                input_binding_items.append (f_note_item);
                input_key_box.insert (f_note_item, -1);
                var fs_note_item = new ItemInput (j, "F♯ " + i.to_string (), KeyboardConstants.key_bindings[j++], true);
                input_binding_items.append (fs_note_item);
                input_key_box.insert (fs_note_item, -1);
                var g_note_item = new ItemInput (j, "G " + i.to_string (), KeyboardConstants.key_bindings[j++], false);
                input_binding_items.append (g_note_item);
                input_key_box.insert (g_note_item, -1);
                var gs_note_item = new ItemInput (j, "G♯ " + i.to_string (), KeyboardConstants.key_bindings[j++], true);
                input_binding_items.append (gs_note_item);
                input_key_box.insert (gs_note_item, -1);
                var a_note_item = new ItemInput (j, "A " + i.to_string (), KeyboardConstants.key_bindings[j++], false);
                input_binding_items.append (a_note_item);
                input_key_box.insert (a_note_item, -1);
                var bf_note_item = new ItemInput (j, "B♭ " + i.to_string (), KeyboardConstants.key_bindings[j++], true);
                input_binding_items.append (bf_note_item);
                input_key_box.insert (bf_note_item, -1);
                var b_note_item = new ItemInput (j, "B " + i.to_string (), KeyboardConstants.key_bindings[j++], false);
                input_binding_items.append (b_note_item);
                input_key_box.insert (b_note_item, -1);
            }

            BindingUpdate update_bindings_ui = (() => {
                for (int i = 0; i < 60; i++) {
                    input_binding_items.nth_data (i).update_labels (KeyboardConstants.key_bindings[i]);
                }
            });

            update_bindings_ui ();

            mapping_file_open_chooser.response.connect ((response_id) => {
                if (response_id == -3) {
                    KeyboardConstants.load_mapping (Application.settings,
                        mapping_file_open_chooser.get_file ());
                    update_bindings_ui ();
                }
            });

            input_key_box.row_activated.connect ((row) => {
                selected_input_item = (ItemInput)row;
            });

            var key_event_controller = new Gtk.EventControllerKey ();

            input_key_box.add_controller ((Gtk.ShortcutController) key_event_controller);

            key_event_controller.key_pressed.connect ((keyval) => {;
                if (keyval == KeyboardConstants.KeyMap.ESCAPE) {
                    input_key_box.unselect_all ();
                    selected_input_item = null;
                } else {
                    if (selected_input_item != null) {
                        if ((keyval > 64 && keyval < 91) ||
                            (keyval > 96 && keyval < 123) ||
                            keyval == 44 ||
                            keyval == 46 ||
                            keyval == 47 ||
                            keyval == 91 ||
                            keyval == 93 ||
                            keyval == 123 ||
                            keyval == 125 ||
                            keyval == 60 ||
                            keyval == 62 ||
                            keyval == 63 ||
                            keyval == 59 ||
                            keyval == 39 ||
                            keyval == 34 ||
                            keyval == 58) {

                            KeyboardConstants.key_bindings[
                                selected_input_item.note_index
                            ] = (KeyboardConstants.KeyMap)keyval;
                            selected_input_item.update_labels (
                                KeyboardConstants.key_bindings[selected_input_item.note_index]
                            );
                            KeyboardConstants.save_mapping (Application.settings);
                            input_key_box.unselect_all ();
                            selected_input_item = null;
                        }
                    }
                }
                return false;
            });

            var scrollable = new Gtk.ScrolledWindow () {
                vexpand = true
            };
            scrollable.set_child (input_key_box);

            var open_pc_input_preset_button = new Gtk.Button.with_label (_("Import PC Keyboard Input Preset")) {
                hexpand = true
            };
            open_pc_input_preset_button.clicked.connect (() => {
                mapping_file_open_chooser.show ();
                mapping_file_open_chooser.hide ();
            });
            var save_pc_input_preset_button = new Gtk.Button.from_icon_name (
                "document-save-as-symbolic"
            );
            save_pc_input_preset_button.get_style_context ().remove_class ("image-button");
            save_pc_input_preset_button.tooltip_text = _("Export preset as");
            save_pc_input_preset_button.clicked.connect (() => {
                mapping_file_chooser.show ();
                mapping_file_chooser.hide ();
            });
            var btn_grid = new Gtk.Grid () {
                margin_top = 4,
                margin_bottom = 4,
                margin_start = 4,
                margin_end = 4,
                column_spacing = 4
            };
            btn_grid.attach (open_pc_input_preset_button, 0, 0);
            btn_grid.attach (save_pc_input_preset_button, 1, 0);

            var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            header_stack.add_named (top_box, "input");
            var separator_a = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            main_box.append (separator_a);
            main_box.append (scrollable);
            var separator_b = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            main_box.append (separator_b);
            main_box.append (btn_grid);

            return main_box;
        }

        private Gtk.Widget get_midi_widget () {
            var top_box = new Dialogs.Preferences.TopBox ("input-gaming", _("MIDI Input Presets"));
            top_box.back_activated.connect (() => {
                stack.visible_child_name = "home";
                header_stack.visible_child_name = "home";
            });

            top_box.done_activated.connect (() => {
                hide_destroy ();
            });

            header_stack.add_named (top_box, "midi");

            var main_box = new Gtk.Grid () {
                margin_start = 4,
                margin_end = 4,
                margin_top = 4,
                margin_bottom = 4,
                row_spacing = 14,
                column_spacing = 4
            };

            var notes = new Gtk.Label (
                _("You can load presets from csv file and export your current settings to another file. ")
                + _("These presets can often be used for easily binding certain MIDI controllers. ")
                + _("You can combine presets by setting the import mode to 'Append'. ")
                + _("To bind manually, right click on a control for more options.")
            ) {
                wrap = true,
                justify = Gtk.Justification.LEFT,
            };
            main_box.attach (notes, 0, 0, 2, 1);

            var label = new Gtk.Label (_("Import Mode")) {
                halign = Gtk.Align.START,
                margin_start = 8
            };
            main_box.attach (label, 0, 1, 2, 1);

            var replace_mode_button = new Gtk.CheckButton.with_label (_("Replace")) {
                margin_start = 12
            };
            main_box.attach (replace_mode_button, 0, 2, 2, 1);

            var append_mode_button = new Gtk.CheckButton.with_label (_("Append")) {
                group = replace_mode_button,
                margin_start = 12
            };
            main_box.attach (append_mode_button, 0, 3, 2, 1);

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
                vexpand = true,
                valign = Gtk.Align.START
            };
            main_box.attach (separator, 0, 4, 2, 1);

            var import_button = new Gtk.Button.with_label (_("Import Preset")) {
                hexpand = true
            };
            import_button.get_style_context ().add_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);
            main_box.attach (import_button, 0, 5);

            var export_button = new Gtk.Button.from_icon_name ("document-save-as-symbolic") {
                tooltip_text = _("Export preset as")
            };
            export_button.get_style_context ().remove_class ("image-button");
            main_box.attach (export_button, 1, 5);

            bool append_mode = false;
            append_mode_button.toggled.connect (() => {
                append_mode = append_mode_button.active;
            });

            var file_filter_csv = new Gtk.FileFilter ();
            file_filter_csv.add_mime_type ("text/csv");
            file_filter_csv.set_filter_name (_("Comma Separated Values File"));

            var default_controller_preset_dir = Application.user_config_dir + "/midi_controller_presets";

            if (DirUtils.create_with_parents (Application.user_config_dir, 2000) != -1) {
                if (DirUtils.create_with_parents (
                    default_controller_preset_dir, 2000) != -1) {
                    debug ("Made input presets folder\n");
                }
            }

            File controller_preset_file = File.new_for_path (default_controller_preset_dir);

            Gtk.FileChooserDialog mapping_file_open_chooser;
            mapping_file_open_chooser = new Gtk.FileChooserDialog (_("Import MIDI Input Preset"),
                                                                Application.main_window,
                                                                Gtk.FileChooserAction.OPEN,
                                                                _("Cancel"),
                                                                Gtk.ResponseType.CANCEL,
                                                                _("Import"),
                                                                Gtk.ResponseType.ACCEPT
                                                                );

            mapping_file_open_chooser.set_filter (file_filter_csv);
            mapping_file_open_chooser.set_current_folder (controller_preset_file);

            import_button.clicked.connect (() => {
                mapping_file_open_chooser.show ();
                mapping_file_open_chooser.hide ();
            });

            mapping_file_open_chooser.response.connect ((response_id) => {
                if (response_id == -3) {
                    string[,] csv_data;
                    Utils.read_csv (mapping_file_open_chooser.get_file (), out csv_data);
                    string[] note_maps = {};
                    string[] control_maps = {};
                    string[] control_label_maps = {};
                    for (int i = 0; i < csv_data.length[0]; i++) {
                        if (csv_data[i, 0].length > 0) {
                            note_maps += csv_data[i, 0];
                        }

                        if (csv_data[i, 1].length > 0) {
                            control_maps += csv_data[i, 1];
                        }

                        if (csv_data[i, 2].length > 0) {
                            control_label_maps += csv_data[i, 2];
                        }
                    }

                    Application.arranger_core.midi_input_host.load_maps (
                        append_mode,
                        note_maps,
                        control_maps,
                        control_label_maps
                    );
                }
            });

            Gtk.FileChooserDialog mapping_file_chooser;
            mapping_file_chooser = new Gtk.FileChooserDialog (_("Export MIDI Input Preset"),
                                                                Application.main_window,
                                                                Gtk.FileChooserAction.SAVE,
                                                                _("Cancel"),
                                                                Gtk.ResponseType.CANCEL,
                                                                _("Export"),
                                                                Gtk.ResponseType.ACCEPT
                                                                );
            mapping_file_chooser.set_current_folder (controller_preset_file);
            mapping_file_chooser.set_current_name ("UntitledDevice.csv");

            export_button.clicked.connect (() => {
                mapping_file_chooser.show ();
                mapping_file_chooser.hide ();
            });

            mapping_file_chooser.response.connect ((response_id) => {
                if (response_id == -3) {
                    //  KeyboardConstants.save_mapping (Application.settings, mapping_file_chooser.get_file ().get_path ());
                    var note_maps = Application.settings.get_strv ("note-maps");
                    var control_maps = Application.settings.get_strv ("control-maps");
                    var label_maps = Application.settings.get_strv ("control-label-maps");

                    uint m = uint.max (uint.max (note_maps.length, control_maps.length), label_maps.length);

                    var array = new string[m, 3];

                    for (int i = 0; i < m; i++) {
                        if (i < note_maps.length) {
                            array[i, 0] = note_maps[i];
                        }

                        if (i < control_maps.length) {
                            array[i, 1] = control_maps[i];
                        }

                        if (i < label_maps.length) {
                            array[i, 2] = label_maps[i];
                        }
                    }

                    Utils.save_csv (mapping_file_chooser.get_file (), array);
                }
            });

            return main_box;
        }

        private Gtk.Widget get_appearance_widget () {
            var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            var top_box = new Dialogs.Preferences.TopBox ("applications-graphics", _("Appearance"));
            header_stack.add_named (top_box, "theme");

            var separator_a = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            main_box.append (separator_a);

            var key_label = new Gtk.Label (_("Note Visualization Legend")) {
                xalign = 0,
                margin_top = 8,
                margin_bottom = 8,
                margin_start = 8,
                margin_end = 8
            };
            main_box.append (key_label);

            var key_theme_guide = new Gtk.Grid () {
                column_homogeneous = true,
                column_spacing = 4,
                row_spacing = 4,
                margin_top = 8,
                margin_bottom = 8,
                margin_start = 8,
                margin_end = 8
            };

            var key_legend_primary = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                halign = Gtk.Align.CENTER,
                width_request = 48,
                height_request = 48
            };
            key_legend_primary.get_style_context ().add_class ("key_label_primary");
            var key_legend_secondary = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                halign = Gtk.Align.CENTER,
                width_request = 48,
                height_request = 48
            };
            key_legend_secondary.get_style_context ().add_class ("key_label_secondary");
            var key_legend_auto = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                halign = Gtk.Align.CENTER,
                width_request = 48,
                height_request = 48
            };
            key_legend_auto.get_style_context ().add_class ("key_label_auto");

            var key_accent_primary = new Gtk.Label (_("Voice R1, Voice R2")) {
                opacity = 0.5
            };
            var key_accent_secondary = new Gtk.Label (_("Voice L, Chords")) {
                opacity = 0.5
            };
            var key_accent_automatic = new Gtk.Label (_("Automations")) {
                opacity = 0.5
            };

            key_theme_guide.attach (key_legend_primary, 0, 0);
            key_theme_guide.attach (key_legend_secondary, 1, 0);
            key_theme_guide.attach (key_legend_auto, 2, 0);
            key_theme_guide.attach (key_accent_primary, 0, 1);
            key_theme_guide.attach (key_accent_secondary, 1, 1);
            key_theme_guide.attach (key_accent_automatic, 2, 1);

            main_box.append (key_theme_guide);

            var display_preview = new Gtk.Grid () {
                column_homogeneous = true,
                margin_start = 8,
                margin_top = 8,
                margin_end = 8,
                margin_bottom = 8
            };
            display_preview.get_style_context ().add_class ("central-display-preview");
            display_preview.get_style_context ().add_class ("ensembles-central-display");
            var top_bar_preview = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                height_request = 30
            };
            top_bar_preview.get_style_context ().add_class ("home-screen-panel-top");
            var bottom_bar_preview = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                height_request = 60
            };
            bottom_bar_preview.get_style_context ().add_class ("home-screen-panel-bottom");
            var home_preview = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                height_request = 154
            };
            home_preview.get_style_context ().add_class ("home-screen-background");

            home_preview.append (top_bar_preview);
            home_preview.append (bottom_bar_preview);

            display_preview.attach (home_preview, 0, 0);

            var loop = new MainLoop ();
            List<string> theme_list = new List<string> ();
            Utils.get_theme_list.begin ((obj, res) => {
                var themes = Utils.get_theme_list.end (res);
                int selected_index = -1;
                var selected_theme = Application.settings.get_string ("display-theme");
                for (int i = 0; i < themes.length; i++) {
                    theme_list.append (themes[i]);
                    print ("%s %s\n", themes[i], selected_theme);
                    if (themes[i] == selected_theme) {
                        selected_index = i;
                    }
                }
                var theme_select = new Dialogs.Preferences.ItemSelect (
                    _("Central Display Theme"),
                    selected_index,
                    theme_list,
                    true
                );
                theme_select.activated.connect ((index) => {
                    Application.settings.set_string ("display-theme", theme_list.nth_data (index));
                    print ("%s\n", theme_list.nth_data (index));
                    Application.init_theme ();
                });
                main_box.append (theme_select);
                main_box.append (display_preview);
                loop.quit ();
            });
            loop.run ();

            top_box.back_activated.connect (() => {
                stack.visible_child_name = "home";
                header_stack.visible_child_name = "home";
            });

            top_box.done_activated.connect (() => {
                hide_destroy ();
            });


            return main_box;
        }

        private Gtk.Widget get_about_widget () {
            var top_box = new Dialogs.Preferences.TopBox ("help-about", _("About"));

            Gdk.Pixbuf header_logo = new Gdk.Pixbuf (Gdk.Colorspace.RGB, true, 8, 2, 2);
            try {
                header_logo = new Gdk.Pixbuf.from_resource (
                    "/com/github/subhadeepjasu/ensembles/images/ensembles_logo.svg"
                );
            } catch (Error e) {
                warning (e.message);
            }
            header_logo = header_logo.scale_simple (256, 59, Gdk.InterpType.BILINEAR);
            var header_logo_image = new Gtk.Image.from_pixbuf (header_logo);
            header_logo_image.margin_start = 4;
            header_logo_image.margin_top = 4;

            var fluid_version = Core.Synthesizer.get_fluidsynth_version ();
            // TRANSLATORS: %1.1f is a version number
            var fluidsynth_version = new Gtk.Label ((_("Powered by FluidSynth v%1.1f")).printf (fluid_version));
            fluidsynth_version.get_style_context ().add_class ("h3");
            fluidsynth_version.margin_top = 6;

            var version_label = new Gtk.Label ("AW - 200");
            version_label.get_style_context ().add_class ("dim-label");

            var web_item = new Dialogs.Preferences.Item ("web-browser", _("Website"));
            var github_item = new Dialogs.Preferences.Item ("github", _("Github"));
            var twitter_item = new Dialogs.Preferences.Item ("online-account-twitter", _("Follow"));
            var issue_item = new Dialogs.Preferences.Item ("bug", _("Report a Problem"));
            var translation_item = new Dialogs.Preferences.Item ("config-language", _("Suggest Translations"), true);

            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                margin_top = 24,
                valign = Gtk.Align.START
            };
            box.get_style_context ().add_class ("preferences-view");
            box.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            box.append (web_item);
            box.append (github_item);
            box.append (twitter_item);
            box.append (issue_item);
            box.append (translation_item);
            box.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

            var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                hexpand = true,
                vexpand = true
            };

            header_stack.add_named (top_box, "about");
            main_box.append (header_logo_image);
            main_box.append (version_label);
            main_box.append (fluidsynth_version);
            main_box.append (box);

            top_box.back_activated.connect (() => {
                stack.visible_child_name = "home";
                header_stack.visible_child_name = "home";
            });

            top_box.done_activated.connect (() => {
                hide_destroy ();
            });

            web_item.activated.connect (() => {
                try {
                    AppInfo.launch_default_for_uri ("https://subhadeepjasu.github.io/#/project/ensembles", null);
                } catch (Error e) {
                    warning ("%s\n", e.message);
                }
            });

            github_item.activated.connect (() => {
                try {
                    AppInfo.launch_default_for_uri ("https://github.com/SubhadeepJasu/Ensembles", null);
                } catch (Error e) {
                    warning ("%s\n", e.message);
                }
            });

            twitter_item.activated.connect (() => {
                try {
                    AppInfo.launch_default_for_uri ("https://twitter.com/subhajasu", null);
                } catch (Error e) {
                    warning ("%s\n", e.message);
                }
            });

            issue_item.activated.connect (() => {
                try {
                    AppInfo.launch_default_for_uri ("https://github.com/SubhadeepJasu/Ensembles/issues", null);
                } catch (Error e) {
                    warning ("%s\n", e.message);
                }
            });

            translation_item.activated.connect (() => {
                try {
                    AppInfo.launch_default_for_uri (
                        "https://github.com/SubhadeepJasu/Ensembles/tree/master/po", null
                    );
                } catch (Error e) {
                    warning ("%s\n", e.message);
                }
            });

            return main_box;
        }

        private void hide_destroy () {
            hide ();

            Timeout.add (500, () => {
                destroy ();
                return GLib.Source.REMOVE;
            });
        }
    }
}
