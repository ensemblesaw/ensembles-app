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

fluid_settings_t* sf_settings;
fluid_synth_t* sf_synth;

fluid_sfloader_t* sf_loader;
fluid_sfont_t* soundfont;
fluid_preset_t* _soundfont_preset;

const gchar* sf_preset_name;
int sf_preset_bank_num;
int sf_preset_num;

int
voice_analyser_init (const gchar* sf_path) {
    sf_settings = new_fluid_settings();
    sf_synth = new_fluid_synth(sf_settings);
    // sf_loader = new_fluid_defsfloader (sf_settings);
    // fluid_sfloader_set_callbacks(sf_loader,
    //                             my_open,
    //                             my_read,
    //                             my_seek,
    //                             my_tell,
    //                             my_close);
    // fluid_synth_add_sfloader(sf_synth, sf_loader);

    if (fluid_is_soundfont(sf_path)) {
        int id = fluid_synth_sfload(sf_synth, sf_path, 1);
        soundfont = fluid_synth_get_sfont (sf_synth, 0);
    } else {
        return -1;
    }
    fluid_sfont_iteration_start (soundfont);
    return 0;
}

int
voice_analyser_next () {
    _soundfont_preset = fluid_sfont_iteration_next (soundfont);
    if (_soundfont_preset == NULL) {
        return 0;
    }
    sf_preset_name = fluid_preset_get_name (_soundfont_preset);
    sf_preset_bank_num = fluid_preset_get_banknum (_soundfont_preset);
    sf_preset_num = fluid_preset_get_num (_soundfont_preset);
    //printf ("%d-%d -> %s\n", sf_preset_bank_num, sf_preset_num, sf_preset_name);
    return 1;
}

void
voice_analyser_deconstruct () {
    delete_fluid_synth(sf_synth);
    delete_fluid_settings(sf_settings);
}