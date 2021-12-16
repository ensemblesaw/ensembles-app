/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


#ifndef SYNTHESIZER_H
#define SYNTHESIZER_H

#include <fluidsynth.h>

#include "central_bus.h"
#include "providers/synthesizer_settings.h"
#include "providers/synthesizer_instance.h"
#include "../Utils/chord_finder.h"

/** This function is used to receive midi events from style_player
 */
int handle_events_for_styles (fluid_midi_event_t *event);

void synthesizer_send_notes_metronome (int key, int on);

/** This function is used to stop all synthesizer sounds for styles
 * except channel 10 i.e. drums
 */
void synthesizer_halt_notes ();

#endif /* SYNTHESIZER_H */
