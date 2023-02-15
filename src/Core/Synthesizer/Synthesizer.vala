/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.Synthesizer {
    public enum SynthType {
        RENDER,
        UTILITY
    }

    public class Synthesizer : Object {
        private SynthInstanceProvider synth_provider;
        construct {
            synth_provider = new SynthInstanceProvider ();
        }
    }
}
