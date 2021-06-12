namespace Ensembles.Core {
    public class CentralBus : Object {
        bool thread_alive = true;

        // Bus access for shell
        int style_section = 0;
        int loaded_tempo = 10;

        public CentralBus () {
            new Thread<int> ("bus_watch", bus_watch);
        }
        ~CentralBus () {
            thread_alive = false;
        }
        public signal void clock_tick ();
        public signal void style_section_change (int section);
        public signal void loaded_tempo_change (int tempo);
        int bus_watch () {
            while (thread_alive) {
                if (central_clock == 1) {
                    clock_tick ();
                    central_clock = 0;
                    Thread.usleep (100);
                }
                if (style_section != central_style_section) {
                    style_section_change (central_style_section);
                    style_section = central_style_section;
                }
                if (loaded_tempo != central_loaded_tempo && central_loaded_tempo > 10) {
                    loaded_tempo_change (central_loaded_tempo);
                    loaded_tempo = central_loaded_tempo;
                }
                Thread.usleep (50);
            }
            return 0;
        }
    }
}

extern int central_clock;
extern int central_style_section;
extern int central_loaded_tempo;