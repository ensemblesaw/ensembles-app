/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "synthesizer_instance.h"

fluid_audio_driver_t* rendering_driver;
fluid_synth_t* rendering_synth;

fluid_audio_driver_t* utility_driver;
fluid_synth_t* utility_synth;

fluid_settings_t* rendering_settings;
fluid_settings_t* utility_settings;

char* driver_name;
double buffer_length_multiplier;
fluid_settings_t* get_settings(enum UseCase use_case);

fluid_synth_t*
get_synthesizer(enum UseCase use_case)
{
    set_configuration(use_case);
    switch (use_case)
    {
        case RENDER:
            if (rendering_synth == NULL)
            {
                rendering_synth = new_fluid_synth(rendering_settings);
                rendering_driver = new_fluid_audio_driver(rendering_settings, rendering_synth);
            }
            return rendering_synth;
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

void
set_configuration(enum UseCase use_case)
{
    switch (use_case)
    {
        case RENDER:
            if (rendering_settings != NULL) {
                delete_fluid_settings (rendering_settings);
            }
            rendering_settings = new_fluid_settings ();
            if (strcmp (driver_name, "alsa") == 0) {
                fluid_settings_setstr(rendering_settings, "audio.driver", "alsa");
                fluid_settings_setint(rendering_settings, "audio.periods",8);
                fluid_settings_setint(rendering_settings, "audio.period-size", (int)(86.0 + (buffer_length_multiplier * 938.0)));
                fluid_settings_setint(rendering_settings, "audio.realtime-prio", 80);
            }
            if (strcmp (driver_name, "pulseaudio") == 0) {
                fluid_settings_setstr(rendering_settings, "audio.driver", "pulseaudio");
                fluid_settings_setint(rendering_settings, "audio.periods",2);
                fluid_settings_setint(rendering_settings, "audio.period-size", (int)(1024.0 + (buffer_length_multiplier * 3072.0)));
                fluid_settings_setint(rendering_settings, "audio.realtime-prio", 90);
                fluid_settings_setint(rendering_settings, "audio.pulseaudio.adjust-latency", 0);
            }
            if (strcmp (driver_name, "pipewire-pulse") == 0) {
                fluid_settings_setstr(rendering_settings, "audio.driver", "pulseaudio");
                fluid_settings_setint(rendering_settings, "audio.periods",2);
                fluid_settings_setint(rendering_settings, "audio.period-size", (int)(1024.0 + (buffer_length_multiplier * 3072.0)));
                fluid_settings_setint(rendering_settings, "audio.pulseaudio.adjust-latency", 0);
            }
            if (strcmp (driver_name, "pipewire") == 0) {
                fluid_settings_setstr(rendering_settings, "audio.driver", "pipewire");
                fluid_settings_setint(rendering_settings, "audio.period-size", 64);
                fluid_settings_setint(rendering_settings, "audio.pulseaudio.adjust-latency", 0);
                fluid_settings_setstr(rendering_settings, "audio.pipewire.media-role", "Production");
                fluid_settings_setstr(rendering_settings, "audio.pipewire.media-type", "Audio");
            }
            fluid_settings_setnum(rendering_settings, "synth.gain", 2);
            fluid_settings_setnum(rendering_settings, "synth.overflow.percussion", 5000.0);
            fluid_settings_setstr(rendering_settings, "synth.midi-bank-select", "gs");
        case UTILITY:
            if (utility_settings != NULL) {
                delete_fluid_settings (utility_settings);
            }
            utility_settings = new_fluid_settings ();
            if (strcmp (driver_name, "alsa") == 0) {
                fluid_settings_setstr(utility_settings, "audio.driver", "alsa");
                fluid_settings_setint(utility_settings, "audio.periods",16);
                fluid_settings_setint(utility_settings, "audio.period-size", (int)(86.0 + (buffer_length_multiplier * 938.0)));
                fluid_settings_setint(utility_settings, "audio.realtime-prio", 70);
            }
            if (strcmp (driver_name, "pulseaudio") == 0) {
                fluid_settings_setstr(utility_settings, "audio.driver", "pulseaudio");
                fluid_settings_setint(utility_settings, "audio.periods", 8);
                fluid_settings_setint(utility_settings, "audio.period-size", (int)(1024.0 + (buffer_length_multiplier * 3072.0)));
                fluid_settings_setint(utility_settings, "audio.realtime-prio", 70);
            }
            if (strcmp (driver_name, "pipewire-pulse") == 0) {
                fluid_settings_setstr(utility_settings, "audio.driver", "pulseaudio");
                fluid_settings_setint(utility_settings, "audio.periods", 8);
                fluid_settings_setint(utility_settings, "audio.period-size", (int)(1024.0 + (buffer_length_multiplier * 3072.0)));
            }
            if (strcmp (driver_name, "pipewire") == 0) {
                fluid_settings_setstr(utility_settings, "audio.driver", "pipewire");
                fluid_settings_setint(utility_settings, "audio.period-size", 64);
                fluid_settings_setint(utility_settings, "audio.realtime-prio", 1);
                fluid_settings_setstr(utility_settings, "audio.pipewire.media-role", "Production");
                fluid_settings_setstr(utility_settings, "audio.pipewire.media-type", "Audio");
            }
            fluid_settings_setnum(utility_settings, "synth.gain", 2);
            fluid_settings_setnum(utility_settings, "synth.overflow.percussion", 5000.0);
            fluid_settings_setstr(utility_settings, "synth.midi-bank-select", "gs");
    }
}
