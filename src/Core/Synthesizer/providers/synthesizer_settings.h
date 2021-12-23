/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
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
