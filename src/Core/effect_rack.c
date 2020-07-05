/*
 * Copyright © 2020 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * Licensed under the GNU General Public License Version 3
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "effect_rack.h"

int 
effect_rack (void *data, int len,
                int nfx, float **fx,
                int nout, float **out)
{
    struct fx_data_t *fx_data = (struct fx_data_t *) data;
    /* Call the synthesizer to fill the output buffers with its
     * audio output. */
    if(fluid_synth_process(fx_data->synth, len, nfx, fx, nout, out) != FLUID_OK)
    {
        /* Some error occurred. Very unlikely to happen, though. */
        return FLUID_FAILED;
    }

    /* @todo:
     * Implement Effects here
     */

    return FLUID_OK;
}