/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "chord_finder.h"

int key_track[13];
int chord_possibility[144];

int
chord_finder_infer (int key, int on, int* type) {
    key_track [key % 12] = ((on == 144) ? 1 : 0);

    int n_keys = 0;
    for (int i = 0; i < 12; i++) {
        n_keys += key_track[i];
    }
    // printf("\n");
    for (int i = 0; i < 144; i++) {
        chord_possibility[i] = 0;
    }

    int i = 0;

    if (n_keys < 4)
    {
        // Major
        for (; i < 5; i++) {
            chord_possibility [i] = 6 * key_track[i] + key_track[i + 4] + key_track[i + 7];
        }
        for (; i < 9; i++) {
            chord_possibility [i] = key_track[i - 5] + 6 * key_track[i] + key_track[i + 4];
        }
        for (; i < 12; i++) {
            chord_possibility [i] = key_track[i - 8] + key_track[i - 5] + 6 * key_track[i];
        }

        // minor
        for (; i < 17; i++) {
            chord_possibility [i] = 6 * key_track[i - 12] + key_track[i - 12 + 3] + key_track[i - 12 + 7];
        }
        for (; i < 21; i++) {
            chord_possibility [i] = key_track[i - 12 - 5] + 6 * key_track[i - 12] + key_track[i - 12 + 3];
        }
        for (; i < 24; i++) {
            chord_possibility [i] = key_track[i - 12 - 9] + key_track[i - 12 - 5] + 6 * key_track[i - 12];
        }

        // diminished
        for (; i < 29; i++) {
            chord_possibility [i] = 6 * key_track[i - 24] + key_track[i - 24 + 3] + key_track[i - 24 + 6];
        }
        for (; i < 33; i++) {
            chord_possibility [i] = key_track[i - 24 + 6] + 6 * key_track[i - 24] + key_track[i - 24 + 3];
        }
        for (; i < 36; i++) {
            chord_possibility [i] = key_track[i - 24 - 9] + key_track[i - 24 - 6] + 6 * key_track[i - 24];
        }

        // suspended 2
        for (; i < 41; i++) {
            chord_possibility [i] = 6 * key_track[i - 36] + key_track[i - 36 + 2] + key_track[i - 36 + 7];
        }
        for (; i < 45; i++) {
            chord_possibility [i] = key_track[i - 36 - 5] + 6 * key_track[i - 36] + key_track[i - 36 + 2];
        }
        for (; i < 48; i++) {
            chord_possibility [i] = key_track[i - 36 - 10] + key_track[i - 36 - 5] + 6 * key_track[i - 36];
        }

        // suspended 4
        for (; i < 53; i++) {
            chord_possibility [i] = 7 * key_track[i - 48] + key_track[i - 48 + 5] + key_track[i - 48 + 7];
        }
        for (; i < 57; i++) {
            chord_possibility [i] = key_track[i - 48 - 5] + 7 * key_track[i - 48] + key_track[i - 48 + 5];
        }
        for (; i < 60; i++) {
            chord_possibility [i] = key_track[i - 48 - 7] + key_track[i - 48 - 5] + 7 * key_track[i - 48];
        }

        // augmented
        for (; i < 65; i++) {
            chord_possibility [i] = 6 * key_track[i - 60] + key_track[i - 60 + 4] + key_track[i - 60 + 8];
        }
        for (; i < 69; i++) {
            chord_possibility [i] = key_track[i - 60 - 4] + 6 * key_track[i - 60] + key_track[i - 60 + 4];
        }
        for (; i < 72; i++) {
            chord_possibility [i] = key_track[i - 60 - 8] + key_track[i - 60 - 4] + 6 * key_track[i - 60];
        }
    }
    else if (n_keys == 4)
    {
        // Dominant Sixth
        for (i = 72; i < 77; i++) {
            chord_possibility [i] = 6 * key_track[i - 72] + key_track[i - 72 + 4] + key_track[i - 72 + 7] + key_track[i - 72 + 9];
        }
        for (; i < 81; i++) {
            chord_possibility [i] = key_track[i - 72 - 5] + key_track[i - 72 - 3] + 6 * key_track[i - 72] + key_track[i - 72 + 4];
        }
        for (; i < 84; i++) {
            chord_possibility [i] = key_track[i - 72 - 8] + key_track[i - 72 - 5] + key_track[i - 72 - 3] + 6 * key_track[i - 72];
        }

        // Dominant Seventh
        for (; i < 89; i++) {
            chord_possibility [i] = 6 * key_track[i - 84] + key_track[i - 84 + 4] + key_track[i - 84 + 7] + key_track[i - 84 + 10];
        }
        for (; i < 93; i++) {
            chord_possibility [i] = key_track[i - 84 - 5] + key_track[i - 84 - 2] + 6 * key_track[i - 84] + key_track[i - 84 + 4];
        }
        for (; i < 96; i++) {
            chord_possibility [i] = key_track[i - 84 - 8] + key_track[i - 84 - 5] + key_track[i - 84 - 2] + 6 * key_track[i - 84];
        }

        // Major Seventh
        for (; i < 101; i++) {
            chord_possibility [i] = 6 * key_track[i - 96] + key_track[i - 96 + 4] + key_track[i - 96 + 7] + key_track[i - 96 + 11];
        }
        for (; i < 105; i++) {
            chord_possibility [i] = key_track[i - 96 - 5] + key_track[i - 96 - 1] + 6 * key_track[i - 96] + key_track[i - 96 + 4];
        }
        for (; i < 108; i++) {
            chord_possibility [i] = key_track[i - 96 - 8] + key_track[i - 96 - 5] + key_track[i - 96 - 1] + 6 * key_track[i - 96];
        }

        // minor seventh
        for (; i < 113; i++) {
            chord_possibility [i] = 6 * key_track[i - 108] + key_track[i - 108 + 3] + key_track[i - 108 + 7] + key_track[i - 108 + 10];
        }
        for (; i < 117; i++) {
            chord_possibility [i] = key_track[i - 108 - 5] + key_track[i - 108 - 2] + 6 * key_track[i - 108] + key_track[i - 108 + 3];
        }
        for (; i < 120; i++) {
            chord_possibility [i] = key_track[i - 108 - 9] + key_track[i - 108 - 5] + key_track[i - 108 - 2] + 6 * key_track[i - 108];
        }

        // add9
        for (; i < 125; i++) {
            chord_possibility [i] = 6 * key_track[i - 120] + key_track[i - 120 + 4] + key_track[i - 120 + 7] + key_track[i - 120 + 2];
        }
        for (; i < 129; i++) {
            chord_possibility [i] = key_track[i - 120 - 5] + key_track[i - 120  + 2] + 6 * key_track[i - 120] + key_track[i - 120 + 4];
        }
        for (; i < 132; i++) {
            chord_possibility [i] = key_track[i - 120 - 8] + key_track[i - 120 - 5] + key_track[i - 120 - 10] + 6 * key_track[i - 120];
        }
    }
    else if (n_keys == 5)
    {
        // Dominant 9th
        for (; i < 137; i++) {
            chord_possibility [i] = 6 * key_track[i - 132] + key_track[i - 132 + 4] + key_track[i - 132 + 7] + key_track[i - 132 + 10] + key_track[i - 132 + 2];
        }
        for (; i < 141; i++) {
            chord_possibility [i] = key_track[i - 132 - 5] + key_track[i - 132 - 2] + key_track[i - 120  + 2] + 6 * key_track[i - 132] + key_track[i - 132 + 4];
        }
        for (; i < 144; i++) {
            chord_possibility [i] = key_track[i - 132 - 8] + key_track[i - 132 - 5] + key_track[i - 132 - 2] + 6 * key_track[i - 132] + key_track[i - 120 - 10];
        }
    }


    i = n_keys < 4 ? 0 : n_keys == 4 ? 72 : 132;
    int max_i = n_keys < 4 ? 72 : n_keys == 4 ? 132 : 144;
    int max = -1;
    int max_index = 0;
    for (; i < max_i; i++) {
        printf ("%d ", chord_possibility[i]);
        if (max < chord_possibility[i]) {
            max = chord_possibility[i];
            max_index = i;
        }
    }
    printf("\n%d  ----------\n", max_index);
    if (on == 128)
    {
        return -6;
    }

    if (max_index < 12)
    {
        *type = 0;
    }
    else if (max_index < 24)
    {
        *type = 1;
    }
    else if (max_index < 36)
    {
        *type = 2;
    }
    else if (max_index < 48)
    {
        *type = 3;
    }
    else if (max_index < 60)
    {
        *type = 4;
    }
    else if (max_index < 72)
    {
        *type = 5;
    }
    else if (max_index < 84)
    {
        *type = 6;
    }
    else if (max_index < 96)
    {
        *type = 7;
    }
    else if (max_index < 108)
    {
        *type = 8;
    }
    else if (max_index < 120)
    {
        *type = 9;
    }
    else if (max_index < 132)
    {
        *type = 10;
    }
    else
    {
        *type = 11;
    }

    if (max > 0) {
        if (max_index >= 0 && max_index <= 6)
        {
            return max_index;
        }
        else if (max_index >= 7 && max_index <= 18)
        {
            return max_index - 12;
        }
        else if (max_index >= 19 && max_index <= 30)
        {
            return max_index - 24;
        }
        else if (max_index >= 31 && max_index <= 42)
        {
            return max_index - 36;
        }
        else if (max_index >= 43 && max_index <= 54)
        {
            return max_index - 48;
        }
        else if (max_index >= 55 && max_index <= 66)
        {
            return max_index - 60;
        }
        else if (max_index >= 67 && max_index <= 78)
        {
            return max_index - 72;
        }
        else if (max_index >= 79 && max_index <= 90)
        {
            return max_index - 84;
        }
        else if (max_index >= 91 && max_index <= 102)
        {
            return max_index - 96;
        }
        else if (max_index >= 103 && max_index <= 114)
        {
            return max_index - 108;
        }
        else if (max_index >= 115 && max_index <= 126)
        {
            return max_index - 120;
        }
        else if (max_index >= 127 && max_index <= 138)
        {
            return max_index - 132;
        }
        else if (max_index >= 139 && max_index <= 156)
        {
            return max_index - 150;
        }
    }
    return -6;
}
