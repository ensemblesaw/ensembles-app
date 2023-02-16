/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core {
    public class ArrangerWorkstation : Object {
        private Synthesizer.SynthManager synth_manager;

        // Path constants
        /*
         * sf stands for SoundFont (Registered Trademark of Emu Systems)
         * sf_loc is location of the actual soundfont file which is also like the sound database
         * sf_schema_loc is the location for the csv file that specifies the categorization of the sounds
        */
        public string sf_path = Constants.SF2DATADIR + "/EnsemblesGM.sf2";

        construct {
            print (sf_path);
            synth_manager = new Synthesizer.SynthManager (sf_path, "alsa", 0.1);
        }

        public void sound_test () {
            GLib.Timeout.add (1000, () => {
                print ("playing\n");
                synth_manager.send_notes_realtime (17, 72, 127, true);
                synth_manager.send_notes_realtime (17, 72, 127, false);
                return true;
            });
        }


    }
}
