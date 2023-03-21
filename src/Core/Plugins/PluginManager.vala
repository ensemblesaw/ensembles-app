/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.Plugins {
    public class PluginManager : Object {
        private AudioPlugins.LADSPAV2.LV2Manager lv2_audio_plugin_manager;

        construct {
            // Load Audio Plugins
            // Load LV2 Plugins
            lv2_audio_plugin_manager = new AudioPlugins.LADSPAV2.LV2Manager ();

            unowned List<AudioPlugins.LADSPAV2.LV2Plugin> lv2_plugins = lv2_audio_plugin_manager.load_plugins ();

            foreach (var lv2_plugin in lv2_plugins) {
                switch (lv2_plugin.category) {
                    case AudioPlugins.AudioPlugin.Category.DSP:
                    // Send to DSP Rack
                    break;
                    case AudioPlugins.AudioPlugin.Category.VOICE:
                    // Send to Voice Rack
                    break;
                }
            }
        }
    }
}
