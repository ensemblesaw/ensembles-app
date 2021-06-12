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
 * Authored by: Subhadeep Jasu
 */
namespace Ensembles.Shell { 
    public class MainWindow : Gtk.Window {
        StyleControllerView style_controller_view;
        BeatCounterView beat_counter_panel;
        Ensembles.Core.Synthesizer synthesizer;
        Ensembles.Core.StylePlayer player;
        Ensembles.Core.StyleAnalyser analyser;
        Ensembles.Core.CentralBus bus;

        string sf_loc = Constants.PKGDATADIR + "/SoundFonts/EnsemblesGM.sf2";
        public MainWindow () {
            Gtk.Settings settings = Gtk.Settings.get_default ();
            settings.gtk_application_prefer_dark_theme = true;
            bus = new Ensembles.Core.CentralBus ();
            make_bus_events ();

            beat_counter_panel = new BeatCounterView ();
            var headerbar = new Gtk.HeaderBar ();
            headerbar.has_subtitle = false;
            headerbar.set_show_close_button (true);
            headerbar.title = "Ensembles";
            headerbar.pack_start (beat_counter_panel);
            this.set_titlebar (headerbar);

            style_controller_view = new StyleControllerView ();

            var grid = new Gtk.Grid ();
            grid.attach (style_controller_view, 0, 0, 1, 1);
            this.add (grid);
            this.show_all ();
            
            analyser = new Ensembles.Core.StyleAnalyser ();

            analyser.analyze_style(Constants.PKGDATADIR + "/Styles/DancePop_01.mid");

            synthesizer = new Ensembles.Core.Synthesizer (sf_loc);
            player = new Ensembles.Core.StylePlayer (Constants.PKGDATADIR + "/Styles/DancePop_01.mid");

            make_ui_events ();
        }
        void make_bus_events () {
            bus.clock_tick.connect (() => {
                beat_counter_panel.sync ();
            });
            bus.style_section_change.connect ((section) => {
                style_controller_view.set_style_section (section);
            });
            bus.loaded_tempo_change.connect ((tempo) => {
                beat_counter_panel.change_tempo (tempo);
                print("tempo:%d\n", tempo);
            });
        }
        void make_ui_events () {
            style_controller_view.start_stop.connect (() => {
                player.play_style ();
            });

            style_controller_view.switch_var_a.connect (() => {
                player.switch_var_a ();
            });

            style_controller_view.switch_var_b.connect (() => {
                player.switch_var_b ();
            });

            style_controller_view.switch_var_c.connect (() => {
                player.switch_var_c ();
            });

            style_controller_view.switch_var_d.connect (() => {
                player.switch_var_d ();
            });

            style_controller_view.queue_intro_a.connect (() => {
                player.queue_intro_a ();
            });

            style_controller_view.queue_intro_b.connect (() => {
                player.queue_intro_b ();
            });

            style_controller_view.queue_ending_a.connect (() => {
                player.queue_ending_a ();
            });

            style_controller_view.queue_ending_b.connect (() => {
                player.queue_ending_b ();
            });

            style_controller_view.break_play.connect (() => {
                player.break_play ();
            });

            style_controller_view.sync_stop.connect (() => {
                player.sync_stop ();
            });
            print("Initialized...\n");
        }
    }
}