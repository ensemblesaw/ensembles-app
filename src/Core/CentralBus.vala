namespace Ensembles.Core {
    public class CentralBus : Object {
        bool thread_alive = true;
        int style_section = 0;

        public CentralBus () {
            new Thread<int> ("bus_watch", bus_watch);
        }
        ~CentralBus () {
            thread_alive = false;
        }
        public signal void clock_tick ();
        public signal void style_section_change (int section);
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
                Thread.usleep (50);
            }
            return 0;
        }
    }
}

extern int central_clock;
extern int central_style_section;