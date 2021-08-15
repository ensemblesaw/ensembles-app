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
    public class VoiceMenu : WheelScrollableWidget {
        int channel;
        Gtk.Button close_button;
        Gtk.ListBox main_list;
        VoiceItem[] voice_rows;
        int _selected_index;

        public signal void close_menu ();
        public signal void change_voice (Ensembles.Core.Voice voice, int channel);
        public VoiceMenu (int channel) {
            this.channel = channel;
            this.get_style_context ().add_class ("menu-background");

            close_button = new Gtk.Button.from_icon_name ("application-exit-symbolic", Gtk.IconSize.BUTTON);
            close_button.margin_end = 4;
            close_button.halign = Gtk.Align.END;


            var headerbar = new Hdy.HeaderBar ();
            headerbar.set_title ("Voice - " + ((channel == 0) ? "Right 1 (Main)" : (channel == 1)
            ? "Right 2 (Layered)"
            : "Left (Split)"));
            headerbar.set_subtitle ("Pick a Voice to play" + ((channel == 0) ? "" : (channel == 1)
            ? " on another layer"
            : " on left hand side of split"));
            headerbar.get_style_context ().add_class ("menu-header");
            headerbar.pack_start (close_button);
            main_list = new Gtk.ListBox ();
            main_list.get_style_context ().add_class ("menu-box");

            var scrollable = new Gtk.ScrolledWindow (null, null);
            scrollable.hexpand = true;
            scrollable.vexpand = true;
            scrollable.margin = 8;
            scrollable.add (main_list);

            this.attach (headerbar, 0, 0, 1, 1);
            this.attach (scrollable, 0, 1, 1, 1);


            close_button.clicked.connect (() => {
                close_menu ();
            });

            main_list.set_selection_mode (Gtk.SelectionMode.BROWSE);
            main_list.row_activated.connect ((row) => {
                int index = row.get_index ();
                _selected_index = index;
                scroll_wheel_location = index;
                change_voice (voice_rows[index].voice, channel);
                switch (channel) {
                    case 0:
                    EnsemblesApp.settings.set_int ("voice-r1-index", index);
                    break;
                    case 1:
                    EnsemblesApp.settings.set_int ("voice-r2-index", index);
                    break;
                    case 2:
                    EnsemblesApp.settings.set_int ("voice-l-index", index);
                    break;
                }
            });

            wheel_scrolled_absolute.connect ((value) => {
                Idle.add (() => {
                    quick_select_row (value);
                    return false;
                });
            });
        }

        public void populate_voice_menu (Ensembles.Core.Voice[] voices) {
            voice_rows = new VoiceItem [voices.length];
            string temp_category = "";
            for (int i = 0; i < voices.length; i++) {
                bool show_category = false;
                if (temp_category != voices[i].category) {
                    temp_category = voices[i].category;
                    show_category = true;
                }
                var row = new VoiceItem (voices[i], show_category);
                voice_rows[i] = row;
                main_list.insert (row, -1);
            }
            load_settings ();
            min_value = 0;
            max_value = voice_rows.length - 1;
            main_list.show_all ();
        }

        public void scroll_to_selected_row () {
            voice_rows[_selected_index].grab_focus ();
            if (main_list != null) {
                var adj = main_list.get_adjustment ();
                if (adj != null) {
                    int height, _htemp;
                    voice_rows[_selected_index].get_preferred_height (out _htemp, out height);
                    Timeout.add (200, () => {
                        adj.set_value (_selected_index * height);
                        return false;
                    });
                }
            }
        }

        public void quick_select_row (int index) {
            Idle.add (() => {
                main_list.select_row (voice_rows[index]);
                _selected_index = index;
                scroll_wheel_location = index;
                change_voice (voice_rows[index].voice, channel);
                scroll_to_selected_row ();
                switch (channel) {
                    case 0:
                    EnsemblesApp.settings.set_int ("voice-r1-index", index);
                    break;
                    case 1:
                    EnsemblesApp.settings.set_int ("voice-r2-index", index);
                    break;
                    case 2:
                    EnsemblesApp.settings.set_int ("voice-l-index", index);
                    break;
                }
                return false;
            });
        }

        public void load_settings () {
            switch (channel) {
                case 0:
                quick_select_row (EnsemblesApp.settings.get_int ("voice-r1-index"));
                break;
                case 1:
                quick_select_row (EnsemblesApp.settings.get_int ("voice-r2-index"));
                break;
                case 2:
                quick_select_row (EnsemblesApp.settings.get_int ("voice-l-index"));
                break;
            }
        }

        public void scroll_wheel_activate () {
            close_menu ();
        }
    }
}
