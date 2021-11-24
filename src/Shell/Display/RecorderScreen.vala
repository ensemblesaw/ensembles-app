/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class RecorderScreen : WheelScrollableWidget {
        Gtk.HeaderBar headerbar;
        Gtk.Grid sequencer_grid;
        Gtk.ScrolledWindow scrollable;
        Gtk.Button close_button;
        public signal void close_menu ();

        Gtk.Button new_button;
        Gtk.Button open_button;
        Gtk.Entry name_entry;

        Gtk.Stack main_stack;
        Gtk.Button play_button;
        Gtk.Button rec_button;
        Gtk.Button stop_button;
        Gtk.Stack btn_stack;

        Gtk.FileChooserDialog project_folder_chooser;
        Gtk.FileChooserDialog project_file_chooser;

        string save_location = "";
        string project_file_name = "";
        string project_name = "";
        string suffix = ".enproj";

        public static Core.MidiRecorder sequencer;

        public RecorderScreen () {
            this.get_style_context ().add_class ("menu-background");

            close_button = new Gtk.Button.from_icon_name ("application-exit-symbolic", Gtk.IconSize.BUTTON);
            close_button.margin_end = 4;
            close_button.halign = Gtk.Align.END;

            new_button = new Gtk.Button.from_icon_name ("document-new-symbolic", Gtk.IconSize.BUTTON);
            open_button = new Gtk.Button.from_icon_name ("document-open-symbolic", Gtk.IconSize.BUTTON);


            headerbar = new Gtk.HeaderBar ();
            headerbar.set_title (_("Recorder"));
            headerbar.set_subtitle (_("Record playback in multiple tracks"));
            headerbar.get_style_context ().add_class ("menu-header");
            headerbar.height_request = 42;
            headerbar.pack_start (close_button);
            headerbar.pack_start (new_button);
            headerbar.pack_start (open_button);

            btn_stack = new Gtk.Stack ();
            btn_stack.transition_type = Gtk.StackTransitionType.SLIDE_RIGHT;
            btn_stack.transition_duration = 500;

            play_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.BUTTON);
            play_button.sensitive = false;
            rec_button = new Gtk.Button.from_icon_name ("media-record-symbolic", Gtk.IconSize.BUTTON);
            rec_button.sensitive = false;
            stop_button = new Gtk.Button.from_icon_name ("media-playback-stop-symbolic", Gtk.IconSize.BUTTON);

            var btn_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            btn_box.pack_start (play_button);
            btn_box.pack_end (rec_button);

            btn_stack.add_named (btn_box, "Start");
            btn_stack.add_named (stop_button, "Stop");

            headerbar.pack_end (btn_stack);

            close_button.clicked.connect (() => {
                close_menu ();
                MainWindow.synthesizer.disable_input (false);
            });

            scrollable = new Gtk.ScrolledWindow (null, null);
            scrollable.hexpand = true;
            scrollable.vexpand = true;
            scrollable.margin = 8;

            this.attach (headerbar, 0, 0, 1, 1);
            this.attach (scrollable, 0, 1, 1, 1);

            main_stack = new Gtk.Stack ();
            main_stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
            main_stack.add_named (get_welcome_widget (), "Welcome");

            var name_grid = new Gtk.Grid ();
            var header_label = new Gtk.Label (_("Sequence Name"));
            header_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
            name_grid.attach (header_label, 0, 0, 2, 1);
            name_entry = new Gtk.Entry ();
            name_grid.attach (name_entry, 0, 1, 2, 1);
            name_grid.halign = Gtk.Align.CENTER;
            name_grid.valign = Gtk.Align.CENTER;

            save_location = Environment.get_home_dir () + "/Documents/Ensembles/RecorderProjects";

            if (DirUtils.create_with_parents (Environment.get_home_dir () + "/Documents/Ensembles", 2000) != -1) {
                if (DirUtils.create_with_parents (
                    save_location, 2000) != -1) {
                    debug ("Made user projects folder\n");
                }
            }

            var location_label = new Gtk.Label (save_location);
            location_label.get_style_context ().add_class (Granite.STYLE_CLASS_TERMINAL);
            location_label.ellipsize = Pango.EllipsizeMode.MIDDLE;
            name_grid.attach (location_label, 0, 2, 2, 1);

            project_folder_chooser = new Gtk.FileChooserDialog (_("Select Project Folder"),
                                                                Ensembles.Application.main_window,
                                                                Gtk.FileChooserAction.SELECT_FOLDER,
                                                                _("Cancel"),
                                                                Gtk.ResponseType.CANCEL,
                                                                _("Select"),
                                                                Gtk.ResponseType.ACCEPT
                                                                );
            project_folder_chooser.local_only = false;
            project_folder_chooser.modal = true;

            var location_change_button = new Gtk.Button.with_label (_("Change Project Location"));
            location_change_button.clicked.connect (() => {
                project_folder_chooser.run ();
                project_folder_chooser.hide ();
            });
            project_folder_chooser.response.connect ((response_id) => {
                if (response_id == -3) {
                    save_location = project_folder_chooser.get_file ().get_path ();
                }
                location_label.set_text (save_location);
            });
            name_grid.attach (location_change_button, 0, 3, 1, 1);

            project_file_chooser = new Gtk.FileChooserDialog (_("Open Project File"),
                                                                Ensembles.Application.main_window,
                                                                Gtk.FileChooserAction.OPEN,
                                                                _("Cancel"),
                                                                Gtk.ResponseType.CANCEL,
                                                                _("Open"),
                                                                Gtk.ResponseType.ACCEPT
                                                                );
            var file_filter_enproj = new Gtk.FileFilter ();
            file_filter_enproj.add_pattern ("*.enproj");
            file_filter_enproj.set_filter_name (_("Ensembles Recorder Project"));
            project_file_chooser.set_filter (file_filter_enproj);
            project_file_chooser.response.connect ((response_id) => {
                if (response_id == -3) {
                    create_project (project_file_chooser.get_file ().get_path ());
                }
            });

            var create_project_button = new Gtk.Button.with_label (_("Create Project"));
            create_project_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            create_project_button.clicked.connect (() => {
                project_name = name_entry.get_text ();
                create_project ();
            });
            name_grid.attach (create_project_button, 1, 3, 1, 1);
            name_grid.row_spacing = 4;
            name_grid.column_spacing = 4;
            name_grid.row_homogeneous = true;

            main_stack.add_named (name_grid, "EnterName");

            sequencer_grid = new Gtk.Grid ();
            main_stack.add_named (sequencer_grid, "SqnGrid");

            name_entry.activate.connect (() => {
                project_name = name_entry.get_text ();
                create_project ();
            });

            scrollable.add (main_stack);

            play_button.clicked.connect (() => {
                if (sequencer != null) {
                    sequencer.play ();
                }
            });

            rec_button.clicked.connect (() => {
                if (sequencer != null) {
                    sequencer.toggle_sync_start ();
                }
            });

            stop_button.clicked.connect (() => {
                if (sequencer != null) {
                    sequencer.stop ();
                    MainWindow.style_player.stop_style ();
                }
            });

            new_button.clicked.connect (() => {
                if (sequencer != null) {
                    sequencer.stop ();
                    MainWindow.style_player.stop_style ();
                }
                main_stack.set_visible_child_name ("EnterName");
                MainWindow.synthesizer.disable_input (true);
                play_button.sensitive = false;
                rec_button.sensitive = false;
                sequencer_grid.foreach ((widget) => {
                    sequencer_grid.remove (widget);
                    widget.unref ();
                });
                name_entry.set_text ("");
                name_entry.grab_focus ();
            });
        }

        void create_project (string? existing_file_path = null) {
            MainWindow.synthesizer.disable_input (false);
            play_button.sensitive = true;
            rec_button.sensitive = true;
            project_file_name = project_name.replace (" ", "_");
            project_file_name = project_file_name.replace ("/", "_");
            project_file_name = project_file_name.replace ("\\", "_");
            project_file_name = project_file_name.replace ("\"", "'");
            project_file_name = project_file_name.down ();
            project_file_name += suffix;
            sequencer = new Core.MidiRecorder (project_name,
                                               existing_file_path == null ? Path.build_filename (save_location, project_file_name) : existing_file_path,
                                               existing_file_path == null);
            headerbar.set_title (_("Recorder") + " - " + project_name);
            var visual = sequencer.get_sequencer_visual ();

            sequencer_grid.add (visual);
            visual.show_all ();
            main_stack.set_visible_child_name ("SqnGrid");

            sequencer.project_name_change.connect ((value) => {
                headerbar.set_title (_("Recorder") + " - " + value);
            });

            sequencer.progress_change.connect ((value) => {
                var adj = scrollable.get_hadjustment ();
                adj.set_value (value);
            });

            sequencer.set_ui_sensitive.connect ((sensitive) => {
                if (MainWindow.ctrl_panel != null) {
                    MainWindow.ctrl_panel.set_panel_sensitive (sensitive);
                }
                if (MainWindow.style_controller_view != null) {
                    MainWindow.style_controller_view.ready (sensitive);
                }
            });

            sequencer.note_event.connect ((channel, key, on, velocity) => {
                if (MainWindow.synthesizer != null) {
                    if (channel == 0) {
                        MainWindow.synthesizer.send_notes_realtime (key, on, velocity, 6, false);
                    } else {
                        MainWindow.synthesizer.send_notes_realtime (key, on, velocity, channel, false);
                    }
                }
            });

            sequencer.voice_change.connect ((channel, bank, index) => {
                if (MainWindow.synthesizer != null) {
                    var voice = new Core.Voice (index, bank, index, "", "");
                    if (channel == 0) {
                            MainWindow.synthesizer.change_voice (voice, 6, false);
                    } else {
                        MainWindow.synthesizer.change_voice (voice, channel, false);
                    }
                }
            });

            sequencer.layer_change.connect ((active) => {
                Ensembles.Core.CentralBus.set_layer_on (active);
            });

            sequencer.split_change.connect ((active) => {
                Ensembles.Core.CentralBus.set_split_on (active);
            });

            sequencer.accomp_change.connect ((active) => {
                if (MainWindow.synthesizer != null) {
                    MainWindow.synthesizer.set_accompaniment_on (active);
                }
            });

            sequencer.style_change.connect ((index) => {
                if (MainWindow.main_display_unit != null && MainWindow.main_display_unit.style_menu != null) {
                    MainWindow.main_display_unit.style_menu.quick_select_row (index, -0);
                }
            });

            sequencer.style_part_change.connect ((section) => {
                if (MainWindow.style_controller_view != null) {
                    MainWindow.style_controller_view.set_style_section_by_index (section);
                }
            });

            sequencer.style_start_stop.connect ((value) => {
                if (MainWindow.style_controller_view != null) {
                    if (value) {
                        MainWindow.style_player.stop_style ();
                    } else {
                        MainWindow.style_player.play_style ();
                    }
                }
            });

            sequencer.tempo_change.connect ((tempo) => {
                MainWindow.style_player.change_tempo (tempo);
            });

            sequencer.recorder_state_change.connect ((state) => {
                switch (state) {
                    case Core.MidiRecorder.RecorderState.PLAYING:
                    btn_stack.set_visible_child_name ("Stop");
                    break;
                    case Core.MidiRecorder.RecorderState.RECORDING:
                    play_button.sensitive = !play_button.sensitive;
                    play_button.opacity = play_button.sensitive ? 1.0 : 0.5;
                    btn_stack.set_visible_child_name ("Stop");
                    break;
                    case Core.MidiRecorder.RecorderState.STOPPED:
                    btn_stack.set_visible_child_name ("Start");
                    play_button.sensitive = true;
                    play_button.opacity = 1;
                    if (MainWindow.ctrl_panel != null) {
                        MainWindow.ctrl_panel.load_settings ();
                    }
                    break;
                }
            });
        }

        void save_project () {
            sequencer.save_sequence_to_file ();
        }

        Granite.Widgets.Welcome get_welcome_widget () {
            var welcome = new Granite.Widgets.Welcome (_("No Project Open"), _("Create a new project to start recording"));
            welcome.append ("document-new", _("New Project"), _("Creates a new project from scratch"));
            welcome.append ("document-open", _("Open Project"), _("Opens a pre-recorded project file"));

            welcome.activated.connect ((index) => {
                switch (index) {
                    case 0:
                        main_stack.set_visible_child_name ("EnterName");
                        MainWindow.synthesizer.disable_input (true);
                        play_button.sensitive = false;
                        rec_button.sensitive = false;
                        name_entry.grab_focus ();
                        break;
                    case 1:
                        project_file_chooser.run ();
                        project_file_chooser.hide ();
                        break;
                }
            });

            return welcome;
        }
    }
}
