#include <fluidsynth.h>
#include <gtk/gtk.h>
#include "central_bus.h"

fluid_settings_t* settings;
fluid_synth_t* synth;
fluid_audio_driver_t* adriver;
fluid_player_t* player;

int looping = 0;
int loop_start_tick = 0;
int loop_end_tick = 0;
int measure_length = 0;

int start_s = 0;
int end_s = 0;

int start_temp = 0;
int end_temp = 0;

int fill_queue = 0;
int fill_in = 0;
int intro_playing = 0;
int sync_stop = 0;

int breaking = 0;


int ticks_since_measure = 0;

int changing_variation = 0;

int parse_midi_events (void *data, fluid_midi_event_t *event) {
    fluid_synth_t* synth = (fluid_synth_t*) data;
    int type = fluid_midi_event_get_type(event);
    int chan = fluid_midi_event_get_channel(event);
    int cont = fluid_midi_event_get_control(event);
    int value= fluid_midi_event_get_value (event);

    int gain;
    fluid_synth_get_cc (synth, 0, 74, &gain);

    // printf ("Type: %d, ", type);
    // printf ("Channel: %d, ", chan);
    // printf ("Control: %d, ", cont);
    // printf ("Value: %d\n", value);
    if (breaking == 1) {
        return 0;
    }
    return fluid_synth_handle_midi_event( data, event);
}

int parse_ticks (void* data, int ticks) {
    if (fill_queue == 1) {
        fill_queue = 0;
        fill_in = 1;
        int loop_end_temp = measure_length + loop_end_tick;
        int loop_start_temp = loop_end_tick + ((ticks - loop_start_tick) % measure_length);
        if (loop_start_temp < loop_end_temp) {
            return fluid_player_seek (player, loop_start_temp);
        }
    }
    //printf (">>> %d\n", (ticks - loop_start_tick) % measure_length);
    if (((ticks - loop_start_tick) % measure_length) <= 1) {
        changing_variation = 1;
        central_clock = 1;
        fill_queue = 0;
        fill_in = 0;
        central_style_section = start_s;
        if (loop_start_tick != loaded_style_time_stamps[start_s]) {
            loop_start_tick = loaded_style_time_stamps[start_s];
            loop_end_tick = loaded_style_time_stamps[end_s];
            return fluid_player_seek (player, loop_start_tick);
        }
    } else {
        changing_variation = 0;
    }

    if (changing_variation == 1) {
        central_measure++;
    }
    
    if (looping == 1) {
        if (ticks > loop_end_tick && fill_in == 0) {
            //printf("looping...%d -> %d\n", loop_start_tick, loop_end_tick);
            if (intro_playing == 1) {
                start_s = start_temp;
                end_s = end_temp;
                intro_playing = 0;
            } else if (sync_stop) {
                fluid_player_stop (player);
                start_s = start_temp;
                end_s = end_temp;
                looping = 0;
                intro_playing = 0;
                fill_in = 0;
                fill_queue = 0;
                sync_stop = 0;
                central_style_section = 0;
            }
            breaking = 0;
            return fluid_player_seek (player, loop_start_tick);
        }
    }

    return FLUID_OK;
}


void style_player_init (const gchar* loc, const gchar* mid_file) {
    int sfont_id;
    settings = new_fluid_settings();
    fluid_settings_setstr(settings, "audio.driver", "alsa");
    fluid_settings_setint(settings, "audio.periods", 16);
    fluid_settings_setint(settings, "audio.period-size", 86);
    fluid_settings_setint(settings, "audio.realtime-prio", 70);
    fluid_settings_setstr(settings, "synth.midi-bank-select", "gs");

    synth = new_fluid_synth(settings);

    player = new_fluid_player(synth);
    fluid_player_set_playback_callback(player, parse_midi_events, synth);
    fluid_player_set_tick_callback (player, parse_ticks, synth);
    adriver = new_fluid_audio_driver(settings, synth);

    if (fluid_is_soundfont(loc)) {
        fluid_synth_sfload(synth, loc, 1);
    }
    if (fluid_is_midifile(mid_file)) {
        fluid_player_add(player, mid_file);
    }
}

void style_player_destruct () {
    /* wait for playback termination */
    fluid_player_stop (player);
    fluid_player_join(player);
    /* cleanup */
    delete_fluid_audio_driver(adriver);
    delete_fluid_player(player);
    delete_fluid_synth(synth);
    delete_fluid_settings(settings);
}

void style_player_play_loop (int start, int end) {
    /* play the midi files, if any */
    measure_length = loaded_style_time_stamps[1];
    start_s = start;
    end_s = end;
    start_temp = start_s;
    end_temp = end_s;
    if (looping == 0) {
        loop_start_tick = loaded_style_time_stamps[start];
        loop_end_tick = loaded_style_time_stamps[end];
        printf("Queuing...%d -> %d\n", loop_start_tick, loop_end_tick);
    } else {
        if (loop_start_tick == loaded_style_time_stamps[start_s]) {
            if (fill_in == 0) {
                fill_queue = 1;
            }
            printf("Fill\n");
        }
        else {
            printf("Playing...%d -> %d\n", loop_start_tick, loop_end_tick);
        }

    }
    sync_stop = 0;
}

void style_player_play () {
    measure_length = loaded_style_time_stamps[1];
    if (looping == 0) {
        if (start_s == 0) {
            start_s = 3;
            end_s = 4;
            start_temp = start_s;
            end_temp = end_s;
        }
        loop_start_tick = loaded_style_time_stamps[start_s];
        loop_end_tick = loaded_style_time_stamps[end_s];
        fluid_player_seek (player, loop_start_tick);
        fluid_player_play(player);
        looping = 1;
    } else {
        if (fluid_player_get_status (player) == FLUID_PLAYER_PLAYING) {
            fluid_player_stop (player);
            looping = 0;
            intro_playing = 0;
            fill_in = 0;
            fill_queue = 0;
            central_style_section = 0;
        }
    }
    central_clock = 0;
    sync_stop = 0;
}

void style_player_queue_intro (int start, int end) {
    printf("Intro>>>\n");
    if (start_s == 0) {
        start_s = 3;
        end_s = 4;
    }
    start_temp = start_s;
    end_temp = end_s;
    start_s = start;
    end_s = end;
    intro_playing = 1;
}

void style_player_queue_ending (int start, int end) {
    printf("Ending>>>\n");
    start_temp = start_s;
    end_temp = end_s;
    start_s = start;
    end_s = end;
    sync_stop = 1;
}

void style_player_break () {
    breaking = 1;
}

void style_player_sync_stop () {
    sync_stop = 1;
}