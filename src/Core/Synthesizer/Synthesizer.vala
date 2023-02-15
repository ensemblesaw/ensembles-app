/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.Synthesizer {
    public class Synthesizer : Object {
        private Fluid.Settings rendering_settings;
        private Fluid.Synth rendering_synth;

        construct {
            rendering_settings = new Fluid.Settings ();
            rendering_synth = new Fluid.Synth (rendering_settings);
        }
    }
}
