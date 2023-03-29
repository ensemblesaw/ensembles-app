/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Core.Plugins.AudioPlugins;
using Ensembles.Shell.Widgets.Display;

namespace Ensembles.Shell.Layouts.Display {
    public class AudioPluginPicker : WheelScrollableWidget {
        public Core.Plugins.AudioPlugins.AudioPlugin.Category category {
            get;
            private set;
        }
        private Gtk.ListBox main_list_box;

        public AudioPluginPicker (Core.Plugins.AudioPlugins.AudioPlugin.Category category) {
            Object (
                width_request: 500,
                hexpand: false,
                vexpand: true
            );
            this.category = category;

            build_ui ();
            build_events ();
        }

        public void build_ui () {
            var scrollable = new Gtk.ScrolledWindow () {
                hexpand = true,
                vexpand = true
            };
            append (scrollable);

            main_list_box = new Gtk.ListBox () {
                selection_mode = Gtk.SelectionMode.NONE
            };
            main_list_box.add_css_class ("plugin-list");
            scrollable.set_child (main_list_box);
        }

        private void build_events () {
            Application.event_bus.arranger_ready.connect (() => {
                Timeout.add (2200, () => {
                    Idle.add (() => {
                        populate (Application.arranger_workstation.get_audio_plugins ());
                        return false;
                    });
                    return false;
                });
            });
        }

        public void populate (List<AudioPlugin> plugins) {
            for (uint16 i = 0; i < plugins.length (); i++) {
                var menu_item = new DSPMenuItem (plugins.nth_data (i));
                main_list_box.insert (menu_item, -1);
            }

            min_value = 0;
            max_value = (int) plugins.length () - 1;
        }
    }
}
