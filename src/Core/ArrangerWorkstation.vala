/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core {
    public class ArrangerWorkstation : Object {
        private Synthesizer.SynthProvider synth_provider;
        private Synthesizer.Synthesizer synthesizer;
        private MIDIPlayers.StyleEngine style_engine;

        // Path constants
        /*
         * sf stands for SoundFont (Registered Trademark of Emu Systems)
         * sf_loc is location of the actual soundfont file which is also like the sound database
         * sf_schema_loc is the location for the csv file that specifies the categorization of the sounds
        */
        private const string SF_PATH = Constants.SF2DATADIR + "/EnsemblesGM.sf2";

        construct {
            #if PIPEWIRE_CORE_DRIVER
            Pipewire.init(null, null);
            #endif
            synth_provider = new Synthesizer.SynthProvider ();
            synth_provider.init_driver ("alsa", 0.2);
            Console.log ("Loading Soundfont from %s".printf (SF_PATH));
            try {
                synthesizer = new Synthesizer.Synthesizer (synth_provider, SF_PATH);
            } catch (FluidException e) {
                Console.log (e.message, Console.LogLevel.ERROR);
            }
        }

        public ArrangerWorkstation () {
            var style = (new Analysers.StyleAnalyser
                ("/home/subhadeep/Documents/ensembles/styles/EDM@Dance_Pop.enstl")
            ).get_style ();

            Console.log (style.to_string ());
        }
    }
}
