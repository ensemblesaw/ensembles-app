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

#include <fluidsynth.h>
#include <gtk/gtk.h>
#include <glib.h>
#include <string.h>

#include "style_analyser.h"
#include "central_bus.h"
#include "synthesizer.h"

// None of this will be used for actual rendering /////////
fluid_settings_t* settings;
fluid_synth_t* synth;
fluid_audio_driver_t* adriver;
fluid_player_t* player;
///////////////////////////////////////////////////////////

int measure_length = 0;

char* metronome_file_path;