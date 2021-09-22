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
            driver_list.append ("Alsa");
            driver_list.append ("PulseAudio");
            driver_list.append ("PipeWire");
    
            var driver_select = new Dialogs.Preferences.ItemSelect (
                _("Driver"),
                0,
                driver_list,
                false
            );
            driver_select.margin_top = 12;

            var buffer_length = new Dialogs.Preferences.ItemScale (
                _("Buffer length [%d frames]"),
                1024,
                64,
                4096,
                64,
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

        private void hide_destroy () {
            hide ();
    
            Timeout.add (500, () => {
                destroy ();
                return GLib.Source.REMOVE;
            });
        }
    }
}
