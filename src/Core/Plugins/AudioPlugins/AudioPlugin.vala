/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.Plugins.AudioPlugins {
    /**
     * The base audio plugin type.
     *
     * An audio plugin can be used for DSP or as voices, expanding
     * the standard set of sampled voices that Ensembles come with.
     */
    public abstract class AudioPlugin : Plugin {
        public enum Category {
            DSP,
            VOICE,
            UNSUPPORTED
        }

        public enum Tech {
            NATIVE,
            LADSPA,
            LV2,
            CARLA
        }

        // Plugin Information
        public string license;
        public Tech tech { get; protected set; }
        public Category category { get; protected set; }

        public bool stereo_source { get; protected set; }
        public bool stereo_sink { get; protected set; }

        protected float _mix_gain = 1;
        public float mix_gain {
            get {
                return _mix_gain;
            }
            set {
                _mix_gain = value;
            }
        }

        public Port[] audio_in_ports;
        public Port[] audio_out_ports;

        public bool stereo { get; protected set; }

        public bool has_generated_ui { get; protected set; }
        public bool has_custom_ui { get; protected set; }

        protected AudioPlugin () {
            base ();
        }

        public abstract void connect_source_buffer (void* in_l, void* in_r);

        public abstract void connect_sink_buffer (void* out_l, void* out_r);

        /**
         * Connect a port to local variable. Connect all ports before activating
         * plugin
         */
        public abstract void connect_port (Port port, void* data_pointer);

        /**
         * Running this function will fill the sink buffers with processed audio
         * as per the functionality defined in this function
         */
        public abstract void process (uint32 sample_count);

        public abstract AudioPlugin duplicate () throws PluginError;

        public abstract Gtk.Widget? get_generated_ui ();

        public abstract Gtk.Widget? get_custom_ui ();
    }
}
