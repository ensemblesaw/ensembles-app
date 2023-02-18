/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

 namespace Ensembles.Core.Synthesizer {
    /**
     * Provides Synth settings, presets and variables
     */
    public class SynthSettingsPresets {
        /** Reverb presets
         */
        public class ReverbPresets {
            public const double[] ROOM_SIZE = { 0.0, 0.1, 0.2, 0.3, 0.4, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9};
            public const double[] WIDTH     = { 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20 };
            public const double[] LEVEL     = { 0, 0.05, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 };
        }

        /** Chorus presets
         */
        public class ChorusPresets {
            public const double[] DEPTH = {0, 4, 4, 4, 6, 10, 20, 25, 30, 35, 40 };
            public const uint8[] NR = { 0, 2, 3, 3, 4, 5, 6, 8, 10, 16, 20 };
            public const double[] LEVEL = { 0, 0.1, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2 };
        }

        public class ModulatorValues {
            private static int16[] pan_value = { -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65 };
            private static int16[] reverb_value = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };
            private static int16[] chorus_value = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };
            private static int16[] pitch_value = { -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65 };
            private static int16[] expression_value = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };
            private static int16[] modulation_value = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };
            private static int16[] cut_off_value = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };
            private static int16[] resonance_value = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };

            /** Gets the modulator value of style channel by modulator number
             */
            public static int16 get_mod_buffer_value (uint8 modulator, uint8 channel) {
                switch (modulator)
                {
                    case 1:
                    return ModulatorValues.modulation_value[channel];
                    case 10:
                    return ModulatorValues.pan_value[channel];
                    case 11:
                    return ModulatorValues.expression_value[channel];
                    case 66:
                    return ModulatorValues.pitch_value[channel];
                    case 71:
                    return ModulatorValues.resonance_value[channel];
                    case 74:
                    return ModulatorValues.cut_off_value[channel];
                    case 91:
                    return ModulatorValues.reverb_value[channel];
                    case 93:
                    return ModulatorValues.chorus_value[channel];
                }
                return -1;
            }

            /** Sets the modulator value of style channel by modulator number
            */
            public static void set_mod_buffer_value (uint8 modulator, uint8 channel, int16 value) {
                switch (modulator)
                {
                    case 1:
                    ModulatorValues.modulation_value[channel] = value;
                    break;
                    case 10:
                    ModulatorValues.pan_value[channel] = value;
                    break;
                    case 11:
                    ModulatorValues.expression_value[channel] = value;
                    break;
                    case 66:
                    ModulatorValues.pitch_value[channel] = value;
                    break;
                    case 71:
                    ModulatorValues.resonance_value[channel] = value;
                    break;
                    case 74:
                    ModulatorValues.cut_off_value[channel] = value;
                    break;
                    case 91:
                    ModulatorValues.reverb_value[channel] = value;
                    break;
                    case 93:
                    ModulatorValues.chorus_value[channel] = value;
                    break;
                }
            }
        }

        /** Style gain values */
        public static int16[] gain_value = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };

        /** Get Gain value of style channel
         */
        public static int16 get_gain_value (uint8 channel) {
            return gain_value[channel];
        }

        /** Set Gain value of style channel
         */
         public static void set_gain_value (uint8 channel, uint8 value) {
            gain_value[channel] = value;
        }
    }
 }
