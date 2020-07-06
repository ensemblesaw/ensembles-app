namespace Ensembles.Core { 
    public class EffectRack {
        public int print_hello (int x) {
            return effect_rack_print_hello (x);
        }
    }
}

// C Bindings
extern int effect_rack_print_hello (int a);