/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.Plugins {
    public class PluginManager : Object {
        // Audio Plugins
        public List<AudioPlugins.AudioPlugin> audio_plugins;

        private AudioPlugins.LADSPAV2.LV2Manager lv2_audio_plugin_manager;

        construct {
            // Load Audio Plugins //////////////////////////////////////////////
            Console.log ("Loading Audio Plugins…");
            audio_plugins = new List<AudioPlugins.AudioPlugin> ();

            // Load LADSPA Plugins

            // Load LV2 Plugins
            lv2_audio_plugin_manager = new AudioPlugins.LADSPAV2.LV2Manager ();
            lv2_audio_plugin_manager.load_plugins (audio_plugins);

            // Load Carla Plugins

            // Load Native Plugins

            Console.log ("Audio Plugins Loaded Successfully!",
            Console.LogLevel.SUCCESS);
        }
    }
}
