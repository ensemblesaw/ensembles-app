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
            yield;
        }
        ~CentralBus () {
            thread_alive = false;
        }
        public signal void clock_tick ();
        public signal void system_halt ();
        public signal void style_section_change (int section);
        public signal void loaded_tempo_change (int tempo);


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
                yield;
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