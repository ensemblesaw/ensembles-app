/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.Synthesizer {
    /** Type of synthesizer based on it's purpose */
    public enum SynthType {
        /** Whenever you are supposed to render audio */
        RENDER,
        /** For automations and analysis and doesn't require rendering */
        UTILITY
    }

    public class SynthManager : Object {
        private SynthInstanceProvider synth_instance_provider;
        private Analysers.ChordAnalyser chord_analyser;

        private unowned Fluid.Synth realtime_render_synth;

        private int soundfont_id;

        construct {
            synth_instance_provider = new SynthInstanceProvider ();
            chord_analyser = new Analysers.ChordAnalyser ();
        }

        public SynthManager (string soundfont, string driver_name, double buffer_size) {
            #if PIPEWIRE_CORE_DRIVER
            Pipewire.init(null, null);
            #endif
            synth_instance_provider.set_driver_configuration (driver_name, buffer_size);
            realtime_render_synth = synth_instance_provider.get_instance (SynthType.RENDER);

            if (Fluid.is_soundfont (soundfont)) {
                soundfont_id = realtime_render_synth.sfload (soundfont, true);

                // Initialize Voices
                realtime_render_synth.program_select (17, soundfont_id, 0, 0);
                realtime_render_synth.program_select (18, soundfont_id, 0, 49);
                realtime_render_synth.program_select (19, soundfont_id, 0, 33);

                // Initialize chord voices
                realtime_render_synth.program_select (20, soundfont_id, 0, 5);
                realtime_render_synth.program_select (21, soundfont_id, 0, 33);
                realtime_render_synth.program_select (22, soundfont_id, 0, 49);

                // Initialize metronome voice
                realtime_render_synth.program_select (16, soundfont_id, 128, 0);
            }

            set_synth_defaults ();
        }

        private void set_synth_defaults () {
            // CutOff for Realtime synth
            realtime_render_synth.cc (17, 74, 40);
            realtime_render_synth.cc (18, 74, 0);
            realtime_render_synth.cc (19, 74, 0);

            // Reverb and Chorus for R1 voice
            realtime_render_synth.cc (17, 91, 100);
            realtime_render_synth.cc (17, 93, 100);

            // Reverb and Chorus for Metronome
            realtime_render_synth.cc (16, 91, 0);
            realtime_render_synth.cc (16, 93, 0);

            // Default gain for Realtime synth
            realtime_render_synth.cc (17, 7, 100);
            realtime_render_synth.cc (18, 7, 90);
            realtime_render_synth.cc (19, 7, 80);


            // Default pitch of all synths
            for (int i = 17; i < 64; i++) {
                realtime_render_synth.cc (i, 3, 64);
            }

            // Default cut-off and resonance for recorder
            for (int i = 24; i < 64; i++) {
                realtime_render_synth.cc (i, 74, 40);
                realtime_render_synth.cc (i, 71, 10);
            }

            // Default pitch for styles
            for (int i = 0; i < 16; i++) {
                realtime_render_synth.cc (i, 3, 64);
            }
        }

        private void edit_master_reverb (int level) {
            if (realtime_render_synth != null) {
                realtime_render_synth.set_reverb_group_roomsize (-1, SynthSettingsProvider.reverb_room_size[level]);
                realtime_render_synth.set_reverb_group_damp (-1, 0.1);
                realtime_render_synth.set_reverb_group_width (-1, SynthSettingsProvider.reverb_width[level]);
                realtime_render_synth.set_reverb_group_level (-1, SynthSettingsProvider.reverb_level[level]);
            }
        }

        private void set_master_reverb_active (bool active) {
            if (realtime_render_synth != null) {
                realtime_render_synth.reverb_on (-1, active);
            }
        }

        private void edit_master_chorus (int level) {
            if (realtime_render_synth != null) {
                realtime_render_synth.set_chorus_group_depth (-1, SynthSettingsProvider.chorus_depth[level]);
                realtime_render_synth.set_chorus_group_level (-1, SynthSettingsProvider.chorus_level[level]);
                realtime_render_synth.set_chorus_group_nr (-1, SynthSettingsProvider.chorus_nr[level]);
            }
        }

        private void set_master_chorus_active (bool active) {
            if (realtime_render_synth != null) {
                realtime_render_synth.chorus_on (-1, active);
            }
        }
    }
}
