namespace Ensembles.Core {
    public class EffectRack : Object {
        static List<Ensembles.PlugIns.PlugIn> plugin_references;
        static Lilv.Instance?[] plugin_instances;

        static float[] dry_buffer_in;
        static float[] mix_buffer_out;
        static float gain = 0.0f;

        public static void populate_rack (PlugIns.PlugIn plugin) {
            plugin_references.append (plugin);
        }

        public static void create_plugins () {
            print ("creating...\n");
            plugin_instances = new Lilv.Instance? [plugin_references.length ()];
            for (int i = 0; i < plugin_instances.length; i++) {
                plugin_instances[i] = plugin_references.nth_data (i).lv2_plugin.instantiate (44100, null);
            }

            plugin_instances[0].activate ();
        }

        public static void connect_ports () {
            print ("Connecting port\n");
            plugin_instances[0].connect_port (0, &gain);
            plugin_instances[0].connect_port (1, dry_buffer_in);
            plugin_instances[0].connect_port (2, mix_buffer_out);
            print ("Connected port\n");
        }

        public static float[] process_audio (float[] dry_in) {
            if (dry_buffer_in == null || mix_buffer_out == null) {
                dry_buffer_in =  new float [dry_in.length];
                mix_buffer_out = new float [dry_in.length];
                connect_ports ();
            } else {
                for (int i = 0; i < dry_in.length; i++) {
                    dry_buffer_in[i] = dry_in[i];
                }
                if (plugin_instances.length > 0) {
                    print ("Running\n");
                    plugin_instances[0].run (dry_in.length);
                }
                return mix_buffer_out;
            }
            return dry_in;
        }
    }
}
