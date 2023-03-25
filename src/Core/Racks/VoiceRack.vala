/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Core.Plugins.AudioPlugins;

namespace Ensembles.Core.Racks {
    /**
     * This rack supports voice / instrument plugins.
     *
     * Every individual voice plugin can be associated with an instance
     * of DSP Rack.
     */
    public class VoiceRack : Rack {
        private List<DSPRack> dsp_racks;

        public VoiceRack () {
            Object (
                rack_type: AudioPlugin.Category.VOICE
            );

            dsp_racks = new List<DSPRack> ();
        }
    }
}
