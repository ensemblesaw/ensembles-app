/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "voice_analyser.h"

fluid_synth_t* sf_synth;

fluid_sfloader_t* sf_loader;
fluid_sfont_t* soundfont;
fluid_preset_t* _soundfont_preset;

const gchar* sf_preset_name;
int sf_preset_bank_num;
int sf_preset_num;

int
voice_analyser_init(const gchar* sf_path)
{
    sf_synth = get_synthesizer(UTILITY);

    if (fluid_is_soundfont(sf_path))
    {
        fluid_synth_sfload(sf_synth, sf_path, 1);
        soundfont = fluid_synth_get_sfont(sf_synth, 0);
    }
    else
    {
        return -1;
    }
    fluid_sfont_iteration_start (soundfont);
    return 0;
}

int
voice_analyser_next()
{
    _soundfont_preset = fluid_sfont_iteration_next(soundfont);
    if (_soundfont_preset == NULL)
    {
        return 0;
    }
    sf_preset_name = fluid_preset_get_name(_soundfont_preset);
    sf_preset_bank_num = fluid_preset_get_banknum(_soundfont_preset);
    sf_preset_num = fluid_preset_get_num(_soundfont_preset);
    return 1;
}
