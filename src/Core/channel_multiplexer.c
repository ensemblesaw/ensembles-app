/*
 * Copyright © 2020 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * Licensed under the GNU General Public License Version 3
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "channel_multiplexer.h"

fluid_synth_t *synth_set[SYNTH_COUNT];

fluid_audio_driver_t *adriver[SYNTH_COUNT];

struct fx_data_t fx_data[];

void multiplexer_init (fluid_settings_t* settings) {
    int i;
    for (i = 0; i < SYNTH_COUNT; i++) {
        synth_set[i] = new_fluid_synth(settings);

        fx_data[i].synth = synth_set[i];
        fx_data[i].gain = 127;
        adriver[i] = new_fluid_audio_driver2(settings, effect_rack, (void *) &fx_data);
    }
}

void 
channel_multiplexer_multiplex (fluid_midi_event_t* event, int note_on, struct fx_data_t effects)
{
    int channel = fluid_midi_event_get_channel(event);
    redirect_event_to_synth (event, note_on, channel, effects);
}

void 
redirect_event_to_synth (fluid_midi_event_t* event, int note_on, int channel, struct fx_data_t effects)
{
    int note = fluid_event_get_key (event);
    int velocity = fluid_event_get_velocity (event);

    // Apply effect data
    fx_data[channel] = effects;

    if (note_on > 0) {
        fluid_synth_noteon (synth_set [channel], channel, note, velocity);
    } else {
        fluid_synth_noteoff (synth_set[channel], channel, note);
    }
}

/**
 * channel_multiplexer_new:
 * @parent: a parent #GObject
 *
 * Create a new #ChannelMultiplexer, associated with the @parent widget.
 *
 * Returns: a new #ChannelMultiplexer
 */
ChannelMultiplexer *
cheese_flash_new (GObject *parent, fluid_settings_t *settings)
{
    multiplexer_init (settings);
    return g_object_new (CHANNEL_MULTIPLEXER_TYPE, "settings", settings, "parent", parent);
}
