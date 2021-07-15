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

#ifndef SYNTHESIZER_SETTINGS_H
#define SYNTHESIZER_SETTINGS_H

// Reverb presets
/** Get reverb room size for given magnitude
 */
double get_reverb_room_size (int magnitude);
/** Get reverb stereo width for given magnitude
 */
double get_reverb_width (int magnitude);
/** Get reverb gain for given magnitude
 */
double get_reverb_level (int magnitude);

// Chorus presets
/** Get chorus depth for given magnitude
 */
double get_chorus_depth (int magnitude);
/** Get number of chorus voices for given magnitude
 */
double get_chorus_nr (int magnitude);
/** Get chorus gain for given magnitude
 */
double get_chorus_level (int magnitude);

// Modulator buffers
/** Get Gain value of style channel
 */
int get_gain_value (int channel);

/** Set Gain value of style channel
 */
void set_gain_value (int channel, int value);

/** Gets the modulator value of style channel by modulator number
 */
int get_mod_buffer_value (int modulator, int channel);

/** Sets the modulator value of style channel by modulator number
 */
void set_mod_buffer_value (int modulator, int channel, int value);

#endif /* SYNTHESIZER_SETTINGS_H */
