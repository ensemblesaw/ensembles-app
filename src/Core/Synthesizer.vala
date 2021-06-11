namespace Ensembles.Core { 
    public class Synthesizer : Object {
        public Synthesizer (string soundfont) {
            synthesizer_init (soundfont);
        }

        ~Synthesizer () {
            synthesizer_destruct ();
        }
    }
}

extern void synthesizer_init (string loc);
extern void synthesizer_destruct ();