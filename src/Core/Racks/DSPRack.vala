/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Core.Plugins.AudioPlugins;

namespace Ensembles.Core.Racks {
    /**
     * This defines a rack which gets populated with DSP plugins.
     * The final output of the synthesizer / voice plugin is processed by all
     * the plugins in this rack.
     *
     * DSP - Digital Signal Processing
     */
    public class DSPRack : Rack {
        public DSPRack () {
            Object (
                rack_type: AudioPlugin.Category.DSP
            );
        }
    }
}
