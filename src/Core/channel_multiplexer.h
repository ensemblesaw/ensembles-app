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

#ifndef CHANNEL_MULTIPLEXER_H_
#define CHANNEL_MULTIPLEXER_H_

#include <fluidsynth.h>
#include <glib-object.h>

#include "effect_rack.h"

#ifndef SYNTH_COUNT
    #define SYNTH_COUNT 16
#endif

G_BEGIN_DECLS

struct _ChannelMultiplexer
{
  /*< private >*/
  fluid_settings_t* settings;
  void *unused;
};

/**
 * ChannelMultiplexer:
 *
 * Use the accessor functions below.
 */
#define CHANNEL_MULTIPLEXER_TYPE (channel_multiplexer_get_type ())
G_DECLARE_FINAL_TYPE (ChannelMultiplexer, channel_multiplexer, CHANNEL_MULTIPLEX, MULTIPLEX, GObject)

ChannelMultiplexer channel_multiplexer_new (GObject *object, fluid_settings_t* settings);

void channel_multiplexer_multiplex (fluid_midi_event_t* event, int note_on, struct fx_data_t effects);

G_END_DECLS

#endif /* CHANNEL_MULTIPLEXER_H_ */