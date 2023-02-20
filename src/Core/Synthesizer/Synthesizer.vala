/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.Synthesizer {
    public class Synthesizer : Object {
        private bool input_enabled = true;

        private Analysers.ChordAnalyser chord_analyser;
        private unowned Fluid.Synth rendering_synth;

        private int soundfont_id;

        construct {
            chord_analyser = new Analysers.ChordAnalyser ();
        }

        public Synthesizer (SynthProvider synth_provider, string soundfont) throws FluidError {
            rendering_synth = synth_provider.rendering_synth;

            if (Fluid.is_soundfont (soundfont)) {
                soundfont_id = synth_provider.rendering_synth.sfload (soundfont, true);

                // Initialize Voices
                rendering_synth.program_select (17, soundfont_id, 0, 0);
                rendering_synth.program_select (18, soundfont_id, 0, 49);
                rendering_synth.program_select (19, soundfont_id, 0, 33);

                // Initialize chord voices
                rendering_synth.program_select (20, soundfont_id, 0, 5);
                rendering_synth.program_select (21, soundfont_id, 0, 33);
                rendering_synth.program_select (22, soundfont_id, 0, 49);

                // Initialize metronome voice
                rendering_synth.program_select (16, soundfont_id, 128, 0);
            } else {
                throw new FluidError.INVALID_SF (_("SoundFont from path: %s is either missing or invalid"), soundfont);
            }

            set_synth_defaults ();
        }

        private void set_synth_defaults () {
            // CutOff for Realtime synth
            rendering_synth.cc (17, 74, 40);
            rendering_synth.cc (18, 74, 0);
            rendering_synth.cc (19, 74, 0);

            // Reverb and Chorus for R1 voice
            rendering_synth.cc (17, 91, 100);
            rendering_synth.cc (17, 93, 100);

            // Reverb and Chorus for Metronome
            rendering_synth.cc (16, 91, 0);
            rendering_synth.cc (16, 93, 0);

            // Default gain for Realtime synth
            rendering_synth.cc (17, 7, 100);
            rendering_synth.cc (18, 7, 90);
            rendering_synth.cc (19, 7, 80);


            // Default pitch of all synths
            for (int i = 17; i < 64; i++) {
                rendering_synth.cc (i, 3, 64);
            }

            // Default cut-off and resonance for recorder
            for (int i = 24; i < 64; i++) {
                rendering_synth.cc (i, 74, 40);
                rendering_synth.cc (i, 71, 10);
            }

            // Default pitch for styles
            for (int i = 0; i < 16; i++) {
                rendering_synth.cc (i, 3, 64);
            }
        }

        private void edit_master_reverb (int level) {
            if (rendering_synth != null) {
                rendering_synth.set_reverb_group_roomsize (-1, SynthSettingsPresets.ReverbPresets.ROOM_SIZE[level]);
                rendering_synth.set_reverb_group_damp (-1, 0.1);
                rendering_synth.set_reverb_group_width (-1, SynthSettingsPresets.ReverbPresets.WIDTH[level]);
                rendering_synth.set_reverb_group_level (-1, SynthSettingsPresets.ReverbPresets.LEVEL[level]);
            }
        }

        private void set_master_reverb_active (bool active) {
            if (rendering_synth != null) {
                rendering_synth.reverb_on (-1, active);
            }
        }

        private void edit_master_chorus (int level) {
            if (rendering_synth != null) {
                rendering_synth.set_chorus_group_depth (-1, SynthSettingsPresets.ChorusPresets.DEPTH[level]);
                rendering_synth.set_chorus_group_level (-1, SynthSettingsPresets.ChorusPresets.LEVEL[level]);
                rendering_synth.set_chorus_group_nr (-1, SynthSettingsPresets.ChorusPresets.NR[level]);
            }
        }

        private void set_master_chorus_active (bool active) {
            if (rendering_synth != null) {
                rendering_synth.chorus_on (-1, active);
            }
        }

        public void send_notes_realtime (int channel, int key, int velocity, bool on) {
            if (on) {
                rendering_synth.noteon (channel, key, velocity);
            } else {
                rendering_synth.noteoff (channel, key);
            }
        }
    }
}
