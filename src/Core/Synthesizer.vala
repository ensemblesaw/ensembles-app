namespace Ensembles.Core { 
    public class Synthesizer : Object {
        public Synthesizer (string soundfont) {
            synthesizer_init (soundfont);
        }

        ~Synthesizer () {
            synthesizer_destruct ();
        }

        public signal void detected_chord (int chord_main);

        public void send_notes_realtime (int key, int on, int velocity) {
            int chord_feedback = synthesizer_send_notes (key, on, velocity);
            detected_chord (chord_feedback);
        }

        public void set_accompaniment_on (bool active) {
            synthesizer_set_accomp_enable (active ? 1 : 0);
            if (!active) synthesizer_halt_notes ();
        }
    }
}

extern void synthesizer_init (string loc);
extern void synthesizer_destruct ();
extern int synthesizer_send_notes (int key, int on, int velocity);
extern void synthesizer_halt_notes ();

extern void synthesizer_set_accomp_enable (int on);