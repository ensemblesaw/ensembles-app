/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "synthesizer_instance.h"

// These synth instance is used for actually renderring audio
fluid_synth_t* rendering_synth;
fluid_audio_driver_t* rendering_driver;
fluid_settings_t* rendering_settings;

// These instance is never used to render audio and only use for Midi players
fluid_synth_t* utility_synth;
fluid_audio_driver_t* utility_driver;
fluid_settings_t* utility_settings;



fluid_settings_t* get_settings(enum UseCase use_case);

static synthesizer_fx_callback fx_callback;

void
set_fx_callback (synthesizer_fx_callback callback) {
    fx_callback = callback;
}

int
fx_function(void *synth_data, int len,
                int nfx, float **fx,
                int nout, float **out) {
    if(fx == 0)
    {
        /* Note that some audio drivers may not provide buffers for effects like
         * reverb and chorus. In this case it's your decision what to do. If you
         * had called fluid_synth_process() like in the else branch below, no
         * effects would have been rendered. Instead, you may mix the effects
         * directly into the out buffers. */
        if(fluid_synth_process(synth_data, len, nout, out, nout, out) != FLUID_OK)
        {
            /* Some error occurred. Very unlikely to happen, though. */
            return FLUID_FAILED;
        }
    }
    else
    {
        /* Call the synthesizer to fill the output buffers with its
         * audio output. */
        if(fluid_synth_process(synth_data, len, nfx, fx, nout, out) != FLUID_OK)
        {
            /* Some error occurred. Very unlikely to happen, though. */
            return FLUID_FAILED;
        }
    }

    // All processing is stereo // Repeat processing if the plugin is mono
    float *out_l_i = out[0];
    float *out_r_i = out[1];
    // Apply effects here
    float *out_l_o = malloc (len * sizeof (float));
    float *out_r_o = malloc (len * sizeof (float));
    int size_l, size_r;
    if (fx_callback != NULL) {
        /*
         * The audio buffer data is sent to the plugin system
         */
        fx_callback (out_l_i, len, out_r_i, len, &out_l_o, &size_l, &out_r_o, &size_r);
        for (int k = 0; k < len; k++) {
            out_l_i[k] = out_l_o[k];
            out_r_i[k] = out_r_o[k];
        }
    }
    fluid_free (out_l_o);
    fluid_free (out_r_o);

    return FLUID_OK;
}


fluid_synth_t*
get_synthesizer(enum UseCase use_case)
{
    switch (use_case)
    {
        /*
         * Render is synth is used for renderring audio
         * Due to a technical limitation, we have decided to use a
         * separate synth for midi players and other utilities (see below)
         */
        case RENDER:
            if (rendering_synth == NULL)
            {
                rendering_synth = new_fluid_synth(rendering_settings);
                rendering_driver = new_fluid_audio_driver2(rendering_settings, fx_function, rendering_synth);
            }
            return rendering_synth;
        /*
         * Utility synths don't render any audio, they are used
         * by the midi players to generate events and they are also
         * used by some other "utilities" that only temporarily need
         * a synth instance
         */
        case UTILITY:
            if (utility_synth == NULL)
            {
                utility_synth = new_fluid_synth(utility_settings);
                utility_driver = new_fluid_audio_driver(utility_settings, utility_synth);
            }
            return utility_synth;
    }

    return NULL;
}

int
set_driver_configuration(const char* driver_name, double buffer_length_multiplier)
{
    if (rendering_settings == NULL) {
        rendering_settings = new_fluid_settings ();
        fluid_settings_setnum(rendering_settings, "synth.gain", 1.5);
        fluid_settings_setnum(rendering_settings, "synth.overflow.percussion", 5000.0);
        fluid_settings_setint(rendering_settings, "synth.midi-channels", 64);
        fluid_settings_setstr(rendering_settings, "synth.midi-bank-select", "gs");
    }
    if (utility_settings == NULL) {
        utility_settings = new_fluid_settings ();
        fluid_settings_setnum(utility_settings, "synth.overflow.percussion", 5000.0);
        fluid_settings_setstr(utility_settings, "synth.midi-bank-select", "gs");
        fluid_settings_setint(utility_settings, "synth.cpu-cores", 4);
    }
    if (strcmp (driver_name, "alsa") == 0) {
        fluid_settings_setstr(rendering_settings, "audio.driver", "alsa");
        fluid_settings_setint(rendering_settings, "audio.periods",8);
        fluid_settings_setint(rendering_settings, "audio.period-size", (int)(86.0 + (buffer_length_multiplier * 938.0)));
        fluid_settings_setint(rendering_settings, "audio.realtime-prio", 80);

        fluid_settings_setstr(utility_settings, "audio.driver", "alsa");
        fluid_settings_setint(utility_settings, "audio.periods",16);
        fluid_settings_setint(utility_settings, "audio.period-size", (int)(64.0 + (buffer_length_multiplier * 938.0)));
        fluid_settings_setint(utility_settings, "audio.realtime-prio", 70);

        return (int)(86.0 + (buffer_length_multiplier * 938.0));
    }
    if (strcmp (driver_name, "pulseaudio") == 0) {
        fluid_settings_setstr(rendering_settings, "audio.driver", "pulseaudio");
        fluid_settings_setint(rendering_settings, "audio.periods",8);
        fluid_settings_setint(rendering_settings, "audio.period-size", (int)(1024.0 + (buffer_length_multiplier * 3072.0)));
        fluid_settings_setint(rendering_settings, "audio.realtime-prio", 80);
        // fluid_settings_setint(rendering_settings, "audio.pulseaudio.adjust-latency", 0);

        fluid_settings_setstr(utility_settings, "audio.driver", "pulseaudio");
        fluid_settings_setint(utility_settings, "audio.periods", 2);
        fluid_settings_setint(utility_settings, "audio.period-size", 512);
        fluid_settings_setint(utility_settings, "audio.realtime-prio", 90);

        return (int)(1024.0 + (buffer_length_multiplier * 3072.0));
    }
    if (strcmp (driver_name, "pipewire-pulse") == 0) {
        fluid_settings_setstr(rendering_settings, "audio.driver", "pulseaudio");
        fluid_settings_setint(rendering_settings, "audio.periods",8);
        fluid_settings_setint(rendering_settings, "audio.period-size", (int)(512.0 + (buffer_length_multiplier * 3584.0)));
        fluid_settings_setint(rendering_settings, "audio.pulseaudio.adjust-latency", 0);

        fluid_settings_setstr(utility_settings, "audio.driver", "pulseaudio");
        fluid_settings_setint(utility_settings, "audio.periods", 2);
        fluid_settings_setint(utility_settings, "audio.period-size", 512);

        return (int)(512.0 + (buffer_length_multiplier * 3584.0));
    }
    if (strcmp (driver_name, "jack") == 0) {
        fluid_settings_setnum(rendering_settings, "synth.gain", 0.005);
        fluid_settings_setstr(rendering_settings, "audio.driver", "jack");
        fluid_settings_setstr(rendering_settings, "audio.jack.id", "Ensembles Audio Output");

        fluid_settings_setstr(utility_settings, "audio.driver", "jack");
        fluid_settings_setstr(utility_settings, "audio.jack.id", "Ensembles Utility");

        return 0;
    }
    if (strcmp (driver_name, "pipewire") == 0) {
        fluid_settings_setstr(rendering_settings, "audio.driver", "pipewire");
        fluid_settings_setint(rendering_settings, "audio.period-size", 64);
        fluid_settings_setint(rendering_settings, "audio.pulseaudio.adjust-latency", 0);
        fluid_settings_setstr(rendering_settings, "audio.pipewire.media-role", "Production");
        fluid_settings_setstr(rendering_settings, "audio.pipewire.media-type", "Audio");

        fluid_settings_setstr(utility_settings, "audio.driver", "pipewire");
        fluid_settings_setint(utility_settings, "audio.period-size", 64);
        fluid_settings_setint(utility_settings, "audio.realtime-prio", 1);
        fluid_settings_setstr(utility_settings, "audio.pipewire.media-role", "Production");
        fluid_settings_setstr(utility_settings, "audio.pipewire.media-type", "Audio");

        return (int)(64.0 + (buffer_length_multiplier * 128.0));
    }

    return 0;
}

void
delete_synthesizer_instances()
{
    // Delete utility synth instance
    delete_fluid_audio_driver(utility_driver);
    delete_fluid_synth(utility_synth);
    delete_fluid_settings(utility_settings);

    // Delete render synth instance
    delete_fluid_audio_driver(rendering_driver);
    delete_fluid_synth(rendering_synth);
    delete_fluid_settings(rendering_settings);
}
