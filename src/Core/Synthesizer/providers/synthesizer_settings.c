/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "synthesizer_settings.h"

// Reverb presets
double reverb_room_size[11] = { 0.0, 0.1, 0.2, 0.3, 0.4, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9};
double reverb_width[11]     = { 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20 };
double reverb_level[11]     = { 0, 0.05, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 };

// Chorus presets
double chorus_depth[11] = {0, 4, 4, 4, 6, 10, 20, 25, 30, 35, 40 };
double chorus_nr[11] = { 0, 2, 3, 3, 4, 5, 6, 8, 10, 16, 20 };
double chorus_level[11] = { 0, 0.1, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2 };


/** Modulator values for style
 */
// Mixer gain values
int gain_value[16] = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };

int pan_value[16] = { -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65 };
int reverb_value[16] = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };
int chorus_value[16] = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };
int pitch_value[16] = { -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65, -65 };
int expression_value[16] = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };
int modulation_value[16] = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };
int cut_off_value[16] = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };
int resonance_value[16] = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };

double
get_reverb_room_size (int magnitude) {
    return reverb_room_size[magnitude];
}

double
get_reverb_width (int magnitude) {
    return reverb_width[magnitude];
}

double
get_reverb_level (int magnitude) {
    return reverb_level[magnitude];
}

double
get_chorus_depth (int magnitude) {
    return chorus_depth[magnitude];
}

double
get_chorus_nr (int magnitude) {
    return chorus_nr[magnitude];
}

double
get_chorus_level (int magnitude) {
    return chorus_level[magnitude];
}

void
set_gain_value (int channel, int value) {
    gain_value[channel] = value;
}

int
get_gain_value (int channel) {
    return gain_value[channel];
}

int
get_mod_buffer_value (int modulator, int channel) {
    switch (modulator)
    {
        case 1:
        return modulation_value[channel];
        case 10:
        return pan_value[channel];
        case 11:
        return expression_value[channel];
        case 66:
        return pitch_value[channel];
        case 71:
        return resonance_value[channel];
        case 74:
        return cut_off_value[channel];
        case 91:
        return reverb_value[channel];
        case 93:
        return chorus_value[channel];
    }
    return -1;
}

void
set_mod_buffer_value (int modulator, int channel, int value) {
    switch (modulator)
    {
        case 1:
        modulation_value[channel] = value;
        break;
        case 10:
        pan_value[channel] = value;
        break;
        case 11:
        expression_value[channel] = value;
        break;
        case 66:
        pitch_value[channel] = value;
        break;
        case 71:
        resonance_value[channel] = value;
        break;
        case 74:
        cut_off_value[channel] = value;
        break;
        case 91:
        reverb_value[channel] = value;
        break;
        case 93:
        chorus_value[channel] = value;
        break;
    }
}
