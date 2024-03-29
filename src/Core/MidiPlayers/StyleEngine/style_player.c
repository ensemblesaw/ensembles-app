/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "style_player.h"

// None of this will be used to actual rendering //////////
fluid_player_t* player = NULL;
///////////////////////////////////////////////////////////

int loop_start_tick = 0;
int loop_end_tick = 0;
int measure_length = 0;
int time_resolution_limit = 1;

int start_s = 0;
int end_s = 0;

int start_temp = 0;
int end_temp = 0;

int fill_queue = 0;
int fill_in = 0;
int intro_playing = 0;
int sync_stop = 0;

int breaking = 0;

char* style_player_style_path;


int ticks_since_measure = 0;

int changing_variation = 0;
int changing_style = 0;

int32_t style_swap_thread_id = 0;

// Per channel chord change flags
int chord_change_queued = 0;

// Per channel note-on tracking flags
int channel_note_on_0 = -1;
int channel_note_on_1 = -1;
int channel_note_on_2 = -1;
int channel_note_on_3 = -1;
int channel_note_on_4 = -1;
int channel_note_on_5 = -1;
int channel_note_on_6 = -1;
int channel_note_on_7 = -1;
int channel_note_on_8 = -1;
int channel_note_on_11 = -1;
int channel_note_on_12 = -1;
int channel_note_on_13 = -1;
int channel_note_on_14 = -1;
int channel_note_on_15 = -1;

// Chord tracking flags
int chord_main = 0; // C
int chord_type = 0; // Major
int alt_channels_on = 0;

int style_original_chord_main = 0;

// Style start/stop callback
typedef void
(*style_player_change_state_callback)(gint state);

static style_player_change_state_callback state_change_callback;

void
set_style_change_callback (style_player_change_state_callback callback) {
    state_change_callback = callback;
}

// Style part change callback
typedef void
(*style_player_change_part_callback)(gint part);

static style_player_change_part_callback part_change_callback;

void
set_style_part_change_callback (style_player_change_part_callback callback) {
    part_change_callback = callback;
}

void
style_player_change_chord (int cd_main, int cd_type)
{
    if (cd_main != -6)
    {
        chord_main = cd_main;
        chord_type = cd_type;
        chord_change_queued = 1;
    }
    measure_length = get_loaded_style_time_stamps_by_index (1);
    if (get_central_style_sync_start () == 1)
    {
        set_central_style_sync_start (0);
        if (get_central_style_looping () == 0)
        {
            if (start_s == 0)
            {
                start_s = 3;
                end_s = 4;
                start_temp = start_s;
                end_temp = end_s;
            }
            loop_start_tick = get_loaded_style_time_stamps_by_index (start_s);
            loop_end_tick = get_loaded_style_time_stamps_by_index (end_s);
            fluid_player_seek (player, loop_start_tick);
            printf ("Start central_style_looping\n");
            fluid_player_play(player);
            set_central_style_looping (1);
            if (state_change_callback != NULL)
            {
                state_change_callback (0);
            }
        }
        set_central_clock (0);
        sync_stop = 0;
    }
    //printf("%d\n", chord_main);
}

int
get_random_in_range(int lower_limit, int upper_limit)
{
    srand(time(0));
    return (rand() % (upper_limit - lower_limit + 1)) + lower_limit;
}

int
get_chord_modified_key (int key)
{
    // If style scale is Major
    if (get_central_style_original_chord_type () == 0)
    {
        switch (chord_type)
        {
            // If detected chord is Major
            case 0:
                return key + chord_main;
            // If detected chord is minor
            case 1:
                if (!alt_channels_on && ((key - 4) % 12 == 0 || (key - 9) % 12 == 0 || (key - 11) % 12 == 0))
                {
                    return (key + chord_main - 1);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is diminished
            case 2:
                if ((key - 4) % 12 == 0 || (key - 7) % 12 == 0)
                {
                    return (key + chord_main - 1);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is sus2
            case 3:
                if ((key - 4) % 12 == 0)
                {
                    return (key + chord_main - 2);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is sus4
            case 4:
                if ((key - 4) % 12 == 0)
                {
                    return (key + chord_main + 1);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is augmented
            case 5:
                if ((key - 2) % 12 == 0 || (key - 7) % 12 == 0)
                {
                    return (key + chord_main + 1);
                }
                else if ((key - 5) % 12 == 0 || (key - 9) % 12 == 0)
                {
                    return (key + chord_main - 1);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is Sixth
            case 6:
                if ((key - 4) % 12 == 0)
                {
                    if (get_random_in_range(0, 3) > 2)
                    {
                        return (key + chord_main);
                    }
                    return (key + chord_main + 5);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is Seventh
            case 7:
                if ((key - 4) % 12 == 0)
                {
                    if (get_random_in_range(0, 3) > 2)
                    {
                        return (key + chord_main);
                    }
                    return (key + chord_main + 6);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is Major Seventh
            case 8:
                if ((key - 4) % 12 == 0)
                {
                    if (get_random_in_range(0, 3) > 2)
                    {
                        return (key + chord_main);
                    }
                    return (key + chord_main - 5);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is minor Seventh
            case 9:
                if ((key - 4) % 12 == 0)
                {
                    if (get_random_in_range(0, 1))
                    {
                        return (key + chord_main + 6);
                    }
                    return (key + chord_main - 1);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is add9
            case 10:
                if ((key - 4) % 12 == 0)
                {
                    if (get_random_in_range(0, 3) > 2)
                    {
                        return (key + chord_main);
                    }
                    return (key + chord_main - 2);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is Ninth
            case 11:
                if ((key - 4) % 12 == 0)
                {
                    if (get_random_in_range(0, 1))
                    {
                        return (key + chord_main - 2);
                    }
                    return (key + chord_main);
                }
                else if ((key - 7) % 12 == 0)
                {
                    if (get_random_in_range(0, 1))
                    {
                        return (key + chord_main + 3);
                    }
                    return (key + chord_main);
                }
                else
                {
                    return (key + chord_main);
                }
        }
    }
    // If style scale is minor
    else if (get_central_style_original_chord_type () == 1)
    {
        switch (chord_type)
        {
            // If detected chord is minor
            case 1:
                return (key + chord_main);
            // If detected chord is Major
            case 0:
                if (!alt_channels_on && ((key - 3) % 12 == 0 || (key - 8) % 12 == 0 || (key - 10) % 12 == 0))
                {
                    return (key + chord_main + 1);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is diminished
            case 2:
                if ((key - 7) % 12 == 0)
                {
                    return (key + chord_main - 1);
                }
                else if ((key - 8) % 12 == 0 || (key - 10) % 12 == 0)
                {
                    return (key + chord_main + 1);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is sus2
            case 3:
                if ((key - 3) % 12 == 0)
                {
                    return (key + chord_main - 1);
                }
                else if ((key - 8) % 12 == 0 || (key - 10) % 12 == 0)
                {
                    return (key + chord_main + 1);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is sus4
            case 4:
                if ((key - 3) % 12 == 0)
                {
                    return (key + chord_main + 2);
                }
                else if ((key - 8) % 12 == 0 || (key - 10) % 12 == 0)
                {
                    return (key + chord_main + 1);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is augmented
            case 5:
                if ((key - 7) % 12 == 0)
                {
                    return (key + chord_main - 1);
                }
                else if ((key - 8) % 12 == 0 || (key - 10) % 12 == 0)
                {
                    return (key + chord_main + 1);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is Sixth
            case 6:
                if ((key - 3) % 12 == 0)
                {
                    if (get_random_in_range(0, 3) > 2)
                    {
                        return (key + chord_main + 1);
                    }
                    return (key + chord_main + 6);
                }
                else if ((key - 8) % 12 == 0 || (key - 10) % 12 == 0)
                {
                    return (key + chord_main + 1);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is Seventh
            case 7:
                if ((key - 3) % 12 == 0)
                {
                    if (get_random_in_range(0, 3) > 2)
                    {
                        return (key + chord_main + 1);
                    }
                    return (key + chord_main + 7);
                }
                else if ((key - 8) % 12 == 0)
                {
                    return (key + chord_main + 1);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is Major Seventh
            case 8:
                if ((key - 3) % 12 == 0)
                {
                    if (get_random_in_range(0, 3) > 2)
                    {
                        return (key + chord_main + 1);
                    }
                    return (key + chord_main + 8);
                }
                else if ((key - 8) % 12 == 0 || (key - 10) % 12 == 0)
                {
                    return (key + chord_main + 1);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is minor Seventh
            case 9:
                if ((key - 3) % 12 == 0)
                {
                    if (get_random_in_range(0, 3) > 2)
                    {
                        return (key + chord_main);
                    }
                    return (key + chord_main + 7);
                }
                else if ((key - 8) % 12 == 0)
                {
                    return (key + chord_main + 1);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is add9
            case 10:
                if ((key - 3) % 12 == 0)
                {
                    if (get_random_in_range(0, 3) > 2)
                    {
                        return (key + chord_main + 1);
                    }
                    return (key + chord_main - 2);
                }
                else if ((key - 8) % 12 == 0 || (key - 10) % 12 == 0)
                {
                    return (key + chord_main + 1);
                }
                else
                {
                    return (key + chord_main);
                }
            // If detected chord is Ninth
            case 11:
                if ((key - 3) % 12 == 0)
                {
                    if (get_random_in_range(0, 1))
                    {
                        return (key + chord_main - 1);
                    }
                    return (key + chord_main + 1);
                }
                else if ((key - 7) % 12 == 0)
                {
                    if (get_random_in_range(0, 1))
                    {
                        return (key + chord_main + 3);
                    }
                    return (key + chord_main);
                }
                else if ((key - 8) % 12 == 0)
                {
                    return (key + chord_main + 1);
                }
                else
                {
                    return (key + chord_main);
                }
        }
    }
    return 0;
}

int
parse_midi_events (void *data, fluid_midi_event_t *event)
{

    fluid_midi_event_t* new_event = new_fluid_midi_event ();

    int type = fluid_midi_event_get_type (event);
    int channel = fluid_midi_event_get_channel (event);
    int control = fluid_midi_event_get_control (event);
    int key = fluid_midi_event_get_key (event);
    int value = fluid_midi_event_get_value (event);
    int velocity = fluid_midi_event_get_velocity (event);

    if (control == 120)
    {
        return FLUID_OK;
    }
    else if (channel == 11 && control == 82)
    {
        alt_channels_on = value > 63;
    }

    if (type == 144 && alt_channels_on)
    {
        if (get_central_style_original_chord_type() != chord_type)
        {
            if (channel == 0 ||
                channel == 2 ||
                channel == 3 ||
                channel == 4 ||
                channel == 6 ||
                channel == 7)
            {
                return FLUID_OK;
            }
        }
        else
        {
            if (channel == 11 ||
                channel == 12 ||
                channel == 13 ||
                channel == 14 ||
                channel == 15)
            {
                return FLUID_OK;
            }
        }
    }

    fluid_midi_event_set_channel (new_event, channel);
    fluid_midi_event_set_control (new_event, control);
    fluid_midi_event_set_pitch (new_event, fluid_midi_event_get_pitch (event));
    fluid_midi_event_set_program (new_event, fluid_midi_event_get_program (event));
    fluid_midi_event_set_value (new_event, value);
    fluid_midi_event_set_velocity (new_event,velocity);
    fluid_midi_event_set_type (new_event, type);

    switch (channel)
    {
        case 0:
        if (type == 144) channel_note_on_0 = key | (velocity << 16); else if (type == 128) channel_note_on_0 = -1;
        break;
        case 1:
        if (type == 144) channel_note_on_1 = key | (velocity << 16); else if (type == 128) channel_note_on_1 = -1;
        break;
        case 2:
        if (type == 144) channel_note_on_2 = key | (velocity << 16); else if (type == 128) channel_note_on_2 = -1;
        break;
        case 3:
        if (type == 144) channel_note_on_3 = key | (velocity << 16); else if (type == 128) channel_note_on_3 = -1;
        break;
        case 4:
        if (type == 144) channel_note_on_4 = key | (velocity << 16); else if (type == 128) channel_note_on_4 = -1;
        break;
        case 5:
        if (type == 144) channel_note_on_5 = key | (velocity << 16); else if (type == 128) channel_note_on_5 = -1;
        break;
        case 6:
        if (type == 144) channel_note_on_6 = key | (velocity << 16); else if (type == 128) channel_note_on_6 = -1;
        break;
        case 7:
        if (type == 144) channel_note_on_7 = key | (velocity << 16); else if (type == 128) channel_note_on_7 = -1;
        break;
        case 8:
        if (type == 144) channel_note_on_8 = key | (velocity << 16); else if (type == 128) channel_note_on_8 = -1;
        break;
        case 11:
        if (type == 144) channel_note_on_11 = key | (velocity << 16); else if (type == 128) channel_note_on_11 = -1;
        break;
        case 12:
        if (type == 144) channel_note_on_12 = key | (velocity << 16); else if (type == 128) channel_note_on_12 = -1;
        break;
        case 13:
        if (type == 144) channel_note_on_13 = key | (velocity << 16); else if (type == 128) channel_note_on_13 = -1;
        break;
        case 14:
        if (type == 144) channel_note_on_14 = key | (velocity << 16); else if (type == 128) channel_note_on_14 = -1;
        break;
        case 15:
        if (type == 144) channel_note_on_15 = key | (velocity << 16); else if (type == 128) channel_note_on_15 = -1;
        break;
    }

    if (channel != 9 && channel != 10 && (type == 144 || type == 128))
    {
        fluid_midi_event_set_key (new_event, get_chord_modified_key (key));
    }
    else
    {
        fluid_midi_event_set_key (new_event, key);
    }

    // Send data to synth
    if (breaking == 0)
    {
        handle_events_for_midi_players (new_event, 1);
    }
    return 0;
}

void
resend_key (int value, int channel)
{
    fluid_midi_event_t* new_event = new_fluid_midi_event();
    fluid_midi_event_set_channel(new_event, channel);
    fluid_midi_event_set_type(new_event, 144);
    fluid_midi_event_set_key(new_event, get_chord_modified_key (value & 0xFFFF));
    fluid_midi_event_set_velocity(new_event, (value >> 16) & 0xFFFF);
    handle_events_for_midi_players(new_event, 1);
}

void
style_player_halt_continuous_notes ()
{
    channel_note_on_0 = -1;
    channel_note_on_1 = -1;
    channel_note_on_2 = -1;
    channel_note_on_3 = -1;
    channel_note_on_4 = -1;
    channel_note_on_5 = -1;
    channel_note_on_6 = -1;
    channel_note_on_7 = -1;
    channel_note_on_8 = -1;
    channel_note_on_11 = -1;
    channel_note_on_12 = -1;
    channel_note_on_13 = -1;
    channel_note_on_14 = -1;
    channel_note_on_15 = -1;
    synthesizer_halt_notes();
}

int
parse_ticks (void* data, int ticks)
{

    // Continue notes after a chord change
    if (chord_change_queued == 1 && breaking == 0)
    {
        chord_change_queued = 0;
        printf ("chord -> %d\n", chord_main);
        synthesizer_halt_notes ();
        if (channel_note_on_0 >= 0) resend_key (channel_note_on_0, 0);
        if (channel_note_on_1 >= 0) resend_key (channel_note_on_1, 1);
        if (channel_note_on_2 >= 0) resend_key (channel_note_on_2, 2);
        if (channel_note_on_3 >= 0) resend_key (channel_note_on_3, 3);
        if (channel_note_on_4 >= 0) resend_key (channel_note_on_4, 4);
        if (channel_note_on_5 >= 0) resend_key (channel_note_on_5, 5);
        if (channel_note_on_6 >= 0) resend_key (channel_note_on_6, 6);
        if (channel_note_on_7 >= 0) resend_key (channel_note_on_7, 7);
        if (channel_note_on_8 >= 0) resend_key (channel_note_on_8, 8);
        if (channel_note_on_11 >= 0) resend_key (channel_note_on_11, 11);
        if (channel_note_on_12 >= 0) resend_key (channel_note_on_12, 12);
        if (channel_note_on_13 >= 0) resend_key (channel_note_on_13, 13);
        if (channel_note_on_14 >= 0) resend_key (channel_note_on_14, 14);
        if (channel_note_on_15 >= 0) resend_key (channel_note_on_15, 15);
    }
    if (fill_queue == 1)
    {
        fill_queue = 0;
        fill_in = 1;
        int loop_end_temp = measure_length + loop_end_tick;
        int loop_start_temp = loop_end_tick + ((ticks - loop_start_tick) % measure_length);
        if (loop_start_temp < loop_end_temp)
        {
            return fluid_player_seek (player, loop_start_temp - 2);
        }
    }
    //printf (">>> %d\n", (ticks - loop_start_tick) % measure_length);
    if (get_central_clock () == 0 && ((ticks - loop_start_tick) % measure_length) <= time_resolution_limit)
    {
        set_central_clock (1);
        breaking = 0;
        fill_queue = 0;
        fill_in = 0;
        part_change_callback (start_s);
        if (loop_start_tick != get_loaded_style_time_stamps_by_index (start_s) ||
            loop_end_tick != get_loaded_style_time_stamps_by_index (end_s))
        {
            loop_start_tick = get_loaded_style_time_stamps_by_index (start_s);
            loop_end_tick = get_loaded_style_time_stamps_by_index (end_s);
            style_player_halt_continuous_notes ();
            return fluid_player_seek (player, loop_start_tick - 2);
        }
        if (get_central_style_looping () == 1)
        {
            // printf ("%d >> %d", start_s, end_s);
            // printf ("Sync stop: %d %d %d\n", sync_stop, ticks, loop_end_tick);
            if (ticks >= loop_end_tick && fill_in == 0)
            {
                // printf ("Measure complete\n");
                part_change_callback (start_s);
                if (intro_playing == 1)
                {
                    start_s = start_temp;
                    end_s = end_temp;
                    intro_playing = 0;
                    loop_start_tick = get_loaded_style_time_stamps_by_index(start_s);
                    loop_end_tick = get_loaded_style_time_stamps_by_index(end_s);
                    style_player_halt_continuous_notes ();
                    part_change_callback (start_s);
                    return fluid_player_seek (player, loop_start_tick - 2);
                }
                else if (sync_stop)
                {
                    fluid_player_stop (player);
                    set_central_halt (1);
                    if (start_temp == 11 || start_temp == 13)
                    {
                        start_s = 3;
                        end_s = 4;
                    }
                    else
                    {
                        start_s = start_temp;
                        end_s = end_temp;
                    }
                    set_central_style_looping (0);
                    intro_playing = 0;
                    fill_in = 0;
                    fill_queue = 0;
                    sync_stop = 0;
                    part_change_callback (0);
                    set_central_measure (0);
                    style_player_halt_continuous_notes ();
                    if (state_change_callback != NULL)
                    {
                        state_change_callback (1);
                    }
                    printf ("Sync Stopped\n");
                }
                alt_channels_on = 0;
                style_player_halt_continuous_notes ();
                return fluid_player_seek (player, loop_start_tick - 2);
            }
        }
    }

    return FLUID_OK;
}


void
style_player_init ()
{
    set_central_style_looping (0);
}

void
style_player_sync_stop ()
{
    sync_stop = 1;
}

void
style_player_sync_start ()
{
    set_central_style_sync_start (1);
}

void
queue_style_file_change (int custom_tempo)
{
    alt_channels_on = 0;
    printf("Changing...to %s\n", style_player_style_path);
    if (player != NULL)
    {
        fluid_player_stop (player);
        fluid_player_join(player);
        delete_fluid_player(player);
        player = NULL;
    }
    printf ("Making player\n");
    player = new_fluid_player(get_synthesizer(UTILITY));
    fluid_player_set_playback_callback(player, parse_midi_events, get_synthesizer(UTILITY));
    fluid_player_set_tick_callback (player, parse_ticks, get_synthesizer(UTILITY));
    if (fluid_is_midifile(style_player_style_path))
    {
        fluid_player_add(player, style_player_style_path);
    }
    if (custom_tempo >= 40)
    {
        fluid_player_set_tempo(player, FLUID_PLAYER_TEMPO_EXTERNAL_BPM, (double)custom_tempo);
        set_central_loaded_tempo (custom_tempo);
        if (custom_tempo < 130)
        {
            time_resolution_limit = 1;
        }
        else if (custom_tempo < 182)
        {
            time_resolution_limit = 2;
        }
        else
        {
            time_resolution_limit = 3;
        }
    }
    loop_start_tick = get_loaded_style_time_stamps_by_index(start_s);
    loop_end_tick = get_loaded_style_time_stamps_by_index(end_s);
    set_central_clock (0);
    style_player_halt_continuous_notes();
}

void
style_player_add_style_file(const gchar* mid_file, int custom_tempo)
{
    int c_tempo = (get_central_style_looping () > 0) ?
                    fluid_player_get_bpm (player):
                    custom_tempo;
    if (style_player_style_path) {
        free(style_player_style_path);
    }
    style_player_style_path = (char *)malloc(sizeof (char) * strlen(mid_file));
    strcpy (style_player_style_path, mid_file);
    style_analyser_analyze (style_player_style_path);
    queue_style_file_change (c_tempo);
}

void
style_player_set_tempo(int tempo_bpm)
{
    if (player)
    {
        fluid_player_set_tempo (player, FLUID_PLAYER_TEMPO_EXTERNAL_BPM, (double)tempo_bpm);
    }
    set_central_loaded_tempo (tempo_bpm);

    if (tempo_bpm < 130)
    {
        time_resolution_limit = 1;
    }
    else if (tempo_bpm < 182)
    {
        time_resolution_limit = 2;
    }
    else
    {
        time_resolution_limit = 3;
    }
}

void
style_player_reload_style () {
    int previous_tempo = fluid_player_get_bpm (player);
    set_central_loaded_tempo (previous_tempo);
    style_player_add_style_file (style_player_style_path, previous_tempo);
    set_central_loaded_tempo (previous_tempo);
}

void
style_player_destruct () {
    /* cleanup */
    fluid_synth_all_sounds_off (get_synthesizer(UTILITY), -1);
    if (player != NULL) {
        /* wait for playback termination */
        fluid_player_stop (player);
        fluid_player_join(player);
        delete_fluid_player(player);
    }
    if (style_player_style_path) {
        free(style_player_style_path);
    }
}

void
style_player_play_loop (int start, int end) {
    /* play the midi files, if any */
    measure_length = get_loaded_style_time_stamps_by_index(1);
    start_s = start;
    end_s = end;
    start_temp = start_s;
    end_temp = end_s;
    if (get_central_style_looping () == 0) {
        loop_start_tick = get_loaded_style_time_stamps_by_index(start);
        loop_end_tick = get_loaded_style_time_stamps_by_index(end);
        printf("Queuing...%d -> %d\n", loop_start_tick, loop_end_tick);
    } else {
        if (loop_start_tick == get_loaded_style_time_stamps_by_index(start_s)) {
            if (fill_in == 0) {
                fill_queue = 1;
            }
        }
        else {
            printf("Playing...%d -> %d\n", loop_start_tick, loop_end_tick);
        }

    }
    sync_stop = 0;
}

void
style_player_toggle_play () {
    measure_length = get_loaded_style_time_stamps_by_index(1);
    if (get_central_style_looping () == 0) {
        if (start_s == 0) {
            start_s = 3;
            end_s = 4;
            start_temp = start_s;
            end_temp = end_s;
        }
        loop_start_tick = get_loaded_style_time_stamps_by_index(start_s);
        loop_end_tick = get_loaded_style_time_stamps_by_index(end_s);
        fluid_player_seek (player, loop_start_tick);
        printf ("Start central_style_looping\n");
        fluid_player_play(player);
        set_central_style_looping (1);
        if (state_change_callback != NULL) {
            state_change_callback (0);
        }
        if (start_s == 11 || start_s == 13) {
            sync_stop = 1;
            start_temp = 3;
            end_temp = 4;
        } else {
            sync_stop = 0;
        }
    } else {
        if (fluid_player_get_status (player) == FLUID_PLAYER_PLAYING) {
            printf ("Stop central_style_looping\n");
            fluid_player_stop (player);
            set_central_halt (1);
            set_central_style_looping (0);
            intro_playing = 0;
            fill_in = 0;
            fill_queue = 0;
            part_change_callback (0);
            set_central_measure (0);
            style_player_halt_continuous_notes ();
            if (state_change_callback != NULL) {
                state_change_callback (1);
            }
        }
        sync_stop = 0;
    }
    set_central_clock (0);
}

void
style_player_play () {
    measure_length = get_loaded_style_time_stamps_by_index(1);
    if (get_central_style_looping () == 0) {
        if (start_s == 0) {
            start_s = 3;
            end_s = 4;
            start_temp = start_s;
            end_temp = end_s;
        }
        loop_start_tick = get_loaded_style_time_stamps_by_index(start_s);
        loop_end_tick = get_loaded_style_time_stamps_by_index(end_s);
        fluid_player_seek (player, loop_start_tick);
        printf ("Start central_style_looping\n");
        fluid_player_play(player);
        set_central_style_looping (1);
    }
    set_central_clock (0);
    if (start_s == 11 || start_s == 13) {
        sync_stop = 1;
        start_temp = 3;
        end_temp = 4;
    } else {
        sync_stop = 0;
    }
    if (state_change_callback != NULL) {
        state_change_callback (0);
    }
}

void
style_player_stop () {
    if (fluid_player_get_status (player) == FLUID_PLAYER_PLAYING) {
        printf ("Stop central_style_looping\n");
        fluid_player_stop (player);
        set_central_halt (1);
        set_central_style_looping (0);
        intro_playing = 0;
        fill_in = 0;
        fill_queue = 0;
        part_change_callback (0);
        set_central_measure (0);
        style_player_halt_continuous_notes ();
        set_central_clock (0);
        sync_stop = 0;
    }
    if (state_change_callback != NULL) {
        state_change_callback (1);
    }
}

void
style_player_queue_intro (int start, int end) {
    printf("Intro>>>\n");
    if (start_s == 0 || start_s == 1 || start_s == 2) {
        start_s = 3;
        end_s = 4;
    }
    start_temp = start_s;
    end_temp = end_s;
    start_s = start;
    end_s = end;
    intro_playing = 1;
}

void
style_player_queue_ending (int start, int end) {
    printf("Ending>>>\n");
    start_temp = start_s;
    end_temp = end_s;
    start_s = start;
    end_s = end;
    sync_stop = 1;
}

void
style_player_break () {
    breaking = 1;
    synthesizer_halt_notes ();
}
