/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Core.Plugins.AudioPlugins;
using Ensembles.Shell.Widgets.Display;

namespace Ensembles.Shell.Layouts.Display {
    public class AudioPluginPicker : WheelScrollableWidget {
        public AudioPlugin.Category category {
            get;
            private set;
        }
        private Gtk.ListBox main_list_box;

        public AudioPluginPicker (AudioPlugin.Category category) {
            Object (
                width_request: 500,
                hexpand: false,
                vexpand: true,
                orientation: Gtk.Orientation.VERTICAL,
                spacing: 8
            );
            this.category = category;

            build_ui ();
            build_events ();
            populate (Application.arranger_workstation.get_audio_plugins ());
        }

        public void build_ui () {
            var plugin_picker_header = new Gtk.Label (_("A U D I O   P L U G I N S")) {
                halign = Gtk.Align.END,
                opacity = 0.5,
                margin_end = 14,
                margin_top = 24
            };
            plugin_picker_header.add_css_class (Granite.STYLE_CLASS_H3_LABEL);
            append (plugin_picker_header);

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

        }

        public void populate (List<AudioPlugin> plugins) {
            for (uint16 i = 0; i < plugins.length (); i++) {
                if (plugins.nth_data (i).category == category) {
                    var menu_item = new DSPMenuItem (plugins.nth_data (i),
                    Application.arranger_workstation.get_main_dsp_rack ());
                    main_list_box.insert (menu_item, -1);
                }
            }

            min_value = 0;
            max_value = (int) plugins.length () - 1;
        }
    }
}
