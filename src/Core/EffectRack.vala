namespace Ensembles.Core {
    public class EffectRack : Object {
        static List<Ensembles.PlugIns.PlugIn> plugin_references;

        // Sound buffers
        static float[] aud_buf_dry_l;
        static float[] aud_buf_dry_r;
        static float[] aud_buf_mix_l;
        static float[] aud_buf_mix_r;

        static float[] mixer_values;

        public static PlugIns.PlugIn[] get_plugins () {
            PlugIns.PlugIn[] plugs = new PlugIns.PlugIn [plugin_references.length ()];
            for (int i = 0; i < plugs.length; i++) {
                plugs[i] = plugin_references.nth_data (i);
            }
            return plugs;
        }

        public static void set_synth_callback (float[] buffer_l_in, float[] buffer_r_in, out float[] buffer_out_l, out float[] buffer_out_r) {
            // Initialize out buffer
            buffer_out_l = buffer_l_in;
            buffer_out_r = buffer_r_in;

            // If the main buffers aren't initialised
            if (EffectRack.aud_buf_dry_l == null || EffectRack.aud_buf_dry_r == null ||
                EffectRack.aud_buf_mix_l == null || EffectRack.aud_buf_mix_r == null) {
                // Initialise main buffers
                aud_buf_dry_l = new float [buffer_l_in.length];
                aud_buf_dry_r = new float [buffer_r_in.length];
                aud_buf_mix_l = new float [buffer_l_in.length];
                aud_buf_mix_r = new float [buffer_r_in.length];
                // Connect buffers to the effect rack
                EffectRack.connect_audio_ports (
                    aud_buf_dry_l,
                    aud_buf_dry_r,
                    aud_buf_mix_l,
                    aud_buf_mix_r
                );
            }
            // Fill main dry buffers with audio data
            for (int i = 0; i < buffer_l_in.length; i++) {
                aud_buf_dry_l[i] = buffer_l_in[i];
                aud_buf_dry_r[i] = buffer_r_in[i];
            }
            // Process audio using plugins
            EffectRack.process_audio (buffer_l_in.length);

            // Fill out buffers using wet mix;
            // Wet mix has been copied to the dry buffer; See below
            for (int i = 0; i < buffer_l_in.length; i++) {
                buffer_out_l[i] = aud_buf_dry_l[i];
                buffer_out_r[i] = aud_buf_dry_r[i];
            }
        }

        public static void populate_rack (PlugIns.PlugIn plugin) {
            plugin_references.append (plugin);
        }

        public static void create_plugins () {
            debug ("Creating Plugins\n");
            if (mixer_values == null) {
                mixer_values = new float [plugin_references.length ()];
            }
            for (int i = 0; i < plugin_references.length (); i++) {
                mixer_values[i] = 1.0f;
                plugin_references.nth_data (i).instantiate_plug (true, &mixer_values[i]);
            }
        }

        public static void connect_audio_ports (
            void* source_l,
            void* source_r,
            void* sink_l,
            void* sink_r
        ) {
            print ("Connecting\n");
            for (int i = 0; i < plugin_references.length (); i++) {
                plugin_references.nth_data (i).connect_source_buffer (source_l, source_r);
                plugin_references.nth_data (i).connect_sink_buffer (sink_l, sink_r);
            }
            print ("Connected\n");
        }

        public static void process_audio (uint32 sample_count) {
            for (uint i = 0; i < plugin_references.length (); i++) {
                if (plugin_references.nth_data (i).active && plugin_references.nth_data (i).valid) {
                    // Plugin process audio
                    plugin_references.nth_data (i).process (sample_count);

                    // Copy wet audio to dry buffer in amounts specified in mixer_values
                    for (uint32 j = 0; j < sample_count; j++) {
                        aud_buf_dry_l[j] = lerp (0.0f, aud_buf_dry_l[j], 1.0f, aud_buf_mix_l[j], mixer_values[i]);
                        aud_buf_dry_r[j] = lerp (0.0f, aud_buf_dry_r[j], 1.0f, aud_buf_mix_r[j], mixer_values[i]);
                    }

                    // Next plugin is ready to run
                }
            }
        }


        // Linear Interpolation function
        private static float lerp (float x0, float y0, float x1, float y1, float xp) {
            return (y0 + ((y1 - y0) / (x1 - x0)) * (xp - x0));
        }

        public static void show_plugin_ui (uint index) {
            var window = plugin_references.nth_data (index).get_ui ();
            window.present ();
            window.show_all ();
        }
    }
}
