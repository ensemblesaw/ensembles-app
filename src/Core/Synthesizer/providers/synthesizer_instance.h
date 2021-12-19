/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef SYNTHESIZER_INSTANCE_H
#define SYNTHESIZER_INSTANCE_H

#include <fluidsynth.h>
#include <stdlib.h>
#include <string.h>

/*
 * Where is the synthesizer instance
 * going to operate? What is it gonna do?
 */
enum UseCase
{
    RENDER,           // Whenever you are supposed to render audio
    UTILITY           // For automations and analysis and doesn't require rendering
};

/*
 * Returns a synthesizer instance for the given use case
 */
fluid_synth_t* get_synthesizer(enum UseCase use_case);

/*
 * Sets driver configuration of synthesizer instance;
 */
int set_driver_configuration(const char* driver_name, double buffer_length_multiplier);

// Effect Rack callback
typedef void
(*synthesizer_fx_callback)(float* input_l,
                        int input_l_length1,
                        float* input_r,
                        int input_r_lengthint1,
                        float** output_l,
                        int* output_l_length1,
                        float** output_r,
                        int* output_r_length1);

void set_fx_callback (synthesizer_fx_callback callback);
/*
 * Deletes the synthesizer when a use case
 * is no longer necessary
 */
void delete_synthesizer_instances();

#endif /* SYNTHESIZER_INSTANCE_H */

/*
 *  RENDER SYNTH CHANNEL UTILIZATION SCHEMATICS
 *
 *  LFO, Style, Song:
 *  0 - 15
 *
 *  Metronome:
 *  16
 *
 *  MIDI INPUT:
 *  Voice R1      - 17
 *  Voice R2      - 18
 *  Voice L       - 19
 *  CHORD-EP      - 20
 *  CHORD-Strings - 21
 *  CHORD-Bass    - 22
 *
 *  CHIMES:
 *  23
 *
 *  RECORDER:
 *  24 - 63
 */
