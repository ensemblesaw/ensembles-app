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

#include "driver_settings_provider.h"

fluid_settings_t* fs_style_engine_settings;
fluid_settings_t* fs_style_synth_settings;
fluid_settings_t* fs_realtime_synth_settings;
fluid_settings_t* fs_metronome_player_settings;
fluid_settings_t* fs_song_player_settings;

int alsa_driver_found = 0;
int pulseaudio_driver_found = 0;
int pipewire_driver_found = 0;
int pipewire_pulse_driver_found = 0;

char* currently_selected_driver;

void
driver_settings_provider_init (char* driver, double period_size) {
    printf(driver);
    printf("\n%lf\n", period_size);
    printf("\n");
    if (fs_style_engine_settings == NULL) {
        if (strcmp (driver, "alsa") == 0) {
            currently_selected_driver = "alsa";
            fs_style_engine_settings = new_fluid_settings ();
            fluid_settings_setstr(fs_style_engine_settings, "audio.driver", "alsa");
            fluid_settings_setint(fs_style_engine_settings, "audio.periods",16);
            fluid_settings_setint(fs_style_engine_settings, "audio.period-size", (int)(86.0 + (period_size * 938.0)));
            fluid_settings_setint(fs_style_engine_settings, "audio.realtime-prio", 70);
        }
    }
    if (fs_style_synth_settings == NULL) {
        if (strcmp (driver, "alsa") == 0) {
            fs_style_synth_settings = new_fluid_settings ();
            fluid_settings_setstr(fs_style_synth_settings, "audio.driver", "alsa");
            fluid_settings_setint(fs_style_synth_settings, "audio.periods",16);
            fluid_settings_setint(fs_style_synth_settings, "audio.period-size", (int)(86.0 + (period_size * 938.0)));
            fluid_settings_setint(fs_style_synth_settings, "audio.realtime-prio", 70);
        }
        fluid_settings_setnum(fs_style_synth_settings, "synth.gain", 2);
        fluid_settings_setnum(fs_style_synth_settings, "synth.overflow.percussion", 5000.0);
        fluid_settings_setstr(fs_style_synth_settings, "synth.midi-bank-select", "gs");
    }
    if (fs_realtime_synth_settings == NULL) {
        if (strcmp (driver, "alsa") == 0) {
            fs_realtime_synth_settings = new_fluid_settings ();
            fluid_settings_setstr(fs_realtime_synth_settings, "audio.driver", "alsa");
            fluid_settings_setint(fs_realtime_synth_settings, "audio.periods",8);
            fluid_settings_setint(fs_realtime_synth_settings, "audio.period-size", (int)(86.0 + (period_size * 938.0)));
            fluid_settings_setint(fs_realtime_synth_settings, "audio.realtime-prio", 80);
        }
        fluid_settings_setnum(fs_realtime_synth_settings, "synth.gain", 2);
        fluid_settings_setnum(fs_realtime_synth_settings, "synth.overflow.percussion", 5000.0);
        fluid_settings_setstr(fs_realtime_synth_settings, "synth.midi-bank-select", "gs");
    }
    if (fs_metronome_player_settings == NULL) {
        if (strcmp (driver, "alsa") == 0) {
            fs_metronome_player_settings = new_fluid_settings ();
            fluid_settings_setstr(fs_metronome_player_settings, "audio.driver", "alsa");
            fluid_settings_setint(fs_metronome_player_settings, "audio.periods",2);
            fluid_settings_setint(fs_metronome_player_settings, "audio.period-size", (int)(128.0 + (period_size * 1024.0)));
        }
    }
    if (fs_song_player_settings == NULL) {
        if (strcmp (driver, "alsa") == 0) {
            fs_song_player_settings = new_fluid_settings ();
            fluid_settings_setstr(fs_song_player_settings, "audio.driver", "alsa");
            fluid_settings_setint(fs_song_player_settings, "audio.periods",16);
            fluid_settings_setint(fs_song_player_settings, "audio.period-size", 1024);
        }
    }
}

int
driver_settings_change_period_size (double period_size) {
    if (currently_selected_driver) {
        if (strcmp (currently_selected_driver, "alsa") == 0) {
            fluid_settings_setint(fs_style_engine_settings, "audio.period-size", (int)(86.0 + (period_size * 938.0)));
            fluid_settings_setint(fs_style_synth_settings, "audio.period-size", (int)(86.0 + (period_size * 938.0)));
            fluid_settings_setint(fs_realtime_synth_settings, "audio.period-size", (int)(86.0 + (period_size * 938.0)));
            fluid_settings_setint(fs_metronome_player_settings, "audio.period-size", (int)(128.0 + (period_size * 1024.0)));
            printf ("%lf\n", period_size);
            return (int)(86.0 + (period_size * 938.0));
        }
    }
    return 0;
}

fluid_settings_t*
get_settings (enum SynthLocation synth_location) {
    switch (synth_location) {
        case STYLE_SYNTH:
        return fs_style_synth_settings;
        case STYLE_ENGINE:
        return fs_style_engine_settings;
        case REALTIME_SYNTH:
        return fs_realtime_synth_settings;
        case METRONOME_PLAYER:
        return fs_metronome_player_settings;
        case MIDI_SONG_PLAYER:
        return fs_song_player_settings;
    }
    return NULL;
}
