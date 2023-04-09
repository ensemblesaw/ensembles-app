/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
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
        /**
         * The technology this plugin is based on
         */
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

        protected Port[] audio_in_ports;
        protected Port[] audio_out_ports;

        /**
         * Whether the audio plugin can process stereo audio.
         */
        public bool stereo { get; protected set; }

        protected AudioPlugin () {
            base ();
        }

        public abstract void connect_source_buffer (void* in_l, void* in_r);

        public abstract void connect_sink_buffer (void* out_l, void* out_r);

        public abstract void send_midi_event (Fluid.MIDIEvent midi_event);

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
    }
}
