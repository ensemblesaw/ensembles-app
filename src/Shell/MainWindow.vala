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
        MainDisplayCasing main_display_unit;
        Ensembles.Core.Synthesizer synthesizer;
        Ensembles.Core.StyleDiscovery style_discovery;
        Ensembles.Core.StylePlayer style_player;
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

            main_display_unit = new MainDisplayCasing ();

            style_controller_view = new StyleControllerView ();

            var grid = new Gtk.Grid ();
            grid.attach (main_display_unit, 0, 0, 1, 1);
            grid.attach (style_controller_view, 0, 1, 1, 1);
            this.add (grid);
            this.show_all ();
            





            synthesizer = new Ensembles.Core.Synthesizer (sf_loc);
            style_player = new Ensembles.Core.StylePlayer ();

            style_discovery = new Ensembles.Core.StyleDiscovery ();
            style_discovery.analysis_complete.connect (() => {
                style_player.add_style_file (style_discovery.style_files.nth_data (0));
                main_display_unit.update_style_list (
                    style_discovery.style_files,
                    style_discovery.style_names,
                    style_discovery.style_genre,
                    style_discovery.style_tempo
                );
            });

            make_ui_events ();
        }
        void make_bus_events () {
            bus.clock_tick.connect (() => {
                beat_counter_panel.sync ();
                main_display_unit.set_measure_display (Ensembles.Core.CentralBus.get_measure ());
            });
            bus.system_ready.connect (() => {
                main_display_unit.queue_remove_splash ();
            });
            bus.style_section_change.connect ((section) => {
                style_controller_view.set_style_section (section);
            });
            bus.loaded_tempo_change.connect ((tempo) => {
                beat_counter_panel.change_tempo (tempo);
                main_display_unit.set_tempo_display (tempo);
            });
        }
        void make_ui_events () {
            style_controller_view.start_stop.connect (() => {
                style_player.play_style ();
            });

            style_controller_view.switch_var_a.connect (() => {
                style_player.switch_var_a ();
            });

            style_controller_view.switch_var_b.connect (() => {
                style_player.switch_var_b ();
            });

            style_controller_view.switch_var_c.connect (() => {
                style_player.switch_var_c ();
            });

            style_controller_view.switch_var_d.connect (() => {
                style_player.switch_var_d ();
            });

            style_controller_view.queue_intro_a.connect (() => {
                style_player.queue_intro_a ();
            });

            style_controller_view.queue_intro_b.connect (() => {
                style_player.queue_intro_b ();
            });

            style_controller_view.queue_ending_a.connect (() => {
                style_player.queue_ending_a ();
            });

            style_controller_view.queue_ending_b.connect (() => {
                style_player.queue_ending_b ();
            });

            style_controller_view.break_play.connect (() => {
                style_player.break_play ();
            });

            style_controller_view.sync_stop.connect (() => {
                style_player.sync_stop ();
            });
            print("Initialized...\n");
        }
    }
}