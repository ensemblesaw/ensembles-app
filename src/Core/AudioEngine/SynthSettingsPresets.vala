/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

 namespace Ensembles.Core.AudioEngine.SynthSettingsPresets {
    /** Reverb presets
        */
    public class ReverbPresets {
        public const double[] ROOM_SIZE = { 0.0, 0.1, 0.2, 0.3, 0.4, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9};
        public const double[] WIDTH = { 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20 };
        public const double[] LEVEL = { 0, 0.05, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 };
    }

    /** Chorus presets
        */
    public class ChorusPresets {
        public const double[] DEPTH = {0, 4, 4, 4, 6, 10, 20, 25, 30, 35, 40 };
        public const uint8[] NR = { 0, 2, 3, 3, 4, 5, 6, 8, 10, 16, 20 };
        public const double[] LEVEL = { 0, 0.1, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2 };
    }

    public class ModulatorSettings : Object {
        private int16[] pan_value;
        private int16[] reverb_value;
        private int16[] chorus_value;
        private int16[] pitch_value;
        private int16[] expression_value;
        private int16[] modulation_value;
        private int16[] cut_off_value;
        private int16[] resonance_value;

        construct {
            pan_value = new int16 [16];
            for (uint8 i = 0; i < 16; i++) {
                pan_value[i] = -65;
            }

            reverb_value = new int16 [16];
            for (uint8 i = 0; i < 16; i++) {
                reverb_value[i] = -1;
            }

            chorus_value = new int16 [16];
            for (uint8 i = 0; i < 16; i++) {
                chorus_value[i] = -1;
            }

            pitch_value = new int16 [16];
            for (uint8 i = 0; i < 16; i++) {
                pitch_value[i] = -65;
            }

            expression_value = new int16 [16];
            for (uint8 i = 0; i < 16; i++) {
                expression_value[i] = -1;
            }

            modulation_value = new int16 [16];
            for (uint8 i = 0; i < 16; i++) {
                modulation_value[i] = -1;
            }

            cut_off_value = new int16 [16];
            for (uint8 i = 0; i < 16; i++) {
                cut_off_value[i] = -1;
            }

            resonance_value = new int16 [16];
            for (uint8 i = 0; i < 16; i++) {
                resonance_value[i] = -1;
            }
        }

        /** Gets the modulator value of style channel by modulator number
            */
        public int16 get_mod_buffer_value (uint8 modulator, uint8 channel) {
            switch (modulator) {
                case 1:
                return modulation_value[channel];
                case 10:
                return pan_value[channel];
                case 11:
                return expression_value[channel];
                case 66:
                return pitch_value[channel];
                case 71:
                return resonance_value[channel];
                case 74:
                return cut_off_value[channel];
                case 91:
                return reverb_value[channel];
                case 93:
                return chorus_value[channel];
            }
            return -1;
        }

        /** Sets the modulator value of style channel by modulator number
        */
        public void set_mod_buffer_value (uint8 modulator, uint8 channel, int16 value) {
            switch (modulator) {
                case 1:
                modulation_value[channel] = value;
                break;
                case 10:
                pan_value[channel] = value;
                break;
                case 11:
                expression_value[channel] = value;
                break;
                case 66:
                pitch_value[channel] = value;
                break;
                case 71:
                resonance_value[channel] = value;
                break;
                case 74:
                cut_off_value[channel] = value;
                break;
                case 91:
                reverb_value[channel] = value;
                break;
                case 93:
                chorus_value[channel] = value;
                break;
            }
        }
    }

    public class StyleGainSettings : Object {
        /** Style gain values */
        public int16[] gain;
        construct {
            gain = new int16[16];
            for (uint i = 0; i < 16; i++) {
                gain[i] = -1;
            }
        }
    }
}
