namespace Ensembles.Core { 
    public class Synthesizer : Object {
        public Synthesizer (string soundfont) {
            synthesizer_init (soundfont);
        }

        ~Synthesizer () {
            synthesizer_destruct ();
        }

        public void send_notes_realtime (int key, int on, int velocity) {
            synthesizer_send_notes (key, on, velocity);
        }
    }
}

extern void synthesizer_init (string loc);
extern void synthesizer_destruct ();
extern void synthesizer_send_notes (int key, int on, int velocity);