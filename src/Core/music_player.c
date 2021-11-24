/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <fluidsynth.h>
#include <gtk/gtk.h>
#include <glib.h>
#include <string.h>

#include "driver_settings_provider.h"

// These are actually used to render audio
fluid_settings_t* mp_settings;
fluid_synth_t* mp_synth;
fluid_audio_driver_t* mp_adriver;
fluid_player_t* mp_player;

int note_watch_channel = 0;
int total_ticks = 0;
int current_ticks = 0;


gchar* midi_file_path;

int player_repeat;

int
mp_parse_midi_events (void *data, fluid_midi_event_t *event) {
    return fluid_synth_handle_midi_event (mp_synth, event);
}

int
mp_parse_ticks (void* data, int ticks) {
    current_ticks = ticks;
    if (total_ticks < 10) {
        total_ticks = fluid_player_get_total_ticks (mp_player);

        printf ("total_ticks = %d\n", total_ticks);
    }
    if (total_ticks > 10 && current_ticks + 10 > total_ticks) {
        if (player_repeat > 0) {
            current_ticks = 0;
            return fluid_player_seek (mp_player, 1);
        } else {
            fluid_player_stop (mp_player);
            current_ticks = 0;
            return fluid_player_seek (mp_player, 1);
        }
    }
    return FLUID_OK;
}

void
music_player_init (const gchar* sf_loc) {
    mp_settings = get_settings(MIDI_SONG_PLAYER);
    // fluid_settings_setstr(mp_settings, "audio.driver", "pulseaudio");
    // fluid_settings_setint(mp_settings, "audio.periods", 16);
    // fluid_settings_setint(mp_settings, "audio.period-size", 4096);
    // fluid_settings_setint(mp_settings, "audio.realtime-prio", 40);
    // fluid_settings_setnum(mp_settings, "synth.gain", 1.0);
    mp_synth = new_fluid_synth(mp_settings);
    mp_adriver = new_fluid_audio_driver(mp_settings, mp_synth);

    if (fluid_is_soundfont(sf_loc)) {
        fluid_synth_sfload(mp_synth, sf_loc, 1);
    }
    mp_player = new_fluid_player(mp_synth);
    fluid_player_set_playback_callback(mp_player, mp_parse_midi_events, mp_synth);
    fluid_player_set_tick_callback (mp_player, mp_parse_ticks, mp_synth);
}

int
music_player_load_file (gchar* path) {
    midi_file_path = (char *)malloc(sizeof (char) * strlen (path));
    strcpy (midi_file_path, path);
    if (fluid_is_midifile (midi_file_path)) {
        fluid_player_add (mp_player, midi_file_path);
        total_ticks = fluid_player_get_total_ticks (mp_player);
        return fluid_player_get_bpm (mp_player);
    }
    return -1;
}

void
music_player_play () {
    fluid_player_play (mp_player);
}

void
music_player_pause () {
    fluid_player_stop (mp_player);
    fluid_synth_all_notes_off (mp_synth, -1);
    fluid_synth_all_sounds_off (mp_synth, -1);
}

void
music_player_seek (int seek_point) {
    fluid_player_seek (mp_player, seek_point);
}

int
music_player_get_status () {
    if (mp_player) {
        return fluid_player_get_status (mp_player);
    }
    return 0;
}

void
music_player_destruct () {
    if (mp_player) {
        fluid_player_stop (mp_player);
        fluid_player_join (mp_player);
        delete_fluid_player(mp_player);
        mp_player = NULL;
    }
    if (mp_adriver) {
        delete_fluid_audio_driver(mp_adriver);
        mp_adriver = NULL;
    }
    if (mp_synth) {
        fluid_synth_all_sounds_off (mp_synth, -1);
        delete_fluid_synth(mp_synth);
        mp_synth = NULL;
    }
    if (mp_settings) {
        delete_fluid_settings(mp_settings);
        mp_settings = NULL;
    }
}
