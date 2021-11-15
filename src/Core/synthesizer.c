/*-
 * Copyright (c) 2021-2022 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
 */

#include <fluidsynth.h>
#include <gtk/gtk.h>
#include "central_bus.h"
#include "synthesizer_settings.h"
#include "driver_settings_provider.h"
#include "chord_finder.h"

fluid_synth_t* style_synth;
fluid_settings_t* style_synth_settings;
fluid_audio_driver_t* style_adriver;

fluid_synth_t* realtime_synth;
fluid_settings_t* realtime_synth_settings;
fluid_audio_driver_t* realtime_adriver;


// Accompaniment Flags
int32_t accompaniment_mode = 0;

// Voice Settings
int realtime_synth_sf_id = 0;
int synthesizer_voice_bank_l = 0;
int synthesizer_voice_program_l = 0;
int synthesizer_voice_bank_r1 = 0;
int synthesizer_voice_program_r1 = 0;
int synthesizer_voice_bank_r2 = 0;
int synthesizer_voice_program_r3 = 0;

// StyleEqualizer
int style_velocity_buffer[16];
int voice_velocity_buffer[3];


// Global scale shift
int synthesizer_transpose = 0;
int synthesizer_transpose_enable = 0;
int synthesizer_octave = 0;
int synthesizer_octave_shifted = 0;

void
synthesizer_edit_master_reverb (int level) {
    if (realtime_synth) {
        fluid_synth_set_reverb_group_roomsize (realtime_synth, -1, get_reverb_room_size(level));
        fluid_synth_set_reverb_group_damp (realtime_synth, -1, 0.1);
        fluid_synth_set_reverb_group_width (realtime_synth, -1, get_reverb_width(level));
        fluid_synth_set_reverb_group_level (realtime_synth, -1, get_reverb_level(level));
    }
    if (style_synth) {
        fluid_synth_set_reverb_group_roomsize (style_synth, -1, get_reverb_room_size(level));
        fluid_synth_set_reverb_group_damp (style_synth, -1, 0.1);
        fluid_synth_set_reverb_group_width (style_synth, -1, get_reverb_width(level));
        fluid_synth_set_reverb_group_level (style_synth, -1, get_reverb_level(level));
    }
}

void
synthesizer_set_master_reverb_active (int active) {
    if (realtime_synth)
        fluid_synth_reverb_on (realtime_synth, -1, active);
    if (style_synth)
        fluid_synth_reverb_on (style_synth, -1, active);
}

void
synthesizer_edit_master_chorus (int level) {
    if (realtime_synth) {
        fluid_synth_set_chorus_group_depth (realtime_synth, -1, get_chorus_depth(level));
        fluid_synth_set_chorus_group_level (realtime_synth, -1, get_chorus_level(level));
        fluid_synth_set_chorus_group_nr (realtime_synth, -1, get_chorus_nr(level));
    }
    if (style_synth) {
        fluid_synth_set_chorus_group_depth (style_synth, -1, get_chorus_depth(level));
        fluid_synth_set_chorus_group_level (style_synth, -1, get_chorus_level(level));
        fluid_synth_set_chorus_group_nr (style_synth, -1, get_chorus_nr(level));
    }
}

void
synthesizer_set_master_chorus_active (int active) {
    if (realtime_synth)
        fluid_synth_chorus_on (realtime_synth, -1, active);
    if (style_synth)
        fluid_synth_chorus_on (style_synth, -1, active);
}

void
synthesizer_set_defaults () {
    // Global reverb and chorus levels
    synthesizer_edit_master_reverb (5);
    synthesizer_edit_master_chorus (1);

    // CutOff for Realtime synth
    fluid_synth_cc (realtime_synth, 0, 74, 40);
    fluid_synth_cc (realtime_synth, 1, 74, 0);
    fluid_synth_cc (realtime_synth, 2, 74, 0);

    // Reverb and Chorus for R1 voice
    fluid_synth_cc (realtime_synth, 0, 91, 4);
    fluid_synth_cc (realtime_synth, 0, 93, 1);

    // Reverb and Chorus for Metronome
    fluid_synth_cc (realtime_synth, 9, 91, 0);
    fluid_synth_cc (realtime_synth, 9, 93, 0);

    // Default gain for Realtime synth
    fluid_synth_cc (realtime_synth, 0, 7, 100);
    fluid_synth_cc (realtime_synth, 1, 7, 90);
    fluid_synth_cc (realtime_synth, 2, 7, 80);


    // Default pitch of all synths
    for (int i = 0; i < 16; i++) {
        fluid_synth_cc (realtime_synth, i, 3, 64);
    }
    for (int i = 6; i < 16; i++) {
        fluid_synth_cc (realtime_synth, i, 74, 40);
        fluid_synth_cc (realtime_synth, i, 71, 10);
    }
    for (int i = 0; i < 16; i++) {
        fluid_synth_cc (style_synth, i, 3, 64);
    }
}

// Effect Rack callback
typedef void
(*synthesizer_fx_callback)(gfloat* input_l,
                        gint input_l_length1,
                        gfloat* input_r,
                        gint input_r_length1,
                        gfloat** output_l,
                        gint* output_l_length1,
                        gfloat** output_r,
                        gint* output_r_length1);

synthesizer_fx_callback fx_callback;

void
set_fx_callback (synthesizer_fx_callback callback) {
    fx_callback = callback;
}

int
fx_function_realtime(void *synth_data, int len,
                int nfx, float **fx,
                int nout, float **out) {
    if(fx == 0)
    {
        /* Note that some audio drivers may not provide buffers for effects like
         * reverb and chorus. In this case it's your decision what to do. If you
         * had called fluid_synth_process() like in the else branch below, no
         * effects would have been rendered. Instead, you may mix the effects
         * directly into the out buffers. */
        if(fluid_synth_process(synth_data, len, nout, out, nout, out) != FLUID_OK)
        {
            /* Some error occurred. Very unlikely to happen, though. */
            return FLUID_FAILED;
        }
    }
    else
    {
        /* Call the synthesizer to fill the output buffers with its
         * audio output. */
        if(fluid_synth_process(synth_data, len, nfx, fx, nout, out) != FLUID_OK)
        {
            /* Some error occurred. Very unlikely to happen, though. */
            return FLUID_FAILED;
        }
    }

    // All processing is stereo // Repeat processing if the plugin is mono
    float *out_l_i = out[0];
    float *out_r_i = out[1];
    // Apply effects here
    float *out_l_o = malloc (len * sizeof (float));
    float *out_r_o = malloc (len * sizeof (float));
    int size_l, size_r;
    if (fx_callback != NULL) {
        fx_callback (out_l_i, len, out_r_i, len, &out_l_o, &size_l, &out_r_o, &size_r);
        for (int k = 0; k < len; k++) {
            out_l_i[k] = out_l_o[k];
            out_r_i[k] = out_r_o[k];
        }
    }
    fluid_free (out_l_o);
    fluid_free (out_r_o);

    return FLUID_OK;
}

void
synthesizer_init (const gchar* loc) {
    style_synth_settings = get_settings(STYLE_SYNTH);

    realtime_synth_settings = get_settings(REALTIME_SYNTH);

    style_synth = new_fluid_synth(style_synth_settings);
    realtime_synth = new_fluid_synth(realtime_synth_settings);
    if (fluid_is_soundfont(loc)) {
        fluid_synth_sfload(style_synth, loc, 1);
        realtime_synth_sf_id = fluid_synth_sfload(realtime_synth, loc, 1);

        // Initialize voices
        fluid_synth_program_select (realtime_synth, 0, realtime_synth_sf_id, 0, 0);
        fluid_synth_program_select (realtime_synth, 1, realtime_synth_sf_id, 0, 49);
        fluid_synth_program_select (realtime_synth, 2, realtime_synth_sf_id, 0, 33);

        // Initialize chord voices
        fluid_synth_program_select (realtime_synth, 3, realtime_synth_sf_id, 0, 5);
        fluid_synth_program_select (realtime_synth, 4, realtime_synth_sf_id, 0, 33);
        fluid_synth_program_select (realtime_synth, 5, realtime_synth_sf_id, 0, 49);

        // Initialize metronome voice
        fluid_synth_program_select (realtime_synth, 9, realtime_synth_sf_id, 128, 0);
    }
    style_adriver = new_fluid_audio_driver(style_synth_settings, style_synth);
    realtime_adriver = new_fluid_audio_driver2(realtime_synth_settings, fx_function_realtime, realtime_synth);

    synthesizer_set_defaults ();
}

void
synthesizer_change_voice (int bank, int preset, int channel) {
    if (realtime_synth) {
        fluid_synth_program_select (realtime_synth, channel, realtime_synth_sf_id, bank, preset);
    }
}

void
synthesizer_change_modulator (int synth_index, int channel, int modulator, int value) {
    if (realtime_synth && style_synth) {
        if (synth_index == 0) {
            fluid_synth_cc (realtime_synth, channel, modulator, value);
        } else {
            fluid_synth_cc (style_synth, channel, modulator, value);
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
synthesizer_get_modulator_values (int synth_index, int channel, int modulator) {
    int mod_value = -1;
    if (realtime_synth && style_synth) {
        if (synth_index == 0) {
            fluid_synth_get_cc (realtime_synth, channel, modulator, &mod_value);
        } else {
            fluid_synth_get_cc (style_synth, channel, modulator, &mod_value);
        }
    }
    return mod_value;
}

int
synthesizer_get_velocity_levels (int synth_index, int channel) {
    if (synth_index == 0)
        return voice_velocity_buffer [channel];
    else
        return style_velocity_buffer [channel];
}


void
synthesizer_destruct () {
    printf ("Stopping Synthesizers\n");
    fluid_synth_all_sounds_off (style_synth, -1);
    fluid_synth_all_sounds_off (realtime_synth, -1);
    printf ("Unloading drivers\n");
    if(style_adriver)
    {
        delete_fluid_audio_driver(style_adriver);
    }
    if(realtime_adriver)
    {
        delete_fluid_audio_driver(realtime_adriver);
    }
    sleep (1);
    printf ("Unloading synthesizers\n");
    if(style_synth)
    {
        delete_fluid_synth(style_synth);
    }
    if(realtime_synth)
    {
        delete_fluid_synth(realtime_synth);
    }
    printf ("Unloading Settings\n");
    if(style_synth_settings)
    {
        delete_settings(STYLE_SYNTH);
    }
    if(realtime_synth_settings)
    {
        delete_settings(REALTIME_SYNTH);
    }
}

int
handle_events_for_styles (fluid_midi_event_t *event) {
    int type = fluid_midi_event_get_type(event);
    int chan = fluid_midi_event_get_channel(event);
    int cont = fluid_midi_event_get_control(event);
    int value= fluid_midi_event_get_value (event);

    // printf ("Type: %d, ", type);
    // printf ("Channel: %d, ", chan);
    // printf ("Control: %d, ", cont);
    // printf ("Value: %d\n", value);

    if (type == 176) {
        if (cont == 85 && (value == 1 || value == 8 || value == 16 || value == 126)) {
            int sf_id, program_id, bank_id;
            fluid_synth_get_program (style_synth, chan, &sf_id, &bank_id, &program_id);
            fluid_synth_program_select (style_synth, chan, realtime_synth_sf_id, value, program_id);
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
    if (chan != 9 && get_central_accompaniment_mode () == 0 && type == 144) {
        return 0;
    }
    if (type == 144) {
        style_velocity_buffer[chan] = value;
    } else if (type == 128) {
        style_velocity_buffer[chan] = 0;
    }
    int ret_val = 0;
    if (style_synth) {
        ret_val = fluid_synth_handle_midi_event(style_synth, event);
    }
    if (event) {
        delete_fluid_midi_event (event);
    }
    return ret_val;
}

int
synthesizer_send_notes_metronome (int key, int on) {
    if (realtime_synth) {
        if (on == 144) {
            fluid_synth_noteon (realtime_synth, 9, key, 127);
        } else {
            fluid_synth_noteoff (realtime_synth, 9, key);
        }
    }
}

int
synthesizer_send_notes (int key, int on, int velocity, int channel, int* type) {
    if (realtime_synth) {
        if (channel <= 0 || channel == 6) {
            if (get_central_accompaniment_mode () > 0) {
                if (accompaniment_mode == 0) {
                    if (key <= get_central_split_key ()) {
                        int chrd_type = 0;
                        int chrd_main = chord_finder_infer (key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), on, &chrd_type);
                        *type = chrd_type;
                        if (get_central_style_looping() == 0 && get_central_style_sync_start() == 0 && on == 144) {
                            fluid_synth_all_notes_off (realtime_synth, 4);
                            fluid_synth_cc (realtime_synth, 3, 91, 0);
                            fluid_synth_cc (realtime_synth, 4, 91, 0);
                            fluid_synth_noteon (realtime_synth, 3, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0) + 12, velocity * 0.6);
                            fluid_synth_noteon (realtime_synth, 4, chrd_main + 36, velocity);
                            fluid_synth_noteon (realtime_synth, 5, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0) + 36, velocity * 0.2);
                            fluid_synth_noteon (realtime_synth, 5, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0) + 24, velocity * 0.4);
                        }
                        if (on == 128) {
                            fluid_synth_noteoff (realtime_synth, 3, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0) + 12);
                            fluid_synth_all_notes_off (realtime_synth, 4);
                            fluid_synth_noteoff (realtime_synth, 5, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0) + 36);
                            fluid_synth_noteoff (realtime_synth, 5, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0) + 24);
                        }
                        return chrd_main;
                    }
                }

            } else if (get_central_split_on () > 0) {
                if (key <= get_central_split_key ()) {
                    if (on == 144) {
                        fluid_synth_noteon (realtime_synth, 2, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity);
                        voice_velocity_buffer[2] = velocity;
                    } else if (on == 128) {
                        fluid_synth_noteoff (realtime_synth, 2, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0));
                        voice_velocity_buffer[2] = 0;
                    }
                    return -6;
                }
            }
            if (on == 144) {
                fluid_synth_noteon (realtime_synth, 0, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity);
                voice_velocity_buffer[0] = velocity;
            } else if (on == 128) {
                fluid_synth_noteoff (realtime_synth, 0, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0));
                voice_velocity_buffer[0] = 0;
            }
            if (get_central_layer_on () > 0) {
                if (on == 144) {
                    fluid_synth_noteon (realtime_synth, 1, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity);
                    voice_velocity_buffer[1] = velocity;
                } else if (on == 128) {
                    fluid_synth_noteoff (realtime_synth, 1, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0));
                    voice_velocity_buffer[1] = 0;
                }
            }
        } else {
            if (on == 144) {
                fluid_synth_noteon (realtime_synth, channel, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0), velocity);
                voice_velocity_buffer[0] = velocity;
            } else if (on == 128) {
                fluid_synth_noteoff (realtime_synth, channel, key + ((synthesizer_octave_shifted > 0) ? (synthesizer_octave * 12) : 0) + ((synthesizer_transpose_enable > 0) ? synthesizer_transpose : 0));
                voice_velocity_buffer[0] = 0;
            }
        }
    }
    return -6;
}

void
synthesizer_halt_notes () {
    if (style_synth) {
        fluid_synth_all_notes_off (style_synth, 0);
        fluid_synth_all_notes_off (style_synth, 1);
        fluid_synth_all_notes_off (style_synth, 2);
        fluid_synth_all_notes_off (style_synth, 3);
        fluid_synth_all_notes_off (style_synth, 4);
        fluid_synth_all_notes_off (style_synth, 5);
        fluid_synth_all_notes_off (style_synth, 6);
        fluid_synth_all_notes_off (style_synth, 7);
        fluid_synth_all_notes_off (style_synth, 8);
        // fluid_synth_all_notes_off (style_synth, 9);
        // fluid_synth_all_notes_off (style_synth, 10);
        fluid_synth_all_notes_off (style_synth, 11);
        fluid_synth_all_notes_off (style_synth, 12);
        fluid_synth_all_notes_off (style_synth, 13);
        fluid_synth_all_notes_off (style_synth, 14);
        fluid_synth_all_notes_off (style_synth, 15);
    }
}

void
synthesizer_halt_realtime () {
    if (realtime_synth) {
        fluid_synth_all_notes_off (realtime_synth, 0);
        fluid_synth_all_notes_off (realtime_synth, 1);
        fluid_synth_all_notes_off (realtime_synth, 2);

        for (int i = 6; i < 16; i++) {
            fluid_synth_all_notes_off (realtime_synth, i);
        }
    }
}


void
synthesizer_set_accomp_enable (int on) {
    set_central_accompaniment_mode (on);
}

float
synthesizer_get_version () {
    int major_version = 0;
    int minor_version = 0;
    int macro_version = 0;
    fluid_version (&major_version, &minor_version, &macro_version);
    return (float)major_version + (0.1f * minor_version);
}
