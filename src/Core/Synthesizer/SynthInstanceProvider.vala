/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.Synthesizer {
    public class SynthInstanceProvider : Object {
        // These synth instance is used for actually renderring audio
        private Fluid.Synth rendering_synth;
        private Fluid.AudioDriver rendering_driver;
        private Fluid.Settings rendering_settings;

        // These instance is never used to render audio and only use for Midi players
        private Fluid.Synth utility_synth;
        private Fluid.AudioDriver utility_driver;
        private Fluid.Settings utility_settings;

        construct {
            set_default_settings ();
        }

        private void set_default_settings () {
            rendering_settings = new Fluid.Settings ();
            rendering_settings.setnum ("synth.gain", 1.5);
            rendering_settings.setnum("synth.overflow.percussion", 5000.0);
            rendering_settings.setint("synth.midi-channels", 64);
            rendering_settings.setstr("synth.midi-bank-select", "gs");
            rendering_settings.setint("synth.polyphony", 1024);

            utility_settings = new Fluid.Settings ();
            utility_settings.setnum("synth.overflow.percussion", 5000.0);
            utility_settings.setstr("synth.midi-bank-select", "gs");
            utility_settings.setint("synth.cpu-cores", 4);
        }


        public unowned Fluid.Synth get_fluid_synth_instance (SynthType synth_type) {
            switch (synth_type) {
                case SynthType.RENDER:
                    if (rendering_synth == null)
                    {
                        rendering_synth = new Fluid.Synth (rendering_settings);
                        rendering_driver = new Fluid.AudioDriver.with_audio_callback (rendering_settings, (synth_data, len, fx, aout) => {
                            return 0;
                        }, rendering_synth);
                    }
                    return rendering_synth;
                case SynthType.UTILITY:
                    if (utility_synth == null)
                    {
                        utility_synth = new Fluid.Synth (utility_settings);
                        utility_driver = new Fluid.AudioDriver (utility_settings, utility_synth);
                    }
                    return utility_synth;
            }

            return utility_synth;
        }

        public int set_driver_configuration (string driver_name, double buffer_length_multiplier) {
            switch (driver_name) {
                case "alsa":
                    rendering_settings.setstr("audio.driver", "alsa");
                    rendering_settings.setint("audio.periods",8);
                    rendering_settings.setint("audio.period-size", (int)(86.0 + (buffer_length_multiplier * 938.0)));
                    rendering_settings.setint("audio.realtime-prio", 80);

                    utility_settings.setstr("audio.driver", "alsa");
                    utility_settings.setint("audio.periods",16);
                    utility_settings.setint("audio.period-size", (int)(64.0 + (buffer_length_multiplier * 938.0)));
                    utility_settings.setint("audio.realtime-prio", 70);

                    return (int)(86.0 + (buffer_length_multiplier * 938.0));
                case "pulseaudio":
                    rendering_settings.setstr("audio.driver", "pulseaudio");
                    rendering_settings.setint("audio.periods",8);
                    rendering_settings.setint("audio.period-size", (int)(1024.0 + (buffer_length_multiplier * 3072.0)));
                    rendering_settings.setint("audio.realtime-prio", 80);
                    // rendering_settings.setint("audio.pulseaudio.adjust-latency", 0);

                    utility_settings.setstr("audio.driver", "pulseaudio");
                    utility_settings.setint("audio.periods", 2);
                    utility_settings.setint("audio.period-size", 512);
                    utility_settings.setint("audio.realtime-prio", 90);
                    utility_settings.setint("audio.pulseaudio.adjust-latency", 0);

                    return (int)(1024.0 + (buffer_length_multiplier * 3072.0));
                case "pipewire-pulse":
                    rendering_settings.setstr("audio.driver", "pulseaudio");
                    rendering_settings.setint("audio.periods",8);
                    rendering_settings.setint("audio.period-size", (int)(512.0 + (buffer_length_multiplier * 3584.0)));
                    rendering_settings.setint("audio.pulseaudio.adjust-latency", 0);

                    utility_settings.setstr("audio.driver", "pulseaudio");
                    utility_settings.setint("audio.periods", 2);
                    utility_settings.setint("audio.period-size", 512);

                    return (int)(512.0 + (buffer_length_multiplier * 3584.0));
                case "jack":
                    rendering_settings.setnum("synth.gain", 0.005);
                    rendering_settings.setstr("audio.driver", "jack");
                    rendering_settings.setstr("audio.jack.id", "Ensembles Audio Output");

                    utility_settings.setstr("audio.driver", "jack");
                    utility_settings.setstr("audio.jack.id", "Ensembles Utility");

                    return 0;
                case "pipewire":
                    rendering_settings.setstr("audio.driver", "pipewire");
                    rendering_settings.setint("audio.period-size", (int)(256.0 + (buffer_length_multiplier * 3584.0)));
                    rendering_settings.setint("audio.realtime-prio", 80);
                    rendering_settings.setstr("audio.pipewire.media-role", "Production");
                    rendering_settings.setstr("audio.pipewire.media-type", "Audio");
                    rendering_settings.setstr("audio.pipewire.media-category", "Playback");

                    utility_settings.setstr("audio.driver", "pipewire");
                    utility_settings.setint("audio.period-size", 256);
                    utility_settings.setint("audio.realtime-prio", 90);
                    utility_settings.setstr("audio.pipewire.media-role", "Game");
                    utility_settings.setstr("audio.pipewire.media-type", "Audio");
                    utility_settings.setstr("audio.pipewire.media-category", "Playback");

                    return (int)(256.0 + (buffer_length_multiplier * 3584.0));
            }

            return 0;
        }
    }
}
