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
        fs_style_engine_settings = new_fluid_settings ();
        if (strcmp (driver, "alsa") == 0) {
            currently_selected_driver = "alsa";
            fluid_settings_setstr(fs_style_engine_settings, "audio.driver", "alsa");
            fluid_settings_setint(fs_style_engine_settings, "audio.periods",16);
            fluid_settings_setint(fs_style_engine_settings, "audio.period-size", (int)(86.0 + (period_size * 938.0)));
            fluid_settings_setint(fs_style_engine_settings, "audio.realtime-prio", 70);
        }
        if (strcmp (driver, "pulseaudio") == 0) {
            currently_selected_driver = "pulseaudio";
            fluid_settings_setstr(fs_style_engine_settings, "audio.driver", "pulseaudio");
            fluid_settings_setint(fs_style_engine_settings, "audio.periods",2);
            fluid_settings_setint(fs_style_engine_settings, "audio.period-size", (int)(64.0 + (period_size * 448.0)));
            fluid_settings_setint(fs_style_engine_settings, "audio.realtime-prio", 80);
            fluid_settings_setint(fs_style_engine_settings, "audio.pulseaudio.adjust-latency", 0);
        }
        if (strcmp (driver, "pipewire-pulse") == 0) {
            currently_selected_driver = "pipewire-pulse";
            fluid_settings_setstr(fs_style_engine_settings, "audio.driver", "pulseaudio");
            fluid_settings_setint(fs_style_engine_settings, "audio.periods",2);
            fluid_settings_setint(fs_style_engine_settings, "audio.period-size", (int)(128.0 + (period_size * 896.0)));
        }
        if (strcmp (driver, "pipewire") == 0) {
            currently_selected_driver = "pipewire";
            fluid_settings_setstr(fs_style_engine_settings, "audio.driver", "pipewire");
            fluid_settings_setint(fs_style_engine_settings, "audio.period-size", 64);
        }
    }
    if (fs_style_synth_settings == NULL) {
        fs_style_synth_settings = new_fluid_settings ();
        if (strcmp (driver, "alsa") == 0) {
            fluid_settings_setstr(fs_style_synth_settings, "audio.driver", "alsa");
            fluid_settings_setint(fs_style_synth_settings, "audio.periods",16);
            fluid_settings_setint(fs_style_synth_settings, "audio.period-size", (int)(86.0 + (period_size * 938.0)));
            fluid_settings_setint(fs_style_synth_settings, "audio.realtime-prio", 70);
        }
        if (strcmp (driver, "pulseaudio") == 0) {
            fluid_settings_setstr(fs_style_synth_settings, "audio.driver", "pulseaudio");
            fluid_settings_setint(fs_style_synth_settings, "audio.periods", 8);
            fluid_settings_setint(fs_style_synth_settings, "audio.period-size", (int)(1024.0 + (period_size * 3072.0)));
            fluid_settings_setint(fs_style_synth_settings, "audio.realtime-prio", 70);
        }
        if (strcmp (driver, "pipewire-pulse") == 0) {
            fluid_settings_setstr(fs_style_synth_settings, "audio.driver", "pulseaudio");
            fluid_settings_setint(fs_style_synth_settings, "audio.periods", 8);
            fluid_settings_setint(fs_style_synth_settings, "audio.period-size", (int)(1024.0 + (period_size * 3072.0)));
        }
        if (strcmp (driver, "pipewire") == 0) {
            fluid_settings_setstr(fs_style_synth_settings, "audio.driver", "pipewire");
            fluid_settings_setint(fs_style_synth_settings, "audio.period-size", 64);
            fluid_settings_setint(fs_style_synth_settings, "audio.realtime-prio", 1);
            fluid_settings_setstr(fs_style_synth_settings, "audio.pipewire.media-role", "Production");
            fluid_settings_setstr(fs_style_synth_settings, "audio.pipewire.media-type", "Audio");
        }
        fluid_settings_setnum(fs_style_synth_settings, "synth.gain", 2);
        fluid_settings_setnum(fs_style_synth_settings, "synth.overflow.percussion", 5000.0);
        fluid_settings_setstr(fs_style_synth_settings, "synth.midi-bank-select", "gs");
    }
    if (fs_realtime_synth_settings == NULL) {
        fs_realtime_synth_settings = new_fluid_settings ();
        if (strcmp (driver, "alsa") == 0) {
            fluid_settings_setstr(fs_realtime_synth_settings, "audio.driver", "alsa");
            fluid_settings_setint(fs_realtime_synth_settings, "audio.periods",8);
            fluid_settings_setint(fs_realtime_synth_settings, "audio.period-size", (int)(86.0 + (period_size * 938.0)));
            fluid_settings_setint(fs_realtime_synth_settings, "audio.realtime-prio", 80);
        }
        if (strcmp (driver, "pulseaudio") == 0) {
            fluid_settings_setstr(fs_realtime_synth_settings, "audio.driver", "pulseaudio");
            fluid_settings_setint(fs_realtime_synth_settings, "audio.periods",2);
            fluid_settings_setint(fs_realtime_synth_settings, "audio.period-size", (int)(1024.0 + (period_size * 3072.0)));
            fluid_settings_setint(fs_realtime_synth_settings, "audio.realtime-prio", 90);
            fluid_settings_setint(fs_realtime_synth_settings, "audio.pulseaudio.adjust-latency", 0);
        }
        if (strcmp (driver, "pipewire-pulse") == 0) {
            fluid_settings_setstr(fs_realtime_synth_settings, "audio.driver", "pulseaudio");
            fluid_settings_setint(fs_realtime_synth_settings, "audio.periods",2);
            fluid_settings_setint(fs_realtime_synth_settings, "audio.period-size", (int)(1024.0 + (period_size * 3072.0)));
            fluid_settings_setint(fs_realtime_synth_settings, "audio.pulseaudio.adjust-latency", 0);
        }
        if (strcmp (driver, "pipewire") == 0) {
            fluid_settings_setstr(fs_realtime_synth_settings, "audio.driver", "pipewire");
            fluid_settings_setint(fs_realtime_synth_settings, "audio.period-size", 64);
            fluid_settings_setint(fs_realtime_synth_settings, "audio.pulseaudio.adjust-latency", 0);
            fluid_settings_setstr(fs_realtime_synth_settings, "audio.pipewire.media-role", "Production");
            fluid_settings_setstr(fs_realtime_synth_settings, "audio.pipewire.media-type", "Audio");
        }
        fluid_settings_setnum(fs_realtime_synth_settings, "synth.gain", 2);
        fluid_settings_setnum(fs_realtime_synth_settings, "synth.overflow.percussion", 5000.0);
        fluid_settings_setstr(fs_realtime_synth_settings, "synth.midi-bank-select", "gs");
    }
    if (fs_metronome_player_settings == NULL) {
        fs_metronome_player_settings = new_fluid_settings ();
        if (strcmp (driver, "alsa") == 0) {
            fluid_settings_setstr(fs_metronome_player_settings, "audio.driver", "alsa");
            fluid_settings_setint(fs_metronome_player_settings, "audio.periods",4);
            fluid_settings_setint(fs_metronome_player_settings, "audio.period-size", (int)(128.0 + (period_size * 1024.0)));
        }
        if (strcmp (driver, "pulseaudio") == 0 || strcmp (driver, "pipewire-pulse") == 0) {
            fluid_settings_setstr(fs_metronome_player_settings, "audio.driver", "pulseaudio");
            fluid_settings_setint(fs_metronome_player_settings, "audio.periods",2);
            fluid_settings_setint(fs_metronome_player_settings, "audio.period-size", (int)(1024.0 + (period_size * 1024.0)));
        }
        if (strcmp (driver, "pipewire") == 0) {
            fluid_settings_setstr(fs_metronome_player_settings, "audio.driver", "pipewire");
            fluid_settings_setint(fs_metronome_player_settings, "audio.period-size", 64);
        }
    }
    if (fs_song_player_settings == NULL) {
        fs_song_player_settings = new_fluid_settings ();
        if (strcmp (driver, "alsa") == 0) {
            fluid_settings_setstr(fs_song_player_settings, "audio.driver", "alsa");
            fluid_settings_setint(fs_song_player_settings, "audio.periods",16);
            fluid_settings_setint(fs_song_player_settings, "audio.period-size", 1024);
        }
        if (strcmp (driver, "pulseaudio") == 0 || strcmp (driver, "pipewire-pulse") == 0) {
            fluid_settings_setstr(fs_song_player_settings, "audio.driver", "pulseaudio");
            fluid_settings_setint(fs_song_player_settings, "audio.periods",16);
            fluid_settings_setint(fs_song_player_settings, "audio.period-size", 4096);
        }
        if (strcmp (driver, "pipewire") == 0) {
            fluid_settings_setstr(fs_song_player_settings, "audio.driver", "pipewire");
            fluid_settings_setint(fs_song_player_settings, "audio.period-size", 128);
            fluid_settings_setstr(fs_song_player_settings, "audio.pipewire.media-role", "Music");
            fluid_settings_setstr(fs_song_player_settings, "audio.pipewire.media-type", "Audio");
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
            return (int)(86.0 + (period_size * 938.0));
        }
        if (strcmp (currently_selected_driver, "pulseaudio") == 0) {
            fluid_settings_setint(fs_style_engine_settings, "audio.period-size", (int)(86.0 + (period_size * 938.0)));
            fluid_settings_setint(fs_style_synth_settings, "audio.period-size", (int)(1024.0 + (period_size * 3072.0)));
            fluid_settings_setint(fs_realtime_synth_settings, "audio.period-size", (int)(1024.0 + (period_size * 3072.0)));
            fluid_settings_setint(fs_metronome_player_settings, "audio.period-size", (int)(1024.0 + (period_size * 1024.0)));
            return (int)(1024.0 + (period_size * 3072.0));
        }
        if (strcmp (currently_selected_driver, "pipewire-pulse") == 0) {
            fluid_settings_setint(fs_style_engine_settings, "audio.period-size", (int)(128.0 + (period_size * 896.0)));
            fluid_settings_setint(fs_style_synth_settings, "audio.period-size", (int)(1024.0 + (period_size * 3072.0)));
            fluid_settings_setint(fs_realtime_synth_settings, "audio.period-size", (int)(1024.0 + (period_size * 3072.0)));
            fluid_settings_setint(fs_metronome_player_settings, "audio.period-size", (int)(1024.0 + (period_size * 1024.0)));
            return (int)(1024.0 + (period_size * 3072.0));
        }
        if (strcmp (currently_selected_driver, "pipewire") == 0) {
            fluid_settings_setint(fs_style_engine_settings, "audio.period-size", 64);
            fluid_settings_setint(fs_style_synth_settings, "audio.period-size", 64);
            fluid_settings_setint(fs_realtime_synth_settings, "audio.period-size", 64);
            fluid_settings_setint(fs_metronome_player_settings, "audio.period-size", 64);
            return (int)(64.0 + (period_size * 128.0));
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
