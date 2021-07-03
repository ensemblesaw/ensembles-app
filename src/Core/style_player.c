#include <fluidsynth.h>
#include <gtk/gtk.h>
#include <glib.h>
#include <string.h>

#include "style_analyser.h"
#include "central_bus.h"
#include "synthesizer.h"

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

char* style_player_style_path;


int ticks_since_measure = 0;

int changing_variation = 0;
int changing_style = 0;

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


void
style_player_change_chord (int cd_main, int cd_type) {
    if (cd_main != -6) {
        chord_main = cd_main;
        chord_type = cd_type;
        chord_change_0 = 1;
    }
    measure_length = get_loaded_style_time_stamps_by_index (1);
    if (get_central_style_sync_start () == 1) {
        set_central_style_sync_start (0);
        if (get_central_style_looping () == 0) {
            if (start_s == 0) {
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
        }
        set_central_clock (0);
        sync_stop = 0;
    }
    //printf("%d\n", chord_main);
}

int
get_chord_modified_key (int key) {
    if (get_central_style_original_chord_type () == 0) {
        if (chord_type == 0) {
            return key + chord_main;
        } else {
            if ((key - 4) % 12 == 0 || (key - 9) % 12 == 0 || (key - 11) % 12 == 0) {
                return (key + chord_main - 1);
            } else {
                return (key + chord_main);
            }
        }
    } else if (get_central_style_original_chord_type () == 1) {
        if (chord_type == 1) {
            return (key + chord_main);
        } else {
            if ((key - 3) % 12 == 0 || (key - 8) % 12 == 0 || (key - 10) % 12 == 0) {
                return (key + chord_main + 1);
            } else {
                return (key + chord_main);
            }
        }
    }
    return 0;
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
        if (type == 144) channel_note_on_0 = key | (fluid_midi_event_get_velocity (event) << 16); else if (type == 128) channel_note_on_0 = -1;
        break;
        case 1:
        if (type == 144) channel_note_on_1 = key | (fluid_midi_event_get_velocity (event) << 16); else if (type == 128) channel_note_on_1 = -1;
        break;
        case 2:
        if (type == 144) channel_note_on_2 = key | (fluid_midi_event_get_velocity (event) << 16); else if (type == 128) channel_note_on_2 = -1;
        break;
        case 3:
        if (type == 144) channel_note_on_3 = key | (fluid_midi_event_get_velocity (event) << 16); else if (type == 128) channel_note_on_3 = -1;
        break;
        case 4:
        if (type == 144) channel_note_on_4 = key | (fluid_midi_event_get_velocity (event) << 16); else if (type == 128) channel_note_on_4 = -1;
        break;
        case 5:
        if (type == 144) channel_note_on_5 = key | (fluid_midi_event_get_velocity (event) << 16); else if (type == 128) channel_note_on_5 = -1;
        break;
        case 6:
        if (type == 144) channel_note_on_6 = key | (fluid_midi_event_get_velocity (event) << 16); else if (type == 128) channel_note_on_6 = -1;
        break;
        case 7:
        if (type == 144) channel_note_on_7 = key | (fluid_midi_event_get_velocity (event) << 16); else if (type == 128) channel_note_on_7 = -1;
        break;
        case 8:
        if (type == 144) channel_note_on_8 = key | (fluid_midi_event_get_velocity (event) << 16); else if (type == 128) channel_note_on_8 = -1;
        break;
        case 10:
        if (type == 144) channel_note_on_10 = key | (fluid_midi_event_get_velocity (event) << 16); else if (type == 128) channel_note_on_10 = -1;
        break;
        case 11:
        if (type == 144) channel_note_on_11 = key | (fluid_midi_event_get_velocity (event) << 16); else if (type == 128) channel_note_on_11 = -1;
        break;
        case 12:
        if (type == 144) channel_note_on_12 = key | (fluid_midi_event_get_velocity (event) << 16); else if (type == 128) channel_note_on_12 = -1;
        break;
        case 13:
        if (type == 144) channel_note_on_13 = key | (fluid_midi_event_get_velocity (event) << 16); else if (type == 128) channel_note_on_13 = -1;
        break;
        case 14:
        if (type == 144) channel_note_on_14 = key | (fluid_midi_event_get_velocity (event) << 16); else if (type == 128) channel_note_on_14 = -1;
        break;
        case 15:
        if (type == 144) channel_note_on_15 = key | (fluid_midi_event_get_velocity (event) << 16); else if (type == 128) channel_note_on_15 = -1;
        break;
    }

    if (channel != 9 && (type == 144 || type == 128)) {
        fluid_midi_event_set_key (new_event, get_chord_modified_key (key));
        
    } else {
        fluid_midi_event_set_key (new_event, key);
    }
    
    
    

    // Send data to synth
    handle_events_for_styles (new_event);
    return 0;
}

void
resend_key (int value, int channel) {
    fluid_midi_event_t* new_event = new_fluid_midi_event ();
    fluid_midi_event_set_channel (new_event, channel);
    fluid_midi_event_set_type (new_event, 144);
    fluid_midi_event_set_key (new_event, get_chord_modified_key (value & 0xFFFF));
    fluid_midi_event_set_velocity (new_event, (value >> 16) & 0xFFFF);
    handle_events_for_styles (new_event);
}

int
parse_ticks (void* data, int ticks) {
    if (chord_change_0 == 1) {
        chord_change_0 = 0;
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
        if (channel_note_on_10 >= 0) resend_key (channel_note_on_10, 10);
        if (channel_note_on_11 >= 0) resend_key (channel_note_on_11, 11);
        if (channel_note_on_12 >= 0) resend_key (channel_note_on_12, 12);
        if (channel_note_on_13 >= 0) resend_key (channel_note_on_13, 13);
        if (channel_note_on_14 >= 0) resend_key (channel_note_on_14, 14);
        if (channel_note_on_15 >= 0) resend_key (channel_note_on_15, 15);
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
    if (get_central_clock () == 0 && ((ticks - loop_start_tick) % measure_length) <= 1) {
        set_central_clock (1);
        fill_queue = 0;
        fill_in = 0;
        set_central_style_section (start_s);
        if (loop_start_tick != get_loaded_style_time_stamps_by_index (start_s)) {
            loop_start_tick = get_loaded_style_time_stamps_by_index (start_s);
            loop_end_tick = get_loaded_style_time_stamps_by_index (end_s);
            synthesizer_halt_notes ();
            return fluid_player_seek (player, loop_start_tick);
        }
        if (get_central_style_looping () == 1) {
            if (ticks >= loop_end_tick && fill_in == 0) {
                set_central_style_section (start_s);
                if (intro_playing == 1) {
                    start_s = start_temp;
                    end_s = end_temp;
                    intro_playing = 0;
                    loop_start_tick = get_loaded_style_time_stamps_by_index(start_s);
                    loop_end_tick = get_loaded_style_time_stamps_by_index(end_s);
                    synthesizer_halt_notes ();
                    set_central_style_section (start_s);
                    return fluid_player_seek (player, loop_start_tick);
                } else if (sync_stop) {
                    fluid_player_stop (player);
                    set_central_halt (1);
                    start_s = start_temp;
                    end_s = end_temp;
                    set_central_style_looping (0);
                    intro_playing = 0;
                    fill_in = 0;
                    fill_queue = 0;
                    sync_stop = 0;
                    set_central_style_section (0);
                    set_central_measure (0);
                    synthesizer_halt_notes ();
                }
                breaking = 0;
                synthesizer_halt_notes ();
                return fluid_player_seek (player, loop_start_tick + 1);
            }
        }
    }

    return FLUID_OK;
}


void
style_player_init () {
    set_central_style_looping (0);
    settings = new_fluid_settings();
    synth = new_fluid_synth(settings);
    adriver = new_fluid_audio_driver(settings, synth);
}

void
style_player_sync_stop () {
    sync_stop = 1;
}

void
style_player_sync_start () {
    set_central_style_sync_start (1);
}

GThreadFunc
queue_style_file_change (int use_previous_tempo) {
    printf("changing...to %s\n", style_player_style_path);
    int previous_tempo = -1;
    if (get_central_style_looping ()) {
        previous_tempo = fluid_player_get_midi_tempo (player);
        style_player_sync_stop ();
        fluid_player_join (player);
        changing_style = 1;
        printf ("a:\n");
    } else {
        printf ("e:\n");
    }
    if (use_previous_tempo) {
        previous_tempo = fluid_player_get_midi_tempo (player);
    }
    if (player) {
        printf ("b:\n");
        delete_fluid_player(player);
        printf ("c:\n");
    }
    player = new_fluid_player(synth);
    fluid_player_set_playback_callback(player, parse_midi_events, synth);
    fluid_player_set_tick_callback (player, parse_ticks, synth);
    // fluid_player_set_tempo (player, FLUID_PLAYER_TEMPO_EXTERNAL_BPM, 90);
    printf ("f:\n");
    if (fluid_is_midifile(style_player_style_path)) {
        fluid_player_add(player, style_player_style_path);
    }
    if (previous_tempo != -1 || use_previous_tempo) {
        fluid_player_set_tempo (player, FLUID_PLAYER_TEMPO_EXTERNAL_MIDI, (double)previous_tempo);
        set_central_loaded_tempo (previous_tempo / 3840);
        printf("%d >>>>\n", previous_tempo);
    }
    if (changing_style) {
        changing_style = 0;
        loop_start_tick = get_loaded_style_time_stamps_by_index(start_s);
        loop_end_tick = get_loaded_style_time_stamps_by_index(end_s);
        fluid_player_seek (player, loop_start_tick);
        printf ("Restart player with new style\n");
        fluid_player_play(player);
        set_central_style_looping (1) ;
        set_central_clock (0);
        sync_stop = 0;
        printf ("d:\n");
    }
    style_swap_thread_id = 0;
    g_thread_yield ();
}

void
style_player_add_style_file (const gchar* mid_file, int reload) {
    printf("chan...to %s\n", mid_file);
    if (style_swap_thread_id == 0) {
       style_swap_thread_id = 1;
       style_player_style_path = (char *)malloc(sizeof (char) * strlen (mid_file));
       strcpy (style_player_style_path, mid_file);
       style_analyser_analyze (style_player_style_path);
       g_thread_new ("Style Swapper", queue_style_file_change, reload);
    }
}

void
style_player_reload_style () {
    style_player_add_style_file (style_player_style_path, 1);
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
    } else {
        if (fluid_player_get_status (player) == FLUID_PLAYER_PLAYING) {
            printf ("Stop central_style_looping\n");
            fluid_player_stop (player);
            set_central_halt (1);
            set_central_style_looping (0);
            intro_playing = 0;
            fill_in = 0;
            fill_queue = 0;
            set_central_style_section (0);
            set_central_measure (0);
            synthesizer_halt_notes ();
        }
    }
    set_central_clock (0);
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