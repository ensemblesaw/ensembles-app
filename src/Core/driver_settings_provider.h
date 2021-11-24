/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef DRIVER_SETTINGS_PROVIDER_H
#define DRIVER_SETTINGS_PROVIDER_H

#include <fluidsynth.h>
#include <string.h>

enum SynthLocation {
    STYLE_ENGINE,
    STYLE_SYNTH,
    REALTIME_SYNTH,
    METRONOME_PLAYER,
    MIDI_SONG_PLAYER
};

/*
 * Get Settings for Synthesizers based on where it's used
 */
fluid_settings_t* get_settings (enum SynthLocation synth_location);

void settings_changed_callback (void (*cc)(enum SynthLocation, fluid_settings_t*), enum SynthLocation synth_location, fluid_settings_t* settings);

void delete_settings (enum SynthLocation synth_location);

#endif /* DRIVER_SETTINGS_PROVIDER_H */
