/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef SYNTHESIZER_INSTANCE_H
#define SYNTHESIZER_INSTANCE_H

#include <fluidsynth.h>

/*
 * Where is the synthesizer instance
 * going to operate? What is it gonna do
 */
enum UseCase {
    RENDER,           // Whenever you are supposed to render audio
    UTILITY           // For automations and analysis and doesn't require rendering
};

/*
 * Returns a synthesizer instance for the given use case
 */
fluid_synth_t* get_synthesizer(enum UseCase use_case);

/*
 * Deletes the synthesizer when a use case
 * is no longer necessary
 */
void delete_synthesizer(enum UseCase use_case);

#endif /* SYNTHESIZER_INSTANCE_H */
