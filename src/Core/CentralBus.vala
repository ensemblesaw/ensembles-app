namespace Ensembles.Core {
    public class CentralBus : Object {
        bool thread_alive = true;

        // Bus access for shell
        int style_section = 0;
        int loaded_tempo = 10;
        int measure = 0;


        // System Ready Messages
        int styles_loaded_ready = 0;

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
                        system_ready ();
                    }
                }
                if (central_halt == 1) {
                    central_halt = 0;
                    system_halt ();
                }
                if (central_clock == 1) {
                    clock_tick ();
                    if (style_section != central_style_section) {
                        style_section_change (central_style_section);
                        style_section = central_style_section;
                    }
                    Thread.usleep (400000);
                    central_measure ++;
                    central_clock = 0;
                }
            }
            return 0;
        }

        public static void set_styles_ready (bool ready) {
            styles_ready = ready ? 1 : 0;
        }

        public static int get_measure () {
            return central_measure;
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