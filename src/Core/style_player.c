#include <fluidsynth.h>
#include <gtk/gtk.h>
#include <glib.h>
#include "central_bus.h"

// None of this will be used to actual rendering //////////
fluid_settings_t* settings;
fluid_synth_t* synth;
fluid_audio_driver_t* adriver;
fluid_player_t* player;
///////////////////////////////////////////////////////////

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

int32_t style_swap_thread_id = 0;

// Per channel chord change flags
int chord_change_0 = 0;
int chord_change_1 = 0;
int chord_change_2 = 0;
int chord_change_3 = 0;
int chord_change_4 = 0;
int chord_change_5 = 0;
int chord_change_6 = 0;
int chord_change_7 = 0;
int chord_change_8 = 0;
int chord_change_10 = 0;
int chord_change_11 = 0;
int chord_change_12 = 0;
int chord_change_13 = 0;
int chord_change_14 = 0;
int chord_change_15 = 0;

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
int channel_note_on_10 = -1;
int channel_note_on_11 = -1;
int channel_note_on_12 = -1;
int channel_note_on_13 = -1;
int channel_note_on_14 = -1;
int channel_note_on_15 = -1;

// Chord tracking flags
int chord_main = 0; // C
int chord_type = 0; // Major

int style_original_chord_main = 0;
int style_original_chord_type = 1;


void
style_player_change_chord (int cd_main, int cd_type) {
    if (cd_main != -6) {
        chord_main = cd_main;
        chord_type = cd_type;
        chord_change_0 = 1;
    }
    measure_length = loaded_style_time_stamps[1];
    if (central_style_sync_start == 1) {
        central_style_sync_start = 0;
        if (central_style_looping == 0) {
            if (start_s == 0) {
                start_s = 3;
                end_s = 4;
                start_temp = start_s;
                end_temp = end_s;
            }
            loop_start_tick = loaded_style_time_stamps[start_s];
            loop_end_tick = loaded_style_time_stamps[end_s];
            fluid_player_seek (player, loop_start_tick);
            printf ("Start central_style_looping\n");
            fluid_player_play(player);
            central_style_looping = 1;
        }
        central_clock = 0;
        sync_stop = 0;
    }
    //printf("%d\n", chord_main);
}

void
handle_chord_changes () {

}

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
    switch (channel) {
        case 0:
        if (type == 144) channel_note_on_0 = key; else if (type == 128) channel_note_on_0 = -1;
        break;
        case 1:
        if (type == 144) channel_note_on_1 = key; else if (type == 128) channel_note_on_1 = -1;
        break;
        case 2:
        if (type == 144) channel_note_on_2 = key; else if (type == 128) channel_note_on_2 = -1;
        break;
        case 3:
        if (type == 144) channel_note_on_3 = key; else if (type == 128) channel_note_on_3 = -1;
        break;
        case 4:
        if (type == 144) channel_note_on_4 = key; else if (type == 128) channel_note_on_4 = -1;
        break;
        case 5:
        if (type == 144) channel_note_on_5 = key; else if (type == 128) channel_note_on_5 = -1;
        break;
        case 6:
        if (type == 144) channel_note_on_6 = key; else if (type == 128) channel_note_on_6 = -1;
        break;
        case 7:
        if (type == 144) channel_note_on_7 = key; else if (type == 128) channel_note_on_7 = -1;
        break;
        case 8:
        if (type == 144) channel_note_on_8 = key; else if (type == 128) channel_note_on_8 = -1;
        break;
        case 10:
        if (type == 144) channel_note_on_10 = key; else if (type == 128) channel_note_on_10 = -1;
        break;
        case 11:
        if (type == 144) channel_note_on_11 = key; else if (type == 128) channel_note_on_11 = -1;
        break;
        case 12:
        if (type == 144) channel_note_on_12 = key; else if (type == 128) channel_note_on_12 = -1;
        break;
        case 13:
        if (type == 144) channel_note_on_13 = key; else if (type == 128) channel_note_on_13 = -1;
        break;
        case 14:
        if (type == 144) channel_note_on_14 = key; else if (type == 128) channel_note_on_14 = -1;
        break;
        case 15:
        if (type == 144) channel_note_on_15 = key; else if (type == 128) channel_note_on_15 = -1;
        break;
    }

    if (channel != 9 && (type == 144 || type == 128)) {
        if (style_original_chord_type == 0) {
            if (chord_type == 0) {
                fluid_midi_event_set_key (new_event, key + chord_main);
            } else {
                if ((key - 4) % 12 == 0 || (key - 9) % 12 == 0 || (key - 11) % 12 == 0) {
                    fluid_midi_event_set_key (new_event, key + chord_main - 1);
                } else {
                    fluid_midi_event_set_key (new_event, key + chord_main);
                }
            }
        } else if (style_original_chord_type == 1) {
            if (chord_type == 1) {
                fluid_midi_event_set_key (new_event, key + chord_main);
            } else {
                if ((key - 3) % 12 == 0 || (key - 8) % 12 == 0 || (key - 10) % 12 == 0) {
                    fluid_midi_event_set_key (new_event, key + chord_main + 1);
                } else {
                    fluid_midi_event_set_key (new_event, key + chord_main);
                }
            }
        }
        
    } else {
        fluid_midi_event_set_key (new_event, key);
    }
    
    
    

    // Send data to synth
    handle_events_for_styles (new_event);
    return 0;
}

int
parse_ticks (void* data, int ticks) {
    if (chord_change_0 == 1) {
        chord_change_0 = 0;
        printf ("chord -> %d\n", chord_main);
        synthesizer_halt_notes ();
    }
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
        if (central_style_looping == 1) {
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
                    central_style_looping = 0;
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
    central_style_looping = 0;
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
    if (central_style_looping) {
        fluid_player_play(player);
    }
    style_swap_thread_id = 0;
    g_thread_yield ();
}

void
style_player_add_style_file (const gchar* mid_file) {
    if (style_swap_thread_id == 0) {
       style_swap_thread_id = 1;
       g_thread_new ("Style Swapper", queue_style_file_change, mid_file);
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
    if (central_style_looping == 0) {
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
    if (central_style_looping == 0) {
        if (start_s == 0) {
            start_s = 3;
            end_s = 4;
            start_temp = start_s;
            end_temp = end_s;
        }
        loop_start_tick = loaded_style_time_stamps[start_s];
        loop_end_tick = loaded_style_time_stamps[end_s];
        fluid_player_seek (player, loop_start_tick);
        printf ("Start central_style_looping\n");
        fluid_player_play(player);
        central_style_looping = 1;
    } else {
        if (fluid_player_get_status (player) == FLUID_PLAYER_PLAYING) {
            printf ("Stop central_style_looping\n");
            fluid_player_stop (player);
            central_halt = 1;
            central_style_looping = 0;
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

void
style_player_sync_start () {
    central_style_sync_start = 1;
}