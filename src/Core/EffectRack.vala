namespace Ensembles.Core {
    public class EffectRack : Object {
        static List<Ensembles.PlugIns.PlugIn> plugin_references;

        // Sound buffers
        public static float[] aud_buf_dry_l;
        public static float[] aud_buf_dry_r;
        public static float[] aud_buf_mix_l;
        public static float[] aud_buf_mix_r;

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
            // Process audio using effect rack
            EffectRack.process_audio (buffer_l_in.length);

            // Fill out buffers using the wet mix;
            for (int i = 0; i < buffer_l_in.length; i++) {
                buffer_out_l[i] = aud_buf_mix_l[i];
                buffer_out_r[i] = aud_buf_mix_r[i];
            }
        }

        public static void populate_rack (PlugIns.PlugIn plugin) {
            plugin_references.append (plugin);
        }

        public static void create_plugins () {
            debug ("Creating Plugins\n");
            for (int i = 0; i < plugin_references.length (); i++) {

            }
            plugin_references.nth_data (0).instantiate_plug (true);
            var window = plugin_references.nth_data (0).get_ui ();
            window.present ();
            window.show_all ();
        }

        public static void connect_audio_ports (
            void* source_l,
            void* source_r,
            void* sink_l,
            void* sink_r
        ) {
            print ("Connecting\n");
            for (int i = 0; i < plugin_references.length (); i++) {
                plugin_references.nth_data (0).connect_source_buffer (source_l, source_r);
                plugin_references.nth_data (0).connect_sink_buffer (sink_l, sink_r);
            }
            print ("Connected\n");
        }

        public static void process_audio (uint32 sample_count) {
            for (uint i = 0; i < plugin_references.length (); i++) {
                plugin_references.nth_data (i).process (sample_count);
                for (uint32 j = 0; j < sample_count; j++) {
                    aud_buf_dry_l[j] = aud_buf_mix_l[j];
                    aud_buf_dry_r[j] = aud_buf_mix_r[j];
                }
            }
        }
    }
}
