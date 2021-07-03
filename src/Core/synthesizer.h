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


#ifndef SYNTHESIZER_H
#define SYNTHESIZER_H

#include <fluidsynth.h>

/** This function is used to receive midi events from style_player
 */
int handle_events_for_styles (fluid_midi_event_t *event);

/** This function is used to stop all synthesizer sounds for styles
 * except channel 10 i.e. drums
 */
void synthesizer_halt_notes ();

#endif /* SYNTHESIZER_H */