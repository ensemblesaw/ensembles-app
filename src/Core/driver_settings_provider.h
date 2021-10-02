/*-
 * Copyright (c) 2021-2022 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
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

#endif /* DRIVER_SETTINGS_PROVIDER_H */
