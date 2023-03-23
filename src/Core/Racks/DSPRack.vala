/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
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
    public class DSPRack : Object {
        private List<AudioPlugin> dsp_plugins;

        public bool active = false;

        // Sound buffers
        float[] aud_buf_dry_l;
        float[] aud_buf_dry_r;
        float[] aud_buf_mix_l;
        float[] aud_buf_mix_r;

        construct {
            dsp_plugins = new List<AudioPlugin> ();
        }

        /**
         * Add a plugin to the end of the rack
         *
         * @param plugin AudioPlugin to append to the rack
         */
        public void append (AudioPlugin plugin) throws PluginError {
            if (plugin.category != AudioPlugin.Category.DSP) {
                throw new PluginError.INVALID_CATEGORY ("Attempted to add to non-DSP plugin to DSP Rack");
            }

            dsp_plugins.append (plugin);
            plugin.instantiate ();

            connect_audio_ports ();
        }

        /**
         * Add a plugin to the specified position
         *
         * @param plugin AudioPlugin to add to the rack
         * @param position The position in the stack where the plugin must
         * be added
         */
        public void insert (AudioPlugin plugin, int position) throws PluginError {
            if (plugin.category != AudioPlugin.Category.DSP) {
                throw new PluginError.INVALID_CATEGORY ("Attempted to add to non-DSP plugin to DSP Rack");
            }

            dsp_plugins.insert (plugin, position);
            plugin.instantiate ();

            connect_audio_ports ();
        }

        /**
         * Remove a plugin from the rack
         *
         * @param position The position in the stack from where the plugin will
         * be removed
         */
        public void remove (int position) {
            AudioPlugin plugin = dsp_plugins.nth_data (position);
            plugin.active = false;
            dsp_plugins.remove (plugin);

            connect_audio_ports ();
        }

        /**
         * Activate or deactivate a plugin
         *
         * A plugin will not process audio if it's not active
         *
         * @param position The position of the plugin in the rack
         * @param active Whether the plugin should be enabled or not
         */
        public void set_plugin_active (int position, bool active = true) {
            AudioPlugin plugin = dsp_plugins.nth_data (position);
            plugin.active = active;
        }

        /**
         * Process a given stereo audio buffer using plugins
         *
         * @param buffer_in_l Audio input buffer for left channel
         * @param buffer_in_r Audio input buffer for right channel
         * @param buffer_out_l Audio output buffer for left channel
         * @param buffer_out_r Audio output buffer for right channel
         */
        public void process_audio (float[] buffer_in_l, float[] buffer_in_r,
        out float[] buffer_out_l, out float[] buffer_out_r) {
            // Fill out with dry audio initially
            buffer_out_l = buffer_in_l;
            buffer_out_r = buffer_in_r;

            // If the main buffers aren't initialised
            // initialize them
            if (aud_buf_dry_l == null || aud_buf_dry_r == null ||
            aud_buf_mix_l == null || aud_buf_mix_r == null) {
                aud_buf_dry_l = new float[buffer_in_l.length];
                aud_buf_dry_r = new float[buffer_in_r.length];
                aud_buf_mix_l = new float[buffer_in_l.length];
                aud_buf_mix_r = new float[buffer_in_r.length];
            }

            // Fill main dry buffers with audio data
            for (int i = 0; i < buffer_in_l.length; i++) {
                aud_buf_dry_l[i] = buffer_in_l[i];
                aud_buf_dry_r[i] = buffer_in_r[i];
            }

            // Process audio using plugins
            run_plugins (buffer_in_l.length);

            // Fill out buffers using wet mix;
            // Wet mix has been copied to the dry buffer; See below
            for (int i = 0; i < buffer_in_l.length; i++) {
                buffer_out_l[i] = aud_buf_dry_l[i];
                buffer_out_r[i] = aud_buf_dry_r[i];
            }
        }

        private void run_plugins (uint32 sample_count) {
            if (active) {
                foreach (AudioPlugin plugin in dsp_plugins) {
                    if (plugin.active) {
                        // Have the plugin process the audio buffer
                        plugin.process (sample_count);

                        // Copy wet audio to dry buffer as per mix amount
                        for (uint32 j = 0; j < sample_count; j++) {
                            aud_buf_dry_l[j] = map_range (0.0f, aud_buf_dry_l[j],
                                1.0f, aud_buf_mix_l[j], plugin.mix_gain);
                            aud_buf_dry_r[j] = map_range (0.0f, aud_buf_dry_r[j],
                                1.0f, aud_buf_mix_r[j], plugin.mix_gain);
                        }

                        // Next plugin ready to run
                    }
                }
            }
        }

        private void connect_audio_ports () {
            var was_active = active;
            active = false;

            foreach (AudioPlugin plugin in dsp_plugins) {
                plugin.connect_source_buffer (aud_buf_dry_l, aud_buf_dry_r);
                plugin.connect_sink_buffer (aud_buf_mix_l, aud_buf_mix_r);
            }

            active = was_active;
        }

        private float map_range (float x0, float y0, float x1, float y1, float xp) {
            return (y0 + ((y1 - y0) / (x1 - x0)) * (xp - x0));
        }
    }
}
