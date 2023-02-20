/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core {
    public class ArrangerWorkstation : Object {
        private Synthesizer.SynthProvider synth_provider;
        private Synthesizer.Synthesizer synthesizer;

         // Arranger Data
        private Models.Style[] styles;

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
            } catch (FluidError e) {
                Console.log (e.message, Console.LogLevel.ERROR);
            }
        }

        public ArrangerWorkstation () {
            new Thread<void> ("ensembles-data-discovery", load_data);
        }

        public void load_data () {
            Thread.usleep (500000);
            // Load Styles
            Console.log ("Searching for styles…");
            var style_loader = new FileLoaders.StyleFileLoader ();
            uint n_styles = 0;
            styles = style_loader.get_styles (out n_styles);
            foreach (var style in styles) {
                Console.log (style.to_string ());
            }
            Console.log ("Found %u styles".printf (n_styles), Console.LogLevel.SUCCESS);

            // Send ready signal
            Idle.add (() => {
                Ensembles.Application.event_bus.arranger_ready ();
                return false;
            });
        }
    }
}
