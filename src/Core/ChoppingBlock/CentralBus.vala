/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


namespace Ensembles.Core {
    public class CentralBus : Object {
        bool thread_alive = true;

        // Bus access for shell
        int style_section = 0;
        public static int loaded_tempo = 10;
        int loaded_time_sig_n = 4;
        int loaded_time_sig_d = 4;

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
        public signal void loaded_tempo_change (int tempo);
        public signal void loaded_time_signature_change (int n, int d);
        public signal void split_key_change ();

        public void clk () {
            debug ("clk\n");
        }
        int bus_watch () {
            while (thread_alive) {
                if (loaded_tempo != central_loaded_tempo && central_loaded_tempo > 10) {
                    loaded_tempo_change (central_loaded_tempo);
                    loaded_tempo = central_loaded_tempo;
                }
                if (loaded_time_sig_n != central_beats_per_bar || loaded_time_sig_d != central_quarter_notes_per_bar) {
                    loaded_time_signature_change (central_beats_per_bar, central_quarter_notes_per_bar);
                    loaded_time_sig_n = central_beats_per_bar;
                    loaded_time_sig_d = central_quarter_notes_per_bar;
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
                    Thread.yield ();
                    Thread.usleep (300000);
                    central_measure ++;
                    central_clock = 0;
                }
                Thread.yield ();
                Thread.usleep (400);
            }
            return 0;
        }

        public static int get_measure () {
            return central_measure;
        }

        public static int get_tempo () {
            return central_loaded_tempo;
        }

        public static int get_beats_per_bar () {
            return central_beats_per_bar;
        }

        public static int get_quarter_notes_per_bar () {
            return central_quarter_notes_per_bar;
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

        public static int get_lfo_type () {
            return central_lfo_on;
        }

        public static void set_lfo_type (int type) {
            central_lfo_on = type;
        }

        public static bool get_style_looping_on () {
            return central_style_looping > 0 ? true : false;
        }

        public static float get_lfo () {
            return ((float)central_lfo_value / 127.0f);
        }
    }
}

// Style Engine
extern int central_clock;
extern int central_halt;
extern int central_measure;
extern int central_style_section;
extern int central_loaded_tempo;
extern int central_beats_per_bar;
extern int central_quarter_notes_per_bar;
extern int central_split_key;
extern int central_split_on;
extern int central_layer_on;
extern int central_accompaniment_mode;
extern int central_style_looping;

// Metronome and LFO
extern int central_metronome_on;
extern int central_lfo_on;
extern int central_lfo_value;
