/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Core.Plugins.AudioPlugins;

namespace Ensembles.Core.Racks {
    /**
     * ## DSP Rack
     *
     * This defines a rack which gets populated with DSP plugins.
     * The final output of the synthesizer / voice plugin is processed by all
     * the plugins in this rack.
     *
     * _**Note:** DSP - Digital Signal Processing_
     */
    public class DSPRack : Rack {
        public DSPRack () {
            Object (
                rack_type: AudioPlugin.Category.DSP
            );
        }
    }
}
