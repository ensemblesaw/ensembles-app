namespace Ensembles.Core {
    public class EffectRack : Object {
        static List<Ensembles.PlugIns.PlugIn> plugin_references;

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
            plugin_references.nth_data (0).connect_source_buffer (source_l, source_r);
            plugin_references.nth_data (0).connect_sink_buffer (sink_l, sink_r);
            print ("Connected\n");
        }

        public static void process_audio (uint32 sample_count) {
            plugin_references.nth_data (0).process (sample_count);
        }
    }
}
