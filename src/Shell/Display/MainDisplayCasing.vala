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
    public class MainDisplayCasing : Gtk.Box {
        Gtk.Stack main_stack;
        Gtk.Overlay main_overlay;
        Gtk.Image splash_screen;
        Hdy.Deck main_display_deck;
        Hdy.Leaflet main_display_leaflet;

        HomeScreen home_screen;
        StyleMenu style_menu;
        VoiceMenu voice_menu_l;
        VoiceMenu voice_menu_r1;
        VoiceMenu voice_menu_r2;

        public ChannelModulatorScreen channel_mod_screen;

        public signal void change_style (string path, string name, int tempo);
        public signal void change_voice (Ensembles.Core.Voice voice, int channel);

        public MainDisplayCasing() {
            home_screen = new HomeScreen ();
            style_menu = new StyleMenu ();
            voice_menu_l = new VoiceMenu (2);
            voice_menu_r1 = new VoiceMenu (0);
            voice_menu_r2 = new VoiceMenu (1);
            channel_mod_screen = new ChannelModulatorScreen (0, 0);

            main_stack = new Gtk.Stack ();
            main_stack.add_named (style_menu, "Styles Menu");
            main_stack.add_named (voice_menu_l, "Voice L Menu");
            main_stack.add_named (voice_menu_r1, "Voice R1 Menu");
            main_stack.add_named (voice_menu_r2, "Voice R2 Menu");
            main_stack.add_named (channel_mod_screen, "Channel Modulator Screen");


            splash_screen = new Gtk.Image.from_resource ("/com/github/subhadeepjasu/ensembles/images/display_unit/ensembles_splash.svg");


            main_display_leaflet = new Hdy.Leaflet ();
            main_display_leaflet.set_mode_transition_duration (400);
            main_display_leaflet.add (home_screen);
            main_display_leaflet.add (main_stack);
            main_display_leaflet.set_can_swipe_back (true);
            main_display_leaflet.set_transition_type (Hdy.LeafletTransitionType.SLIDE);

            main_display_deck = new Hdy.Deck();
            main_display_deck.add (main_display_leaflet);



            main_overlay = new Gtk.Overlay ();
            main_overlay.height_request = 236;
            main_overlay.width_request = 460;
            main_overlay.margin = 2;

            main_overlay.add_overlay (main_display_deck);
            main_overlay.add_overlay (splash_screen);
            this.get_style_context ().add_class ("display-background");

            this.add (main_overlay);
            this.halign = Gtk.Align.CENTER;
            this.valign = Gtk.Align.START;
            this.vexpand = false;
            this.margin = 4;

            make_events ();
        }

        public void queue_remove_splash () {
            Timeout.add (1000, () => {
                main_overlay.remove (splash_screen);
                return false;
            });
        }

        void make_events () {
            home_screen.open_style_menu.connect (() => {
                main_display_leaflet.set_visible_child (main_stack);
                main_stack.set_visible_child (style_menu);
            });
            home_screen.open_voice_l_menu.connect (() => {
                main_display_leaflet.set_visible_child (main_stack);
                main_stack.set_visible_child (voice_menu_l);
                voice_menu_l.scroll_to_selected_row ();
            });
            home_screen.open_voice_r1_menu.connect (() => {
                main_display_leaflet.set_visible_child (main_stack);
                main_stack.set_visible_child (voice_menu_r1);
                voice_menu_r1.scroll_to_selected_row ();
            });
            home_screen.open_voice_r2_menu.connect (() => {
                main_display_leaflet.set_visible_child (main_stack);
                main_stack.set_visible_child (voice_menu_r2);
                voice_menu_r2.scroll_to_selected_row ();
            });
            home_screen.edit_channel.connect (edit_channel);
            style_menu.close_menu.connect (() => {
                main_display_leaflet.set_visible_child (home_screen);
            });
            voice_menu_l.close_menu.connect (() => {
                main_display_leaflet.set_visible_child (home_screen);
            });
            voice_menu_r1.close_menu.connect (() => {
                main_display_leaflet.set_visible_child (home_screen);
            });
            voice_menu_r2.close_menu.connect (() => {
                main_display_leaflet.set_visible_child (home_screen);
            });
            channel_mod_screen.close_screen.connect (() => {
                main_display_leaflet.set_visible_child (home_screen);
            });
            style_menu.change_style.connect ((style_path, style_name, style_tempo) => {
                home_screen.set_style_name (style_name);
                this.change_style (style_path, style_name, style_tempo);
            });
            voice_menu_l.change_voice.connect ((voice, channel) => {
                home_screen.set_voice_l_name (voice.name);
                this.change_voice (voice, channel);
            });
            voice_menu_r1.change_voice.connect ((voice, channel) => {
                home_screen.set_voice_r1_name (voice.name);
                this.change_voice (voice, channel);
            });
            voice_menu_r2.change_voice.connect ((voice, channel) => {
                home_screen.set_voice_r2_name (voice.name);
                this.change_voice (voice, channel);
            });
        }

        public void update_style_list (List<string> paths, List<string> names, List<string> genre, List<int> tempo) {
            string[] path_arr = new string [paths.length ()];
            string[] name_arr = new string [names.length ()];
            string[] genre_arr = new string [genre.length ()];
            int[] tempo_arr = new int [tempo.length ()];
            for(int i = 0; i < paths.length (); i++) {
                path_arr [i] = paths.nth_data (i);
            }
            for(int i = 0; i < names.length (); i++) {
                name_arr [i] = names.nth_data (i);
            }
            for(int i = 0; i < genre.length (); i++) {
                genre_arr [i] = genre.nth_data (i);
            }
            for(int i = 0; i < tempo.length (); i++) {
                tempo_arr [i] = tempo.nth_data (i);
            }
            style_menu.populate_style_menu (path_arr, name_arr, genre_arr, tempo_arr);
            home_screen.set_style_name (name_arr[0]);
        }

        public void update_voice_list (Ensembles.Core.Voice[] voices) {
            voice_menu_l.populate_voice_menu (voices);
            voice_menu_r1.populate_voice_menu (voices);
            voice_menu_r2.populate_voice_menu (voices);
        }

        public void quick_select_voice (int index) {
            main_display_leaflet.set_visible_child (main_stack);
            main_stack.set_visible_child (voice_menu_r1);
            voice_menu_r1.quick_select_row (index);
        }

        public void set_tempo_display (int tempo) {
            home_screen.set_tempo (tempo);
        }

        public void set_measure_display (int measure) {
            home_screen.set_measure (measure);
        }

        public void set_chord_display (int chord_main, int chord_type) {
            home_screen.set_chord (chord_main, chord_type);
        }

        public void edit_channel (int synth_index, int channel) {
            main_display_leaflet.set_visible_child (main_stack);
            main_stack.set_visible_child (channel_mod_screen);
            channel_mod_screen.set_synth_channel_to_edit (synth_index, channel);
        }
    }
}
