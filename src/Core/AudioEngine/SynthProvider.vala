/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.AudioEngine {
    /**
     * ## Synthesizer Instance Provider
     *
     * Manages FluidSynth instances and driver configurations.
     */
    public class SynthProvider : Object {
        private Fluid.Synth _rendering_synth;
        private Fluid.AudioDriver rendering_driver;
        private Fluid.Settings rendering_settings;

        public delegate void SynthRenderHandler (
            int len,
            float* input_l,
            float* input_r,
            float** output_l,
            float** output_r
        );

        private static float* wet_buffer_l;
        private static float* wet_buffer_r;

        public static SynthRenderHandler synth_render_handler;

        ~SynthProvider () {
            Fluid.free (wet_buffer_l);
            Fluid.free (wet_buffer_r);
        }

        /**
         * This synth instance is used for actually renderring audio
         */
        public unowned Fluid.Synth rendering_synth {
            get {
                if (_rendering_synth == null) {
                    rendering_settings = new Fluid.Settings ();
                    rendering_settings.setnum ("synth.gain", 1);
                    rendering_settings.setnum ("synth.overflow.percussion", 5000.0);
                    rendering_settings.setint ("synth.midi-channels", 64);
                    rendering_settings.setstr ("synth.midi-bank-select", "gs");
                    rendering_settings.setint ("synth.polyphony", 1024);

                    _rendering_synth = new Fluid.Synth (rendering_settings);
                    rendering_driver = new Fluid.AudioDriver.with_audio_callback (rendering_settings,
                        (synth, len, fx, aout) => {
                        if (fx == null) {
                            /* Note that some audio drivers may not provide buffers for effects like
                             * reverb and chorus. In this case it's your decision what to do. If you
                             * had called process() like in the else branch below, no
                             * effects would have been rendered. Instead, you may mix the effects
                             * directly into the out buffers. */
                            if (((Fluid.Synth)synth).process (len, aout, aout) != Fluid.OK) {
                                return Fluid.FAILED;
                            }
                        } else {
                             /* Call the synthesizer to fill the output buffers with its
                              * audio output. */
                            if (((Fluid.Synth)synth).process (len, fx, aout) != Fluid.OK) {
                                return Fluid.FAILED;
                            }
                        }

                        // All processing is stereo // Repeat processing if the plugin is mono
                        float* dry_buffer_l = aout[0];
                        float* dry_buffer_r = aout[1];

                        // Apply effects here
                        if (wet_buffer_l == null || wet_buffer_r == null) {
                            wet_buffer_l = malloc (len * sizeof (float));
                            wet_buffer_r = malloc (len * sizeof (float));
                        }

                        //  int size_l, size_r;

                        if (synth_render_handler != null) {
                            for (int k = 0; k < len; k++) {
                                wet_buffer_l[k] = dry_buffer_l[k];
                                wet_buffer_r[k] = dry_buffer_r[k];
                            }
                            /*
                             * The audio buffer data is sent to the plugin system
                             */
                            synth_render_handler (len,
                                dry_buffer_l,
                                dry_buffer_r,
                                &wet_buffer_l,
                                &wet_buffer_r);

                            for (int k = 0; k < len; k++) {
                                dry_buffer_l[k] = wet_buffer_l[k];
                                dry_buffer_r[k] = wet_buffer_r[k];
                            }
                        }

                        return Fluid.OK;
                    }, _rendering_synth);
                }
                return _rendering_synth;
            }
        }

        private Fluid.Synth _utility_synth;
        private Fluid.AudioDriver utility_driver;
        private Fluid.Settings utility_settings;

        /** This instance is never used to render audio and only use for Midi players
         */
        public unowned Fluid.Synth utility_synth {
            get {
                if (_utility_synth == null) {
                    utility_settings = new Fluid.Settings ();
                    utility_settings.setnum ("synth.overflow.percussion", 5000.0);
                    utility_settings.setstr ("synth.midi-bank-select", "gs");
                    utility_settings.setint ("synth.cpu-cores", 4);

                    _utility_synth = new Fluid.Synth (utility_settings);
                    utility_driver = new Fluid.AudioDriver (utility_settings, _utility_synth);
                }
                return _utility_synth;
            }
        }

        /**
         * Sets driver configuration of synthesizer instance
         *
         * This should be called before accessing any synth
         */
        public int init_driver (string driver_name, double buffer_length_multiplier) {
            switch (driver_name) {
                case "alsa":
                    rendering_settings.setstr ("audio.driver", "alsa");
                    rendering_settings.setint ("audio.periods", 8);
                    rendering_settings.setint ("audio.period-size", (int)(86.0 + (buffer_length_multiplier * 938.0)));
                    rendering_settings.setint ("audio.realtime-prio", 80);

                    utility_settings.setstr ("audio.driver", "alsa");
                    utility_settings.setint ("audio.periods", 16);
                    utility_settings.setint ("audio.period-size", (int)(64.0 + (buffer_length_multiplier * 938.0)));
                    utility_settings.setint ("audio.realtime-prio", 70);

                    return (int)(86.0 + (buffer_length_multiplier * 938.0));
                case "pulseaudio":
                    rendering_settings.setstr ("audio.driver", "pulseaudio");
                    rendering_settings.setint ("audio.periods", 8);
                    rendering_settings.setint ("audio.period-size",
                        (int)(1024.0 + (buffer_length_multiplier * 3072.0)));
                    rendering_settings.setint ("audio.realtime-prio", 80);
                    // rendering_settings.setint ("audio.pulseaudio.adjust-latency", 0);

                    utility_settings.setstr ("audio.driver", "pulseaudio");
                    utility_settings.setint ("audio.periods", 2);
                    utility_settings.setint ("audio.period-size", 512);
                    utility_settings.setint ("audio.realtime-prio", 90);
                    utility_settings.setint ("audio.pulseaudio.adjust-latency", 0);

                    return (int)(1024.0 + (buffer_length_multiplier * 3072.0));
                case "pipewire-pulse":
                    rendering_settings.setstr ("audio.driver", "pulseaudio");
                    rendering_settings.setint ("audio.periods", 8);
                    rendering_settings.setint ("audio.period-size", (int)(512.0 + (buffer_length_multiplier * 3584.0)));
                    rendering_settings.setint ("audio.pulseaudio.adjust-latency", 0);

                    utility_settings.setstr ("audio.driver", "pulseaudio");
                    utility_settings.setint ("audio.periods", 2);
                    utility_settings.setint ("audio.period-size", 512);

                    return (int)(512.0 + (buffer_length_multiplier * 3584.0));
                case "jack":
                    rendering_settings.setnum ("synth.gain", 0.005);
                    rendering_settings.setstr ("audio.driver", "jack");
                    rendering_settings.setstr ("audio.jack.id", "Ensembles Audio Output");

                    utility_settings.setstr ("audio.driver", "jack");
                    utility_settings.setstr ("audio.jack.id", "Ensembles Utility");

                    return 0;
                case "pipewire":
                    rendering_settings.setstr ("audio.driver", "pipewire");
                    rendering_settings.setint ("audio.period-size", (int)(256.0 + (buffer_length_multiplier * 3584.0)));
                    rendering_settings.setint ("audio.realtime-prio", 80);
                    rendering_settings.setstr ("audio.pipewire.media-role", "Production");
                    rendering_settings.setstr ("audio.pipewire.media-type", "Audio");
                    rendering_settings.setstr ("audio.pipewire.media-category", "Playback");

                    utility_settings.setstr ("audio.driver", "pipewire");
                    utility_settings.setint ("audio.period-size", 256);
                    utility_settings.setint ("audio.realtime-prio", 90);
                    utility_settings.setstr ("audio.pipewire.media-role", "Game");
                    utility_settings.setstr ("audio.pipewire.media-type", "Audio");
                    utility_settings.setstr ("audio.pipewire.media-category", "Playback");

                    return (int)(256.0 + (buffer_length_multiplier * 3584.0));
            }

            return 0;
        }
    }
}


/*
 *  RENDER SYNTH CHANNEL UTILIZATION SCHEMATICS
 * ----------------------------------------------
 *
 *  Style, Song:
 *  0 - 15
 *
 *  Metronome:
 *  16
 *
 *  MIDI INPUT:
 *  Voice R1      ~ 17
 *  Voice R2      ~ 18
 *  Voice L       ~ 19
 *  CHORD-EP      ~ 20
 *  CHORD-Strings ~ 21
 *  CHORD-Bass    ~ 22
 *
 *  CHIMES:
 *  23
 *
 *  RECORDER:
 *  Voice R2    ~ 24
 *  Voice L     ~ 25
 *  All tracks  ~ 26 - 63
 */
