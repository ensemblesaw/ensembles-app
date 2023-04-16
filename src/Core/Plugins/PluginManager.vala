/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.Plugins {
    /**
     * ## Plugin Manager
     *
     * Plugins add additional functionality to Ensembles externally.
     *
     * The following types of plugins may be supported:
     * - Audio Plugins
     * - Style Plugins
     * - Display Theme Plugins
     * - Functional Plugins
     */
    public class PluginManager : Object {
        /**
         * Audio Plugins (Voices and DSP)
         */
        public List<AudioPlugins.AudioPlugin> audio_plugins;

        private AudioPlugins.Lv2.LV2Manager lv2_audio_plugin_manager;

        construct {
            // Load Audio Plugins //////////////////////////////////////////////
            Console.log ("Loading Audio Plugins…");
            audio_plugins = new List<AudioPlugins.AudioPlugin> ();

            // Load LADSPA Plugins

            // Load LV2 Plugins
            lv2_audio_plugin_manager = new AudioPlugins.Lv2.LV2Manager ();
            lv2_audio_plugin_manager.load_plugins (this);

            // Load Carla Plugins

            // Load Native Plugins

            Console.log ("%u Audio Plugins Loaded Successfully!".printf (audio_plugins.length ()),
            Console.LogLevel.SUCCESS);
        }
    }
}
