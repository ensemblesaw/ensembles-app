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

#include "chord_finder.h"

int key_track[13];
int chord_possibility [24];

int
chord_finder_infer (int key, int on, int* type) {
    // /printf("%d\n", key);

    //printf("%d\n", key % 12);
    key_track [key % 12] = ((on == 144) ? 1 : 0);
    // for (int i = 0; i < 12; i++) {
    //     printf ("%d ", key_track[i]);
    // }
    // printf("\n");

    int i = 0;
    // Major
    for (; i < 5; i++) {
        chord_possibility [i] = 3*key_track[i] + key_track[i + 4] + key_track[i + 7];
    }
    for (; i < 9; i++) {
        chord_possibility [i] = key_track[i - 5] + 3*key_track[i] + key_track[i + 4];
        //printf ("%d\n", chord_possibility[i]);
    }
    for (; i < 12; i++) {
        chord_possibility [i] = key_track[i - 8] + key_track[i - 5] + 3*key_track[i];
    }
    // Minor
    for (; i < 17; i++) {
        chord_possibility [i] = 3*key_track[i - 12] + key_track[i - 12 + 3] + key_track[i - 12 + 7];
    }
    for (; i < 21; i++) {
        chord_possibility [i] = key_track[i -12 - 5] + 3*key_track[i - 12] + key_track[i - 12 + 3];
    }
    for (; i < 24; i++) {
        chord_possibility [i] = key_track[i - 12 - 9] + key_track[i - 12 - 5] + 3*key_track[i - 12];
    }

    i = 0;
    int max = -1;
    int max_index = 0;
    for (; i < 24; i++) {
        // /printf ("%d ", chord_possibility[i]);
        if (max < chord_possibility[i]) {
            max = chord_possibility[i];
            max_index = i;
        }
    }
    if (on == 128) {
        return -6;
    }

    if (max_index >= 12) {
        *type = 1;
    } else {
        *type = 0;
    }

    if (max > 0) {
        if (max_index >= 0 && max_index <= 6) {
            return max_index;
        }
        else if (max_index >= 7 && max_index <= 18){
            return max_index - 12;
        }
        else if (max_index >= 19) {
            return max_index - 24;
        }
    }
    
    
    return -6;
}
