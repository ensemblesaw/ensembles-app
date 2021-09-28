/*/
*- Copyright © 2021 Subhadeep Jasu
*- Copyright © 2019 Alain M. (https://github.com/alainm23/planner)
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
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alain M. <alainmh23@gmail.com>
*              Subhadeep Jasu <subhajasu@gmail.com>
*/

namespace Ensembles.Shell.Dialogs.Preferences {
    public class Preferences : Hdy.Window {
        public string view { get; construct; }
        private Gtk.Stack stack;
        //private uint timeout_id = 0;

        private const Gtk.TargetEntry[] TARGET_ENTRIES_LABELS = {
            {"LABELROW", Gtk.TargetFlags.SAME_APP, 0}
        };

        public Preferences (string view="home") {
            Object (
                view: view,
                transient_for: Shell.EnsemblesApp.instance.main_window,
                deletable: true,
                resizable: true,
                destroy_with_parent: true,
                window_position: Gtk.WindowPosition.CENTER_ON_PARENT,
                modal: true,
                title: _("Preferences")
            );
        }

        construct {
            get_style_context ().add_class ("app");
    
            //  Core.CentralBus.halt ();
            width_request = 525;
            height_request = 400;
    
            stack = new Gtk.Stack ();
            stack.expand = true;
            stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

            // Add the views to stack
            stack.add_named (get_home_widget (), "home");
            stack.add_named (get_audio_widget (), "audio");
            stack.add_named (get_about_widget (), "about");

            // Show the intended view
            Timeout.add (125, () => {
                stack.visible_child_name = view;
                return GLib.Source.REMOVE;
            });

            var stack_scrolled = new Gtk.ScrolledWindow (null, null);
            stack_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
            stack_scrolled.vscrollbar_policy = Gtk.PolicyType.NEVER;
            stack_scrolled.expand = true;
            stack_scrolled.add (stack);

            var main_grid = new Gtk.Grid ();
            main_grid.expand = true;
            main_grid.orientation = Gtk.Orientation.VERTICAL;
            // main_grid.add (header);
            main_grid.add (stack_scrolled);

            add (main_grid);
            
            key_press_event.connect ((event) => {
                if (event.keyval == 65307) {
                    return true;
                }

                return false;
            });
        }

        private Gtk.Widget get_home_widget () {
            var header = new Hdy.HeaderBar ();
            header.decoration_layout = "close:";
            header.has_subtitle = false;
            header.show_close_button = false;
            header.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
    
            var settings_icon = new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            settings_icon.halign = Gtk.Align.CENTER;
            settings_icon.valign = Gtk.Align.CENTER;
    
            var settings_label = new Gtk.Label (_("Settings"));
            settings_label.get_style_context ().add_class ("h3");
    
            var done_button = new Gtk.Button.with_label (_("Done"));
            done_button.get_style_context ().add_class ("flat");
    
            var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            header_box.margin = 3;
            header_box.hexpand = true;
            header_box.pack_start (settings_icon, false, false, 0);
            header_box.pack_start (settings_label, false, false, 6);
            header_box.pack_end (done_button, false, false, 0);
    
            header.set_custom_title (header_box);
    
            /* General */        
            var audio_item = new Shell.Dialogs.Preferences.Item ("audio-card", _("Audio"));
            audio_item.icon_image.get_style_context ().add_class ("audio-card");
    
            var files_item = new Shell.Dialogs.Preferences.Item ("audio-x-generic", _("Files"));
            files_item.icon_image.get_style_context ().add_class ("audio-x-generic");
    
            var theme_item = new Shell.Dialogs.Preferences.Item ("applications-graphics", _("Appearance"), true);
            theme_item.icon_image.get_style_context ().add_class ("applications-graphics");
    
            var plugin_item = new Shell.Dialogs.Preferences.Item ("extension", _("Plugins"));
            plugin_item.icon_image.get_style_context ().add_class ("extension");
    
            var input_item = new Shell.Dialogs.Preferences.Item ("input-keyboard", _("Input"));
            input_item.icon_image.get_style_context ().add_class ("input-keyboard");
    
            var general_grid = new Gtk.Grid ();
            general_grid.valign = Gtk.Align.START;
            general_grid.margin_top = 18;
            general_grid.get_style_context ().add_class ("preferences-view");
            general_grid.orientation = Gtk.Orientation.VERTICAL;
            general_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            general_grid.add (audio_item);
            general_grid.add (files_item);
            general_grid.add (plugin_item);
            general_grid.add (input_item);
            general_grid.add (theme_item);
            general_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
    
            /* Others */
            var about_item = new Shell.Dialogs.Preferences.Item ("help-about", _("About"), true);
            about_item.icon_image.get_style_context ().add_class ("help-about");
    
            var others_grid = new Gtk.Grid ();
            others_grid.margin_top = 18;
            others_grid.margin_bottom = 3;
            others_grid.valign = Gtk.Align.START;
            others_grid.get_style_context ().add_class ("preferences-view");
            others_grid.orientation = Gtk.Orientation.VERTICAL;
            others_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            others_grid.add (about_item);
            // others_grid.add (fund_item);
            others_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
    
            var grid = new Gtk.Grid ();
            grid.orientation = Gtk.Orientation.VERTICAL;
            grid.valign = Gtk.Align.START;
            grid.add (general_grid);
            grid.add (others_grid);
    
            var main_scrolled = new Gtk.ScrolledWindow (null, null);
            main_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
            main_scrolled.expand = true;
            main_scrolled.add (grid);
    
            var main_grid = new Gtk.Grid ();
            main_grid.expand = true;
            main_grid.orientation = Gtk.Orientation.VERTICAL;
            main_grid.add (header);
            main_grid.add (main_scrolled);
    
            audio_item.activated.connect (() => {
                stack.visible_child_name = "audio";
            });
    
            files_item.activated.connect (() => {
                stack.visible_child_name = "badge-count";
            });
    
            theme_item.activated.connect (() => {
                stack.visible_child_name = "theme";
            });
    
            plugin_item.activated.connect (() => {
                stack.visible_child_name = "task";
            });
    
            input_item.activated.connect (() => {
                stack.visible_child_name = "quick-add";
            });

            about_item.activated.connect (() => {
                stack.visible_child_name = "about";
            });
    
            //  backups_item.activated.connect (() => {
            //      stack.visible_child_name = "backups";
            //  });
    
            done_button.clicked.connect ((response_id) => {
                destroy ();
            });
    
            return main_grid;
        }

        private Gtk.Widget get_audio_widget () {
            var top_box = new Shell.Dialogs.Preferences.TopBox ("audio-card", _("Audio"));
    
            var driver_list = new List<string> ();
            if (alsa_driver_found > 0) {
                driver_list.append ("Alsa");
            }
            if (pulseaudio_driver_found > 0) {
                driver_list.append ("PulseAudio");
            }
            if (pipewire_driver_found > 0) {
                driver_list.append ("PipeWire");
            }
            if (pipewire_pulse_driver_found > 0) {
                driver_list.append ("PipeWire Pulse");
            }

            int saved_driver = 0;

            switch (EnsemblesApp.settings.get_string ("driver")) {
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
            }

    
            var driver_select = new Dialogs.Preferences.ItemSelect (
                _("Driver"),
                saved_driver,
                driver_list,
                false
            );
            driver_select.margin_top = 12;
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
                }
                EnsemblesApp.settings.set_string ("driver", driver_string);
            });

            string buffer_length_text = _("Buffer length [%d frames]");

            var buffer_length = new Dialogs.Preferences.ItemScale (
                buffer_length_text,
                EnsemblesApp.settings.get_double ("buffer-length"),
                0,
                1,
                0.01,
                true
            );

            var pavuctrl_button = new Gtk.Button.with_label (_("System Mixer"));
            pavuctrl_button.margin = 4;
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
                    error_dialog.transient_for = (Gtk.Window) get_toplevel ();
                    error_dialog.show_all ();
                    error_dialog.present ();
                }
            });
    
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            box.margin_top = 6;
            box.valign = Gtk.Align.START;
            box.hexpand = true;
            box.add (driver_select);
            box.add (buffer_length);

            buffer_length.changed.connect ((value) => {
                EnsemblesApp.settings.set_double ("buffer-length", value);
                buffer_length.title = buffer_length_text.printf (Core.DriverSettingsProvider.change_period_size (value));
            });
    
            var box_scrolled = new Gtk.ScrolledWindow (null, null);
            box_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
            box_scrolled.expand = true;
            box_scrolled.add (box);
    
            var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            main_box.expand = true;
    
            main_box.pack_start (top_box, false, false, 0);
            main_box.pack_start (box_scrolled, false, true, 0);
            main_box.pack_end (pavuctrl_button, false, false, 0);
    
            top_box.back_activated.connect (() => {
                stack.visible_child_name = "home";
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
                header_logo = new Gdk.Pixbuf.from_resource ("/com/github/subhadeepjasu/ensembles/images/ensembles_logo.svg");
            } catch (Error e) {
                warning (e.message);
            }
            header_logo = header_logo.scale_simple (256, 59, Gdk.InterpType.BILINEAR);
            var header_logo_image = new Gtk.Image.from_pixbuf (header_logo);
            header_logo_image.margin_start = 4;
            header_logo_image.margin_top = 4;
    
            var fluid_version = Core.Synthesizer.get_fluidsynth_version ();
            var fluidsynth_version = new Gtk.Label (("Powered by FluidSynth v%1.1f").printf (fluid_version));
            fluidsynth_version.get_style_context ().add_class ("h3");
            fluidsynth_version.margin_top = 6;
    
            var version_label = new Gtk.Label ("AW - 100");
            version_label.get_style_context ().add_class ("dim-label");
    
            var web_item = new Dialogs.Preferences.Item ("web-browser", _("Website"));
            var github_item = new Dialogs.Preferences.Item ("github", _("Github"));
            var twitter_item = new Dialogs.Preferences.Item ("online-account-twitter", _("Follow"));
            var issue_item = new Dialogs.Preferences.Item ("bug", _("Report a Problem"));
            var translation_item = new Dialogs.Preferences.Item ("config-language", _("Suggest Translations"), true);
    
            var grid = new Gtk.Grid ();
            grid.margin_top = 24;
            grid.valign = Gtk.Align.START;
            grid.get_style_context ().add_class ("preferences-view");
            grid.orientation = Gtk.Orientation.VERTICAL;
            grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            grid.add (web_item);
            grid.add (github_item);
            grid.add (twitter_item);
            grid.add (issue_item);
            grid.add (translation_item);
            grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
    
            var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            main_box.expand = true;
    
            main_box.pack_start (top_box, false, false, 0);
            main_box.pack_start (header_logo_image, false, true, 0);
            main_box.pack_start (version_label, false, true, 0);
            main_box.pack_start (fluidsynth_version, false, true, 0);
            main_box.pack_start (grid, false, false, 0);
    
            top_box.back_activated.connect (() => {
                stack.visible_child_name = "home";
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
