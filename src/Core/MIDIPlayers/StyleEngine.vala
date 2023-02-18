namespace Ensembles.Core.MIDIPlayers {
    public class StyleEngine : Object {
        private Fluid.Player style_player;

        private unowned Fluid.Synth utility_synth;

        private int loop_start_tick;

        private static bool looping = false;

        public StyleEngine (Synthesizer.SynthProvider synth_provider, Models.Style style, uint8? tempo) {
            utility_synth = synth_provider.utility_synth;
            //  int custom_tempo = looping ? style_player
        }
    }
}
