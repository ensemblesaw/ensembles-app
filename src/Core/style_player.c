#include <fluidsynth.h>
#include <gtk/gtk.h>
#include "central_bus.h"

// None of this will be used to actual rendering //////////
fluid_settings_t* settings;
fluid_synth_t* synth;
fluid_audio_driver_t* adriver;
fluid_player_t* player;
///////////////////////////////////////////////////////////

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

pthread_t style_swap_thread_id = 0;


int chord_main = 2; // C

int
parse_midi_events (void *data, fluid_midi_event_t *event) {

    fluid_midi_event_t* new_event = new_fluid_midi_event ();

    fluid_midi_event_set_channel (new_event, fluid_midi_event_get_channel (event));
    fluid_midi_event_set_control (new_event, fluid_midi_event_get_control (event));
    fluid_midi_event_set_pitch (new_event, fluid_midi_event_get_pitch (event));
    fluid_midi_event_set_program (new_event, fluid_midi_event_get_program (event));
    fluid_midi_event_set_value (new_event, fluid_midi_event_get_value (event));
    fluid_midi_event_set_velocity (new_event, fluid_midi_event_get_velocity (event));
    fluid_midi_event_set_type (new_event, fluid_midi_event_get_type (event));

    int type = fluid_midi_event_get_type (new_event);
    int channel = fluid_midi_event_get_channel (new_event);
    int key = fluid_midi_event_get_key (event);
    if (channel != 9) {
        if (type == 144 || type == 128) {
            fluid_midi_event_set_key (new_event, key + chord_main);
        }
    }
    else {
        fluid_midi_event_set_key (new_event, key);
    }
    
    

    // Send data to synth
    handle_events_for_styles (new_event);
    return 0;
}

int
parse_ticks (void* data, int ticks) {
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
    if (central_clock == 0 && ((ticks - loop_start_tick) % measure_length) <= 1) {
        central_clock = 1;
        fill_queue = 0;
        fill_in = 0;
        central_style_section = start_s;
        if (loop_start_tick != loaded_style_time_stamps[start_s]) {
            loop_start_tick = loaded_style_time_stamps[start_s];
            loop_end_tick = loaded_style_time_stamps[end_s];
            synthesizer_halt_notes ();
            return fluid_player_seek (player, loop_start_tick);
        }
        if (looping == 1) {
            if (ticks >= loop_end_tick && fill_in == 0) {
                central_style_section = start_s;
                if (intro_playing == 1) {
                    start_s = start_temp;
                    end_s = end_temp;
                    intro_playing = 0;
                    loop_start_tick = loaded_style_time_stamps[start_s];
                    loop_end_tick = loaded_style_time_stamps[end_s];
                    synthesizer_halt_notes ();
                    central_style_section = start_s;
                    return fluid_player_seek (player, loop_start_tick);
                } else if (sync_stop) {
                    fluid_player_stop (player);
                    central_halt = 1;
                    start_s = start_temp;
                    end_s = end_temp;
                    looping = 0;
                    intro_playing = 0;
                    fill_in = 0;
                    fill_queue = 0;
                    sync_stop = 0;
                    central_style_section = 0;
                    central_measure = 0;
                    synthesizer_halt_notes ();
                }
                breaking = 0;
                synthesizer_halt_notes ();
                return fluid_player_seek (player, loop_start_tick);
            }
        }
    }

    return FLUID_OK;
}


void
style_player_init () {
    int sfont_id;
    settings = new_fluid_settings();
    synth = new_fluid_synth(settings);
    adriver = new_fluid_audio_driver(settings, synth);
}

void*
queue_style_file_change (char* loc) {
    style_player_sync_stop ();
    if (player) {
        fluid_player_join (player);
        delete_fluid_player(player);
    }
    player = new_fluid_player(synth);
    fluid_player_set_playback_callback(player, parse_midi_events, synth);
    fluid_player_set_tick_callback (player, parse_ticks, synth);
    // fluid_player_set_tempo (player, FLUID_PLAYER_TEMPO_EXTERNAL_BPM, 90);

    if (fluid_is_midifile(loc)) {
        fluid_player_add(player, loc);
    }
    if (looping) {
        fluid_player_play(player);
    }
    style_swap_thread_id = 0;
}

void
style_player_add_style_file (const gchar* mid_file) {
    if (!style_swap_thread_id) {
        pthread_create (&style_swap_thread_id, NULL, queue_style_file_change, mid_file);
    }
}

void
style_player_destruct () {
    /* wait for playback termination */
    fluid_player_stop (player);
    fluid_player_join(player);
    /* cleanup */
    delete_fluid_audio_driver(adriver);
    delete_fluid_player(player);
    delete_fluid_synth(synth);
    delete_fluid_settings(settings);
}

void
style_player_play_loop (int start, int end) {
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

void
style_player_play () {
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
        printf ("Start Looping\n");
        fluid_player_play(player);
        looping = 1;
    } else {
        if (fluid_player_get_status (player) == FLUID_PLAYER_PLAYING) {
            printf ("Stop Looping\n");
            fluid_player_stop (player);
            central_halt = 1;
            looping = 0;
            intro_playing = 0;
            fill_in = 0;
            fill_queue = 0;
            central_style_section = 0;
            central_measure = 0;
            synthesizer_halt_notes ();
        }
    }
    central_clock = 0;
    sync_stop = 0;
}

void
style_player_queue_intro (int start, int end) {
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
}

void
style_player_sync_stop () {
    sync_stop = 1;
}