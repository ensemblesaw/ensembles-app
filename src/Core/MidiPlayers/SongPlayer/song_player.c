/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "song_player.h"
#include "../../Synthesizer/synthesizer.h"

fluid_player_t* mp_player;

int note_watch_channel = 0;
int total_ticks = 0;
int current_ticks = 0;


gchar* midi_file_path;

int player_repeat;

// Note callback
typedef void
(*music_note_callback)(gint note, gint on);

static music_note_callback music_callback;

void
set_music_note_callback(music_note_callback callback)
{
    music_callback = callback;
}

int
mp_parse_midi_events(void *data, fluid_midi_event_t *event)
{
    int type = fluid_midi_event_get_type(event);
    int channel = fluid_midi_event_get_channel(event);
    int key = fluid_midi_event_get_key(event);

    if (music_callback != NULL && channel == note_watch_channel)
    {
        if (type == 144 || type == 128)
        {
            music_callback(key, type);
        }
    }
    fluid_midi_event_t* new_event = new_fluid_midi_event();

    fluid_midi_event_set_channel(new_event, channel);
    fluid_midi_event_set_control(new_event, fluid_midi_event_get_control (event));
    fluid_midi_event_set_pitch(new_event, fluid_midi_event_get_pitch (event));
    fluid_midi_event_set_program(new_event, fluid_midi_event_get_program (event));
    fluid_midi_event_set_value(new_event, fluid_midi_event_get_value (event));
    fluid_midi_event_set_key(new_event, key);
    fluid_midi_event_set_velocity(new_event,fluid_midi_event_get_velocity (event));
    fluid_midi_event_set_type(new_event, type);
    return handle_events_for_midi_players(new_event, 0);
}

int
mp_parse_ticks (void* data, int ticks)
{
    current_ticks = ticks;
    if (total_ticks < 10)
    {
        total_ticks = fluid_player_get_total_ticks(mp_player);
    }
    if (total_ticks > 10 && current_ticks + 10 > total_ticks)
    {
        if (player_repeat > 0)
        {
            current_ticks = 0;
            return fluid_player_seek(mp_player, 1);
        }
        else
        {
            fluid_player_stop(mp_player);
            current_ticks = 0;
            return fluid_player_seek(mp_player, 1);
        }
    }
    return FLUID_OK;
}

void
music_player_init()
{
    mp_player = new_fluid_player(get_synthesizer(UTILITY));
    fluid_player_set_playback_callback(mp_player, mp_parse_midi_events, get_synthesizer(UTILITY));
    fluid_player_set_tick_callback(mp_player, mp_parse_ticks, get_synthesizer(UTILITY));
}

int
music_player_load_file(gchar* path)
{
    midi_file_path = (char *)malloc(sizeof (char) * strlen(path));
    strcpy (midi_file_path, path);
    if (fluid_is_midifile(midi_file_path))
    {
        fluid_player_add(mp_player, midi_file_path);
        total_ticks = fluid_player_get_total_ticks(mp_player);
        return fluid_player_get_bpm(mp_player);
    }
    return -1;
}

void
music_player_play()
{
    synthesizer_halt_notes();
    fluid_player_play(mp_player);
}

void
music_player_pause ()
{
    fluid_player_stop(mp_player);
    synthesizer_halt_notes();
    fluid_synth_all_notes_off(get_synthesizer(UTILITY), -1);
    fluid_synth_all_sounds_off(get_synthesizer(UTILITY), -1);
}

void
music_player_seek(int seek_point)
{
    fluid_player_seek(mp_player, seek_point);
}

int
music_player_get_status()
{
    if (mp_player)
    {
        return fluid_player_get_status(mp_player);
    }
    return 0;
}

void
music_player_destruct()
{
    if (mp_player)
    {
        fluid_player_stop(mp_player);
        fluid_player_join(mp_player);
        delete_fluid_player(mp_player);
        mp_player = NULL;
    }
}
