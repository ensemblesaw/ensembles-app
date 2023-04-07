/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Shell.Widgets.Display;
using Ensembles.Models;
using Ensembles.Core.Plugins.AudioPlugins;
using Ensembles.Core.Racks;

namespace Ensembles.Shell.Layouts.Display {
    /**
     * Shows a list of voices from SoundFont and Voice plugins
     */
    public class VoiceScreen : DisplayWindow {
        public VoiceHandPosition hand_position { get; private set; }
        private Gtk.ListBox main_list_box;

        private uint16 last_voice_index = 1;

        public VoiceScreen (VoiceHandPosition hand_position) {
            var title_by_position = "";
            var subtitle_by_position = "";
            switch (hand_position) {
                case VoiceHandPosition.LEFT:
                    title_by_position = _("Left (Split)");
                    subtitle_by_position = _("Pick a Voice to play on the left hand side of split");
                    break;
                case VoiceHandPosition.RIGHT:
                    title_by_position = _("Right 1 (Main)");
                    subtitle_by_position = _("Pick a Voice to play");
                    break;
                case VoiceHandPosition.RIGHT_LAYERED:
                    title_by_position = _("Right 2 (Layered)");
                    subtitle_by_position = _("Pick a Voice to play on another layer");
                    break;
            }
            base (
                _("Voice - %s").printf (title_by_position),
                subtitle_by_position
            );
            this.hand_position = hand_position;
        }

        construct {
            build_ui ();
            build_events ();
        }

        private void build_ui () {
            var scrollable = new Gtk.ScrolledWindow () {
                hexpand = true,
                vexpand = true,
                margin_start = 8,
                margin_end = 8,
                margin_top = 8,
                margin_bottom = 8
            };
            append (scrollable);

            main_list_box = new Gtk.ListBox () {
                selection_mode = Gtk.SelectionMode.SINGLE
            };
            main_list_box.add_css_class ("menu-box");
            scrollable.set_child (main_list_box);
        }

        public void build_events () {
            Application.event_bus.arranger_ready.connect (() => {
                populate_plugins (Application.arranger_workstation.get_voice_rack (hand_position).get_plugins ());
            });
        }

        public void populate (Voice[] voices) {

        }

        public void populate_plugins (List<AudioPlugin> plugins) {
            var temp_category = AudioPlugin.Tech.NATIVE;
            for (uint16 i = 0; i < plugins.length (); i++) {
                if (plugins.nth_data (i).category == AudioPlugin.Category.VOICE) {
                    var show_category = false;
                    if (temp_category != plugins.nth_data (i).tech) {
                        temp_category = plugins.nth_data (i).tech;
                        show_category = true;
                    }
                    var menu_item = new VoiceMenuItem (
                        last_voice_index++,
                        null,
                        plugins.nth_data (i),
                        show_category);
                    main_list_box.insert (menu_item, -1);
                }
            }
        }

        public void scroll_to_selected_row () {
            var selected_item = main_list_box.get_selected_row ();
            if (selected_item != null) {
                selected_item.grab_focus ();

                //  var adj = main_list_box.get_adjustment ();
                //  if (adj != null) {
                //      int height, _htemp;
                //      height = selected_item.get_allocated_height ();

                //      Timeout.add (200, () => {
                //          adj.set_value (_selected_index * height);
                //          return false;
                //      });
                //  }
            }
        }
    }
}
