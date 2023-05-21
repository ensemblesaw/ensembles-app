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

        private uint16 last_voice_index = 0;
        private uint16 plugin_start_index = 0;

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
                vexpand = true
            };
            append (scrollable);

            main_list_box = new Gtk.ListBox () {
                selection_mode = Gtk.SelectionMode.SINGLE
            };
            main_list_box.add_css_class ("menu-box");
            scrollable.set_child (main_list_box);
        }

        public void build_events () {
            main_list_box.row_selected.connect ((item) => {
                var voice_item = (VoiceMenuItem) item;
                if (voice_item.is_plugin) {
                    Application.event_bus.voice_chosen (hand_position, voice_item.plugin.name, 0, 0);
                    Application.arranger_workstation.get_voice_rack (hand_position).active = true;
                    Application.arranger_workstation.get_voice_rack (hand_position)
                    .set_plugin_active (item.get_index () - plugin_start_index, true);
                } else {
                    Application.arranger_workstation.get_voice_rack (hand_position).active = false;
                    Application.event_bus.voice_chosen (
                        hand_position, voice_item.voice.name, voice_item.voice.bank, voice_item.voice.preset
                    );
                }
            });
            Application.event_bus.arranger_ready.connect (() => {
                populate (Application.arranger_workstation.get_voices ());
                populate_plugins (Application.arranger_workstation.get_voice_rack (hand_position).get_plugins ());
            });
        }

        public void populate (Voice[] voices) {
            var temp_category = "";
            for (uint16 i = 0; i < voices.length; i++) {
                var show_category = false;
                if (temp_category != voices[i].category) {
                    temp_category = voices[i].category;
                    show_category = true;
                }

                var menu_item = new VoiceMenuItem (
                    last_voice_index++,
                    voices[i],
                    null,
                    show_category
                );
                main_list_box.insert (menu_item, -1);
            }

            plugin_start_index = last_voice_index;
        }

        public void populate_plugins (List<AudioPlugin> plugins) {
            var temp_category = AudioPlugin.Protocol.NATIVE;
            for (uint16 i = 0; i < plugins.length (); i++) {
                if (plugins.nth_data (i).category == AudioPlugin.Category.VOICE) {
                    var show_category = false;
                    if (temp_category != plugins.nth_data (i).protocol) {
                        temp_category = plugins.nth_data (i).protocol;
                        show_category = true;
                    }

                    var menu_item = new VoiceMenuItem (
                        last_voice_index++,
                        Voice (),
                        plugins.nth_data (i),
                        show_category
                    );
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
