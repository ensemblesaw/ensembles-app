#include <fluidsynth.h>
#include <gtk/gtk.h>
#include "central_bus.h"
#include "synthesizer_settings.h"

fluid_synth_t* style_synth;
fluid_settings_t* style_synth_settings;
fluid_audio_driver_t* style_adriver;

fluid_synth_t* realtime_synth;
fluid_settings_t* realtime_synth_settings;
fluid_audio_driver_t* realtime_adriver;


// Accompaniment Flags
int accompaniment_enabled = 0;
int32_t accompaniment_mode = 0;
int synthsizer_split_key = 54;

// Voice Settings
int realtime_synth_sf_id = 0;
int synthesizer_voice_bank_l = 0;
int synthesizer_voice_program_l = 0;
int synthesizer_voice_bank_r1 = 0;
int synthesizer_voice_program_r1 = 0;
int synthesizer_voice_bank_r2 = 0;
int synthesizer_voice_program_r3 = 0;

struct fx_data_t
{
    fluid_synth_t *synth;
    float gain;
} fx_data_t;
struct fx_data_t fx_data;

int 
fx_function(void *data, int len,
            int nfx, float **fx,
            int nout, float **out) {
            
    struct fx_data_t *fx_data = (struct fx_data_t *) data;
    int i, k;

 // DO NOT add Low Pass or reverb or chorus here. Add them as modulators in soundfont first
    if(fx == 0) {
        if(fluid_synth_process(fx_data->synth, len, nout, out, nout, out) != FLUID_OK)
        {
            return FLUID_FAILED;
        }
    }
    else
    {
        /* Call the synthesizer to fill the output buffers with its
         * audio output. */
        if(fluid_synth_process(fx_data->synth, len, nfx, fx, nout, out) != FLUID_OK)
        {
            return FLUID_FAILED;
        }
    }
    for(i = 0; i < nout; i++)
    {
        float *out_i = out[i];
        for(int sample = 0; sample < len; sample++)
        {
            out_i[sample] *= fx_data->gain;
        }
    }
    return FLUID_OK;
}

void
fx_init () {
    fx_data.synth = style_synth;
    fx_data.gain = 1.0;
}

void
synthesizer_edit_master_reverb (int level) {
    fluid_synth_reverb_on (realtime_synth, -1, TRUE);
    fluid_synth_set_reverb_group_roomsize (realtime_synth, -1, reverb_room_size[level]);
    fluid_synth_set_reverb_group_damp (realtime_synth, -1, 0.1);
    fluid_synth_set_reverb_group_width (realtime_synth, -1, reverb_width[level]);
    fluid_synth_set_reverb_group_level (realtime_synth, -1, reverb_level[level]);

    fluid_synth_reverb_on (style_synth, -1, TRUE);
    fluid_synth_set_reverb_group_roomsize (style_synth, -1, reverb_room_size[level]);
    fluid_synth_set_reverb_group_damp (style_synth, -1, 0.1);
    fluid_synth_set_reverb_group_width (style_synth, -1, reverb_width[level]);
    fluid_synth_set_reverb_group_level (style_synth, -1, reverb_level[level]);
}

void
synthesizer_edit_master_chorus (int level) {
    fluid_synth_chorus_on (realtime_synth, -1, TRUE);
    fluid_synth_set_chorus_group_depth (realtime_synth, -1, chorus_depth[level]);
    fluid_synth_set_chorus_group_level (realtime_synth, -1, chorus_level[level]);
    fluid_synth_set_chorus_group_nr (realtime_synth, -1, chorus_nr[level]);

    fluid_synth_chorus_on (style_synth, -1, TRUE);
    fluid_synth_set_chorus_group_depth (style_synth, -1, chorus_depth[level]);
    fluid_synth_set_chorus_group_level (style_synth, -1, chorus_level[level]);
    fluid_synth_set_chorus_group_nr (style_synth, -1, chorus_nr[level]);
}

void
synthesizer_init (const gchar* loc) {
    style_synth_settings = new_fluid_settings();
    fluid_settings_setstr(style_synth_settings, "audio.driver", "alsa");
    fluid_settings_setint(style_synth_settings, "audio.periods", 16);
    fluid_settings_setint(style_synth_settings, "audio.period-size", 64);
    fluid_settings_setint(style_synth_settings, "audio.realtime-prio", 70);
    fluid_settings_setnum(style_synth_settings, "synth.gain", 2);
    fluid_settings_setnum(style_synth_settings, "synth.overflow.percussion", 5000.0);
    fluid_settings_setstr(style_synth_settings, "synth.midi-bank-select", "gs");

    realtime_synth_settings = new_fluid_settings();
    fluid_settings_setstr(realtime_synth_settings, "audio.driver", "alsa");
    fluid_settings_setint(realtime_synth_settings, "audio.periods", 8);
    fluid_settings_setint(realtime_synth_settings, "audio.realtime-prio", 70);
    fluid_settings_setnum(realtime_synth_settings, "synth.gain", 2);
    fluid_settings_setstr(realtime_synth_settings, "synth.midi-bank-select", "gs");

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
    }
    fx_init ();
    style_adriver = new_fluid_audio_driver2(style_synth_settings, fx_function, (void *) &fx_data);
    realtime_adriver = new_fluid_audio_driver(realtime_synth_settings, realtime_synth);
    synthesizer_edit_master_reverb (5);
    synthesizer_edit_master_chorus (1);
    fluid_synth_cc (realtime_synth, 0, 74, 40);
}

void
synthesizer_change_voice (int bank, int preset, int channel) {
    fluid_synth_program_select (realtime_synth, channel, realtime_synth_sf_id, bank, preset);
}


void
synthesizer_destruct () {
    if(style_adriver)
    {
        delete_fluid_audio_driver(style_adriver);
    }
    if(realtime_adriver)
    {
        delete_fluid_audio_driver(realtime_adriver);
    }
    if(style_synth)
    {
        delete_fluid_synth(style_synth);
    }
    if(realtime_synth)
    {
        delete_fluid_synth(realtime_synth);
    }
    if(style_synth_settings)
    {
        delete_fluid_settings(style_synth_settings);
    }
    if(realtime_synth_settings)
    {
        delete_fluid_settings(realtime_synth_settings);
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
    if (chan != 9 && accompaniment_enabled == 0 && type == 144) {
        return 0;
    } 
    // CC 74 CutOff Modulator 
    // fluid_synth_cc (style_synth, 0, 74, 80);
    return fluid_synth_handle_midi_event(style_synth, event);
}

int
synthesizer_send_notes (int key, int on, int velocity, int* type) {
    if (accompaniment_enabled > 0) {
        if (accompaniment_mode == 0) {
            if (key <= synthsizer_split_key) {
                int chrd_type = 0;
                int chrd_main = chord_finder_infer (key, on, &chrd_type);
                *type = chrd_type;
                if (central_style_looping == 0 && central_style_sync_start == 0 && on == 144) {
                    fluid_synth_all_notes_off (realtime_synth, 4);
                    fluid_synth_cc (realtime_synth, 3, 91, 0);
                    fluid_synth_cc (realtime_synth, 4, 91, 0);
                    fluid_synth_noteon (realtime_synth, 3, key + 12, velocity * 0.6);
                    fluid_synth_noteon (realtime_synth, 4, chrd_main + 36, velocity);
                    fluid_synth_noteon (realtime_synth, 5, key + 36, velocity * 0.2);
                    fluid_synth_noteon (realtime_synth, 5, key + 24, velocity * 0.4);
                }
                if (on == 128) {
                    fluid_synth_noteoff (realtime_synth, 3, key + 12);
                    fluid_synth_all_notes_off (realtime_synth, 4);
                    fluid_synth_noteoff (realtime_synth, 5, key + 36);
                    fluid_synth_noteoff (realtime_synth, 5, key + 24);
                }
                return chrd_main;
            }
        }
        
    }
    fluid_synth_cc (realtime_synth, 0, 91, 4);
    fluid_synth_cc (realtime_synth, 0, 93, 1);
    if (on == 144) {
        fluid_synth_noteon (realtime_synth, 0, key, velocity);
    } else if (on == 128) {
        fluid_synth_noteoff (realtime_synth, 0, key);
    }
    // int reverb;
    // fluid_synth_get_cc (realtime_synth, 0, 91, &reverb);
    // printf("%d\n", reverb);
    return -6;
}

void
synthesizer_halt_notes () {
    fluid_synth_all_notes_off (style_synth, 0);
    fluid_synth_all_notes_off (style_synth, 1);
    fluid_synth_all_notes_off (style_synth, 2);
    fluid_synth_all_notes_off (style_synth, 3);
    fluid_synth_all_notes_off (style_synth, 4);
    fluid_synth_all_notes_off (style_synth, 5);
    fluid_synth_all_notes_off (style_synth, 6);
    fluid_synth_all_notes_off (style_synth, 7);
    fluid_synth_all_notes_off (style_synth, 8);
    //fluid_synth_all_notes_off (style_synth, 9);
    fluid_synth_all_notes_off (style_synth, 10);
    fluid_synth_all_notes_off (style_synth, 11);
    fluid_synth_all_notes_off (style_synth, 12);
    fluid_synth_all_notes_off (style_synth, 13);
    fluid_synth_all_notes_off (style_synth, 14);
    fluid_synth_all_notes_off (style_synth, 15);
}


void synthesizer_set_accomp_enable (int on) {
    accompaniment_enabled = on;
}