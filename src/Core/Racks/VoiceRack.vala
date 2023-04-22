/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Core.Plugins.AudioPlugins;

namespace Ensembles.Core.Racks {
    /**
     * ## Voice Rack
     *
     * This rack supports voice / instrument plugins.
     *
     * Every individual voice plugin can be associated with an instance
     * of DSP Rack.
     */
    public class VoiceRack : Rack {
        private List<DSPRack> dsp_racks;

        /**
         * Whether only a single instance of a plugin is allowed to process audio.
         */
        public bool exclusive_mode { get; set; }

        public VoiceRack () {
            Object (
                rack_type: AudioPlugin.Category.VOICE,
                exclusive_mode: true
            );

            dsp_racks = new List<DSPRack> ();
        }

        public int send_midi_event (Fluid.MIDIEvent event) {
            if (!active) {
                return Fluid.FAILED;
            }

            bool handled = false;
            foreach (var plugin in plugins) {
                if (plugin.active && plugin.send_midi_event (event) == Fluid.OK) {
                    handled = true;
                }
            }

            return handled ? Fluid.OK : Fluid.FAILED;
        }

        public override void set_plugin_active (int position, bool active = true) {
            base.set_plugin_active (position, active);

            if (active && exclusive_mode) {
                uint n = plugins.length ();
                for (uint i = 0; i < n; i++) {
                    if (i != position) {
                        plugins.nth_data (i).active = false;
                    }
                }
            }
        }
    }
}
