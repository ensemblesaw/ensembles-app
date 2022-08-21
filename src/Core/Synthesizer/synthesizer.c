/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "synthesizer.h"

fluid_synth_t* realtime_render_synth;


// Accompaniment Flags
int accompaniment_mode = 0;
int accompaniment_on = 0;

// Voice Settings
int soundfont_id = 0;
int synthesizer_voice_bank_l = 0;
int synthesizer_voice_program_l = 0;
int synthesizer_voice_bank_r1 = 0;
int synthesizer_voice_program_r1 = 0;
int synthesizer_voice_bank_r2 = 0;
int synthesizer_voice_program_r3 = 0;

// Equalizer
int velocity_buffer[20];


// Global scale shift
int synthesizer_transpose = 0;
int synthesizer_transpose_enable = 0;
int synthesizer_octave = 0;
int synthesizer_octave_shifted = 0;

void
synthesizer_edit_master_reverb (int level) {
    if (realtime_render_synth) {
        fluid_synth_set_reverb_group_roomsize (realtime_render_synth, -1, get_reverb_room_size(level));
        fluid_synth_set_reverb_group_damp (realtime_render_synth, -1, 0.1);
        fluid_synth_set_reverb_group_width (realtime_render_synth, -1, get_reverb_width(level));
        fluid_synth_set_reverb_group_level (realtime_render_synth, -1, get_reverb_level(level));
    }
}

void
synthesizer_set_master_reverb_active (int active) {
    if (realtime_render_synth)
        fluid_synth_reverb_on (realtime_render_synth, -1, active);
}

void
synthesizer_edit_master_chorus (int level) {
    if (realtime_render_synth) {
        fluid_synth_set_chorus_group_depth (realtime_render_synth, -1, get_chorus_depth(level));
        fluid_synth_set_chorus_group_level (realtime_render_synth, -1, get_chorus_level(level));
        fluid_synth_set_chorus_group_nr (realtime_render_synth, -1, get_chorus_nr(level));
    }
}

void
synthesizer_set_master_chorus_active (int active) {
    if (realtime_render_synth)
        fluid_synth_chorus_on (realtime_render_synth, -1, active);
}

void
synthesizer_set_defaults () {
    // Global reverb and chorus levels
    synthesizer_edit_master_reverb (7);
    synthesizer_edit_master_chorus (2);

    // CutOff for Realtime synth
    fluid_synth_cc (realtime_render_synth, 17, 74, 40);
    fluid_synth_cc (realtime_render_synth, 18, 74, 0);
    fluid_synth_cc (realtime_render_synth, 19, 74, 0);

    // Reverb and Chorus for R1 voice
    fluid_synth_cc (realtime_render_synth, 17, 91, 100);
    fluid_synth_cc (realtime_render_synth, 17, 93, 100);

    // Reverb and Chorus for Metronome
    fluid_synth_cc (realtime_render_synth, 16, 91, 0);
    fluid_synth_cc (realtime_render_synth, 16, 93, 0);

    // Default gain for Realtime synth
    fluid_synth_cc (realtime_render_synth, 17, 7, 100);
    fluid_synth_cc (realtime_render_synth, 18, 7, 90);
    fluid_synth_cc (realtime_render_synth, 19, 7, 80);


    // Default pitch of all synths
    for (int i = 17; i < 64; i++) {
        fluid_synth_cc (realtime_render_synth, i, 3, 64);
    }

    // Default cut-off and resonance for recorder
    for (int i = 24; i < 64; i++) {
        fluid_synth_cc (realtime_render_synth, i, 74, 40);
        fluid_synth_cc (realtime_render_synth, i, 71, 10);
    }

    // Default pitch for styles
    for (int i = 0; i < 16; i++) {
        fluid_synth_cc (realtime_render_synth, i, 3, 64);
    }
}

static synthesizer_note_event_callback event_callback;

void
set_note_callback (synthesizer_note_event_callback callback) {
    event_callback = callback;
}

void
synthesizer_init(const char* loc, const char* dname, double buffer_size)
{
    #ifdef PIPEWIRE_CORE_DRIVER
    pw_init(NULL, NULL);
    #endif
    set_driver_configuration(dname, buffer_size);
    realtime_render_synth = get_synthesizer(RENDER);
    if (fluid_is_soundfont(loc)) {
        soundfont_id = fluid_synth_sfload(realtime_render_synth, loc, 1);

        // Initialize voices
        fluid_synth_program_select (realtime_render_synth, 17, soundfont_id, 0, 0);
        fluid_synth_program_select (realtime_render_synth, 18, soundfont_id, 0, 49);
        fluid_synth_program_select (realtime_render_synth, 19, soundfont_id, 0, 33);

        // Initialize chord voices
        fluid_synth_program_select (realtime_render_synth, 20, soundfont_id, 0, 5);
        fluid_synth_program_select (realtime_render_synth, 21, soundfont_id, 0, 33);
        fluid_synth_program_select (realtime_render_synth, 22, soundfont_id, 0, 49);

        // Initialize metronome voice
        fluid_synth_program_select (realtime_render_synth, 16, soundfont_id, 128, 0);
    }

    synthesizer_set_defaults ();
}

void
synthesizer_send_notes_to_metronome(int key, int on)
{
    if (realtime_render_synth)
    {
        if (on == 144)
        {
            fluid_synth_noteon(realtime_render_synth, 16, key, 127);
        }
        else
        {
            fluid_synth_noteoff(realtime_render_synth, 16, key);
        }
    }
}

int
synthesizer_set_driver_configuration(const char* dname, double buffer_size)
{
    return set_driver_configuration(dname, buffer_size);
}

void
synthesizer_change_voice (int bank, int preset, int channel) {
    printf ("Voice: %d, Channel: %d\n", preset, channel);
    if (realtime_render_synth) {
        fluid_synth_program_select (realtime_render_synth, channel, soundfont_id, bank, preset);
    }
}

void
synthesizer_get_voice_by_channel (int channel, int* bank, int* preset) {
    int sfid = 0;
    fluid_synth_get_program(realtime_render_synth, channel, &sfid, bank, preset);
}

void
synthesizer_change_modulator (int channel, int modulator, int value) {
    if (realtime_render_synth) {
        fluid_synth_cc (realtime_render_synth, channel, modulator, value);
        if (channel < 16) {
            if (modulator == 7) {
                // printf ("%d, %d\n", channel, value);
                set_gain_value (channel, value);
            }
            if (modulator == 3 || modulator == 10) {
                set_mod_buffer_value (modulator, channel, value >= -64 ? value : -64);
            } else {
                set_mod_buffer_value (modulator, channel, value >= 0 ? value : 0);
            }
        }
    }
}

int
synthesizer_get_modulator_values (int channel, int modulator) {
    int mod_value = -1;
    if (realtime_render_synth) {
        fluid_synth_get_cc (realtime_render_synth, channel, modulator, &mod_value);
    }
    return mod_value;
}

int
synthesizer_get_velocity_levels (int channel) {
    if (velocity_buffer < 0) {
        velocity_buffer[channel] = 0;
    }
    return velocity_buffer[channel] -= 8;
}


void
synthesizer_destruct () {
    fluid_synth_all_sounds_off (realtime_render_synth, -1);
    delete_synthesizer_instances ();
}

void
synthesizer_set_fx_callback (synthesizer_fx_callback callback) {
    set_fx_callback(callback);
}

static synthesizer_note_event_callback event_callback;

void
synthesizer_set_event_callback (synthesizer_note_event_callback callback)
{
    event_callback = callback;
}

void
synthesizer_set_accomp_enable (int on)
{
    accompaniment_on = on;
}

int
handle_events_for_midi_players(fluid_midi_event_t *event, int _is_style_player)
{
    int type = fluid_midi_event_get_type(event);
    int chan = fluid_midi_event_get_channel(event);
    int cont = fluid_midi_event_get_control(event);
    int value= fluid_midi_event_get_value (event);

    // printf ("Type: %d, ", type);
    // printf ("Channel: %d, ", chan);
    // printf ("Control: %d, ", cont);
    // printf ("Value: %d\n", value);
    if (_is_style_player == 1)
    {
        if (type == 176)
        {
            if (cont == 85 && (value == 1 || value == 8 || value == 16 || value == 126)) {
                int sf_id, program_id, bank_id;
                fluid_synth_get_program (realtime_render_synth, chan, &sf_id, &bank_id, &program_id);
                fluid_synth_program_select (realtime_render_synth, chan, soundfont_id, value, program_id);
            }
            if (cont == 7) {
                if (get_gain_value(chan) >= 0) {
                    fluid_midi_event_set_value (event, get_gain_value(chan));
                }
            }
            if (cont == 16) {
                if (get_mod_buffer_value (16, chan) >= -64) {
                    fluid_midi_event_set_value (event, get_mod_buffer_value (9, chan));
                }
            } else if (cont == 10) {
                if (get_mod_buffer_value (10, chan) >= -64) {
                    fluid_midi_event_set_value (event, get_mod_buffer_value (10, chan));
                }
            } else {
                if (get_mod_buffer_value (cont, chan) >= 0) {
                    fluid_midi_event_set_value (event, get_mod_buffer_value (cont, chan));
                }
            }
        }
        if (chan != 9 && !accompaniment_on && type == 144) {
            return 0;
        }
        if (type == 144)
        {
            velocity_buffer[chan] = value;
        }
    }
    int ret_val = 0;
    if (realtime_render_synth) {
        ret_val = fluid_synth_handle_midi_event(realtime_render_synth, event);
    }
    if (event) {
        delete_fluid_midi_event (event);
    }
    return ret_val;
}

int
synthesizer_send_notes (int key, int on, int velocity, int channel, u_int8_t midi_split, int* type)
{
    if (realtime_render_synth)
    {
        if (midi_split)
        {
            if (channel >= 17 && channel < 24)
            {
                if (accompaniment_on)
                {
                    if (accompaniment_mode == 0)
                    {
                        if (channel == 19)
                        {
                            int chrd_type = 0;
                            int chrd_main = chord_finder_infer (key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), on, &chrd_type);
                            *type = chrd_type;
                            if (get_central_style_looping() == 0 && get_central_style_sync_start() == 0 && on == 144)
                            {
                                fluid_synth_all_notes_off (realtime_render_synth, 21);
                                fluid_synth_cc (realtime_render_synth, 20, 91, 0);
                                fluid_synth_cc (realtime_render_synth, 21, 91, 0);
                                fluid_synth_noteon (realtime_render_synth, 20, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0) + 12, velocity * 0.6);
                                fluid_synth_noteon (realtime_render_synth, 21, chrd_main + 36, velocity);
                                fluid_synth_noteon (realtime_render_synth, 22, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0) + 36, velocity * 0.2);
                                fluid_synth_noteon (realtime_render_synth, 22, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0) + 24, velocity * 0.4);
                            }
                            if (on == 128)
                            {
                                fluid_synth_noteoff (realtime_render_synth, 20, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0) + 12);
                                fluid_synth_all_notes_off (realtime_render_synth, 21);
                                fluid_synth_noteoff (realtime_render_synth, 22, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0) + 36);
                                fluid_synth_noteoff (realtime_render_synth, 22, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0) + 24);
                            }
                            event_callback(17, 0, 0, 0, chrd_main, chrd_type);
                            return chrd_main;
                        }
                    }

                } else if (get_central_split_on () > 0) {
                    if (channel == 19) {
                        if (on == 144) {
                            fluid_synth_noteon(realtime_render_synth, 19, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity);
                            velocity_buffer[19] = velocity;
                            event_callback(19, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity, 144, 0, 0);
                        } else if (on == 128) {
                            fluid_synth_noteoff(realtime_render_synth, 19, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0));
                            event_callback(19, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), 0, 128, 0, 0);
                            velocity_buffer[19] = 0;
                        }
                        return -6;
                    }
                }
                if (on == 144) {
                    fluid_synth_noteon(realtime_render_synth, channel < 0 ? 17 : channel, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity);
                    velocity_buffer[17] = velocity;
                    event_callback(17, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity, 144, 0, 0);
                } else if (on == 128) {
                    fluid_synth_noteoff(realtime_render_synth, channel < 0 ? 17 : channel, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0));
                    velocity_buffer[17] = 0;
                    event_callback(17, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), 0, 128, 0, 0);
                }
                if (get_central_layer_on () > 0) {
                    if (on == 144) {
                        fluid_synth_noteon (realtime_render_synth, 18, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity);
                        velocity_buffer[18] = velocity;
                        event_callback(24, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity, 144, 0, 0);
                    } else if (on == 128) {
                        fluid_synth_noteoff (realtime_render_synth, 18, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0));
                        velocity_buffer[18] = 0;
                        event_callback(24, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), 0, 128, 0, 0);

                    }
                }
            } else {
                if (on == 144) {
                    fluid_synth_noteon (realtime_render_synth, channel, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity);
                    event_callback(channel, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity, 144, 0, 0);
                } else if (on == 128) {
                    fluid_synth_noteoff (realtime_render_synth, channel, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0));
                    event_callback(channel, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), 0, 128, 0, 0);
                }
            }
        }
        else
        {
            if (channel == 17)
            {
                if (accompaniment_on)
                {
                    if (accompaniment_mode == 0)
                    {
                        if (key <= get_central_split_key ())
                        {
                            int chrd_type = 0;
                            int chrd_main = chord_finder_infer (key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), on, &chrd_type);
                            *type = chrd_type;
                            if (get_central_style_looping() == 0 && get_central_style_sync_start() == 0 && on == 144)
                            {
                                fluid_synth_all_notes_off (realtime_render_synth, 21);
                                fluid_synth_cc (realtime_render_synth, 20, 91, 0);
                                fluid_synth_cc (realtime_render_synth, 21, 91, 0);
                                fluid_synth_noteon (realtime_render_synth, 20, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0) + 12, velocity * 0.6);
                                fluid_synth_noteon (realtime_render_synth, 21, chrd_main + 36, velocity);
                                fluid_synth_noteon (realtime_render_synth, 22, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0) + 36, velocity * 0.2);
                                fluid_synth_noteon (realtime_render_synth, 22, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0) + 24, velocity * 0.4);
                            }
                            if (on == 128)
                            {
                                fluid_synth_noteoff (realtime_render_synth, 20, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0) + 12);
                                fluid_synth_all_notes_off (realtime_render_synth, 21);
                                fluid_synth_noteoff (realtime_render_synth, 22, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0) + 36);
                                fluid_synth_noteoff (realtime_render_synth, 22, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0) + 24);
                            }
                            event_callback(17, 0, 0, 0, chrd_main, chrd_type);
                            return chrd_main;
                        }
                    }

                } else if (get_central_split_on () > 0) {
                    if (key <= get_central_split_key ()) {
                        if (on == 144) {
                            fluid_synth_noteon(realtime_render_synth, 19, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity);
                            velocity_buffer[19] = velocity;
                            event_callback(19, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity, 144, 0, 0);
                        } else if (on == 128) {
                            fluid_synth_noteoff(realtime_render_synth, 19, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0));
                            event_callback(19, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), 0, 128, 0, 0);
                            velocity_buffer[19] = 0;
                        }
                        return -6;
                    }
                }
                if (on == 144) {
                    fluid_synth_noteon(realtime_render_synth, channel < 0 ? 17 : channel, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity);
                    velocity_buffer[17] = velocity;
                    event_callback(17, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity, 144, 0, 0);
                } else if (on == 128) {
                    fluid_synth_noteoff(realtime_render_synth, channel < 0 ? 17 : channel, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0));
                    velocity_buffer[17] = 0;
                    event_callback(17, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), 0, 128, 0, 0);
                }
                if (get_central_layer_on () > 0) {
                    if (on == 144) {
                        fluid_synth_noteon (realtime_render_synth, 18, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity);
                        velocity_buffer[18] = velocity;
                        event_callback(24, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity, 144, 0, 0);
                    } else if (on == 128) {
                        fluid_synth_noteoff (realtime_render_synth, 18, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0));
                        velocity_buffer[18] = 0;
                        event_callback(24, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), 0, 128, 0, 0);

                    }
                }
            } else {
                if (on == 144) {
                    fluid_synth_noteon (realtime_render_synth, channel, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity);
                    event_callback(channel, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity, 144, 0, 0);
                } else if (on == 128) {
                    fluid_synth_noteoff (realtime_render_synth, channel, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0));
                    event_callback(channel, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), 0, 128, 0, 0);
                }
            }
        }

    }
    return -6;
}

void
synthesizer_halt_notes ()
{
    if (realtime_render_synth) {
        for (int i = 0; i < 16; i++) {
            if (i != 9 && i != 10) {
                fluid_synth_all_notes_off (realtime_render_synth, i);
            }
            velocity_buffer[i] = 0;
        }
    }
}

void
synthesizer_halt_realtime (int b_all)
{
    if (realtime_render_synth) {
        fluid_synth_all_notes_off (realtime_render_synth, 17);
        fluid_synth_all_notes_off (realtime_render_synth, 18);
        fluid_synth_all_notes_off (realtime_render_synth, 19);
        if (b_all > 0)
        {
            for (int i = 20; i < 64; i++) {
                fluid_synth_all_notes_off (realtime_render_synth, i);
            }
        }
    }
}

void
synthesizer_send_sustain (int on)
{
    synthesizer_change_modulator (17, 66, on > 0 ? 127 : 0);
}

float
synthesizer_get_version ()
{
    int major_version = 0;
    int minor_version = 0;
    int macro_version = 0;
    fluid_version (&major_version, &minor_version, &macro_version);
    return (float)major_version + (0.1f * minor_version);
}
