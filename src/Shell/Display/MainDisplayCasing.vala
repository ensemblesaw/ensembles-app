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
        TempoScreen tempo_screen;
        public StyleMenu style_menu;
        VoiceMenu voice_menu_l;
        VoiceMenu voice_menu_r1;
        VoiceMenu voice_menu_r2;
        EffectRackScreen fx_rack_menu;
        RecorderScreen recorder_screen;

        LFOEditScreen lfo_editor;

        public ChannelModulatorScreen channel_mod_screen;

        public signal void change_style (Ensembles.Core.Style accomp_style);
        public signal void change_voice (Ensembles.Core.Voice voice, int channel);
        public signal void change_tempo (int tempo);

        public MainDisplayCasing () {
            home_screen = new HomeScreen ();
            tempo_screen = new TempoScreen ();
            style_menu = new StyleMenu ();
            voice_menu_l = new VoiceMenu (2);
            voice_menu_r1 = new VoiceMenu (0);
            voice_menu_r2 = new VoiceMenu (1);
            fx_rack_menu = new EffectRackScreen ();
            channel_mod_screen = new ChannelModulatorScreen (0, 0);
            lfo_editor = new LFOEditScreen ();
            recorder_screen = new RecorderScreen ();

            main_stack = new Gtk.Stack ();
            main_stack.add_named (tempo_screen, "Tempo Screen");
            main_stack.add_named (style_menu, "Styles Menu");
            main_stack.add_named (voice_menu_l, "Voice L Menu");
            main_stack.add_named (voice_menu_r1, "Voice R1 Menu");
            main_stack.add_named (voice_menu_r2, "Voice R2 Menu");
            main_stack.add_named (channel_mod_screen, "Channel Modulator Screen");
            main_stack.add_named (lfo_editor, "LFO Editor");
            main_stack.add_named (fx_rack_menu, "Fx Rack");
            main_stack.add_named (recorder_screen, "Sequencer");

            splash_screen = new Gtk.Image.from_resource ("/com/github/subhadeepjasu/ensembles/images/display_unit/ensembles_splash.svg");

            main_display_leaflet = new Hdy.Leaflet ();
            main_display_leaflet.set_mode_transition_duration (400);
            main_display_leaflet.add (home_screen);
            main_display_leaflet.add (main_stack);
            main_display_leaflet.set_can_swipe_back (true);
            main_display_leaflet.set_transition_type (Hdy.LeafletTransitionType.SLIDE);

            main_display_deck = new Hdy.Deck ();
            main_display_deck.add (main_display_leaflet);

            main_overlay = new Gtk.Overlay ();
            main_overlay.height_request = 236;
            main_overlay.width_request = 460;
            main_overlay.margin = 2;

            // This helps maintain fixed size for all children
            var fixed_size_container = new Gtk.Overlay ();
            fixed_size_container.add_overlay (main_display_deck);

            main_overlay.add (fixed_size_container);
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
            Timeout.add (2000, () => {
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
            home_screen.open_fx_menu .connect (() => {
                main_display_leaflet.set_visible_child (main_stack);
                main_stack.set_visible_child (fx_rack_menu);
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
            style_menu.change_style.connect ((accomp_style) => {
                home_screen.set_style_name (accomp_style.name);
                this.change_style (accomp_style);
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
            lfo_editor.close_screen.connect (() => {
                main_display_leaflet.set_visible_child (home_screen);
            });
            tempo_screen.close_screen.connect (() => {
                main_display_leaflet.set_visible_child (home_screen);
            });
            tempo_screen.changed.connect ((tempo) => {
                change_tempo (tempo);
            });
            fx_rack_menu.close_menu.connect (() => {
                main_display_leaflet.set_visible_child (home_screen);
            });
            recorder_screen.close_menu.connect (() => {
                main_display_leaflet.set_visible_child (home_screen);
            });
        }

        public void update_style_list (List<Ensembles.Core.Style> accomp_styles) {
            Ensembles.Core.Style[] styles = new Ensembles.Core.Style[accomp_styles.length ()];
            for (int i = 0; i < accomp_styles.length (); i++) {
                styles[i] = accomp_styles.nth_data (i);
            }
            style_menu.populate_style_menu (styles);
            style_menu.load_settings ();
        }

        public void update_effect_list () {
            fx_rack_menu.populate_effect_menu ();
            Idle.add (() => {
                voice_menu_r1.populate_plugins ();
                return false;
            });
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
            tempo_screen.set_tempo (tempo);
        }

        public void set_tempo (int tempo) {
            tempo_screen.set_tempo (tempo);
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

        public void open_lfo_screen () {
            main_display_leaflet.set_visible_child (main_stack);
            main_stack.set_visible_child (lfo_editor);
        }

        public void open_tempo_screen () {
            main_display_leaflet.set_visible_child (main_stack);
            main_stack.set_visible_child (tempo_screen);
        }

        public void open_recorder_screen () {
            main_display_leaflet.set_visible_child (main_stack);
            main_stack.set_visible_child (recorder_screen);
        }

        public void load_settings (int tempo) {
            voice_menu_r1.load_settings ();
            voice_menu_r2.load_settings ();
            voice_menu_l.load_settings ();
            style_menu.load_settings (tempo);
        }

        public void wheel_scroll (bool direction, int amount) {
            if (main_display_leaflet.get_visible_child () == main_stack) {
                switch (main_stack.get_visible_child_name ()) {
                    case "Tempo Screen":
                    tempo_screen.scroll_wheel_scroll (direction, amount);
                    break;
                    case "Voice R1 Menu":
                    voice_menu_r1.scroll_wheel_scroll (direction, amount);
                    break;
                    case "Voice R2 Menu":
                    voice_menu_r2.scroll_wheel_scroll (direction, amount);
                    break;
                    case "Voice L Menu":
                    voice_menu_l.scroll_wheel_scroll (direction, amount);
                    break;
                    case "Styles Menu":
                    style_menu.scroll_wheel_scroll (direction, amount);
                    break;
                }
            }
        }
        public void wheel_activate () {
            if (main_display_leaflet.get_visible_child () == main_stack) {
                switch (main_stack.get_visible_child_name ()) {
                    case "Tempo Screen":
                    tempo_screen.scroll_wheel_activate ();
                    break;
                    case "Voice R1 Menu":
                    voice_menu_r1.scroll_wheel_activate ();
                    break;
                    case "Voice R2 Menu":
                    voice_menu_r2.scroll_wheel_activate ();
                    break;
                    case "Voice L Menu":
                    voice_menu_l.scroll_wheel_activate ();
                    break;
                    case "Styles Menu":
                    style_menu.scroll_wheel_activate ();
                    break;
                }
            }
        }
    }
}
