/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


#ifndef SYNTHESIZER_H
#define SYNTHESIZER_H

#include <fluidsynth.h>

#include "../ChoppingBlock/central_bus.h"
#include "providers/synthesizer_settings.h"
#include "providers/synthesizer_instance.h"
#include "../Utils/chord_finder.h"

/** This function is used to receive midi events from style_player
 */
int handle_events_for_midi_players(fluid_midi_event_t *event, int _is_style_player);

/** This function is used to receive events exclusively for metronome
 */
void synthesizer_send_notes_to_metronome(int key, int on);

/** This function is used to stop all synthesizer sounds for styles
 * except channel 10 i.e. drums
 */
void synthesizer_halt_notes();

/** Event callback
 */
typedef void
(*synthesizer_note_event_callback)(int channel,
                                   int key,
                                   int velocity,
                                   int on,
                                   int chord_main,
                                   int chord_type);

void synthesizer_set_event_callback (synthesizer_note_event_callback callback);

#endif /* SYNTHESIZER_H */
