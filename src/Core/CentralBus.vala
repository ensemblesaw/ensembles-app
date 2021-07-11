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


namespace Ensembles.Core {
    public class CentralBus : Object {
        bool thread_alive = true;

        // Bus access for shell
        int style_section = 0;
        int loaded_tempo = 10;


        // System Ready Messages
        int styles_loaded_ready = 0;

        // Voice Split Updates
        int split_key = 54;

        public CentralBus () {
            new Thread<int> ("bus_watch", bus_watch);
        }
        ~CentralBus () {
            thread_alive = false;
        }
        public signal void clock_tick ();
        public signal void system_halt ();
        public signal void style_section_change (int section);
        public signal void loaded_tempo_change (int tempo);
        public signal void split_key_change ();

        public void clk() {
            print ("clk\n");
        } 
        public signal void system_ready ();
        int bus_watch () {
            while (thread_alive) {
                if (loaded_tempo != central_loaded_tempo && central_loaded_tempo > 10) {
                    loaded_tempo_change (central_loaded_tempo);
                    loaded_tempo = central_loaded_tempo;
                }
                if (styles_loaded_ready != styles_ready) {
                    styles_loaded_ready = styles_ready;
                    if (styles_loaded_ready > 0) {
                        Idle.add (() => {
                            system_ready ();
                            return false;
                        });
                    }
                }
                if (central_halt == 1) {
                    central_halt = 0;
                    Idle.add (() => {
                        system_halt ();
                        return false;
                    });
                }
                if (split_key != central_split_key) {
                    split_key = central_split_key;
                    split_key_change ();
                }
                if (central_clock == 1) {
                    Idle.add (() => {
                        clock_tick ();
                        return false;
                    });
                    if (style_section != central_style_section) {
                        style_section_change (central_style_section);
                        style_section = central_style_section;
                    }
                    Thread.usleep (300000);
                    central_measure ++;
                    central_clock = 0;
                }
                Thread.usleep (400);
            }
            return 0;
        }

        public static void set_styles_ready (bool ready) {
            styles_ready = ready ? 1 : 0;
        }

        public static int get_measure () {
            return central_measure;
        }

        public static int get_split_key () {
            return central_split_key;
        }

        public static void set_split_key (int key) {
            central_split_key = key;
        }

        public static bool get_accomp_on () {
            return central_accompaniment_mode > 0;
        }

        public static bool get_split_on () {
            return central_split_on > 0;
        }

        public static void set_split_on (bool active) {
            central_split_on = active ? 1 : 0;
        }

        public static void set_layer_on (bool active) {
            central_layer_on = active ? 1 : 0;
        }

        public static bool get_metronome_on () {
            return central_metronome_on > 0 ? true : false;
        }

        public static void set_metronome_on (bool active) {
            central_metronome_on = active ? 1 : 0;
        }

        public static bool get_style_looping_on () {
            return central_style_looping > 0 ? true : false;
        }
    }
}

// System Ready Messages
extern int styles_ready;

// Midi Player Info
extern int central_clock;
extern int central_halt;
extern int central_measure;
extern int central_style_section;
extern int central_loaded_tempo;
extern int central_split_key;
extern int central_split_on;
extern int central_layer_on;

// Style
extern int central_accompaniment_mode;
extern int central_style_looping;

// Metronome and LFO
extern int central_metronome_on;