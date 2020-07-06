#include <fluidsynth.h>
#include <gtk/gtk.h>

fluid_settings_t* settings;
fluid_synth_t* synth;
fluid_audio_driver_t* adriver;

void realtime_play_init (const gchar* loc) {
    
    int sfont_id;
    int i, note;

    settings = new_fluid_settings();

    synth = new_fluid_synth(settings);

    fluid_settings_setstr(settings, "audio.driver", "alsa");

    adriver = new_fluid_audio_driver(settings, synth);

    sfont_id = fluid_synth_sfload(synth, loc, 1);
    fluid_synth_program_select(synth, 0, sfont_id, 0, 81);   
}
void realtime_play_key () {
    fluid_synth_noteon (synth, 0, 67, 115);
}