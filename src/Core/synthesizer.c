#include <fluidsynth.h>
#include <gtk/gtk.h>
#include "central_bus.h"

fluid_synth_t* style_synth;
fluid_settings_t* style_synth_settings;
fluid_audio_driver_t* style_adriver;

fluid_synth_t* realtime_synth;
fluid_settings_t* realtime_synth_settings;
fluid_audio_driver_t* realtime_adriver;

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
        for(k = 0; k < len; k++)
        {
            out_i[k] *= fx_data->gain;
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
synthesizer_init (const gchar* loc) {
    style_synth_settings = new_fluid_settings();
    fluid_settings_setstr(style_synth_settings, "audio.driver", "alsa");
    fluid_settings_setint(style_synth_settings, "audio.periods", 16);
    fluid_settings_setint(style_synth_settings, "audio.period-size", 86);
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
        fluid_synth_sfload(realtime_synth, loc, 1);
    }
    fx_init ();
    style_adriver = new_fluid_audio_driver2(style_synth_settings, fx_function, (void *) &fx_data);
    realtime_adriver = new_fluid_audio_driver(realtime_synth_settings, realtime_synth);
}


void
synthesizer_destruct () {
    if(style_adriver)
    {
        delete_fluid_audio_driver(style_adriver);
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

    return fluid_synth_handle_midi_event(style_synth, event);
}

int
synthesizer_send_notes (int key, int on, int velocity) {
    if (on == 144) {
        fluid_synth_noteon (realtime_synth, 0, key, velocity);
    } else if (on == 128) {
        fluid_synth_noteoff (realtime_synth, 0, key);
    }
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