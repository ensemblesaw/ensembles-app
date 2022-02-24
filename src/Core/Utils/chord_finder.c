/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "chord_finder.h"

int key_track[13];
int chord_possibility [120];

int
chord_finder_infer (int key, int on, int* type) {
    key_track [key % 12] = ((on == 144) ? 1 : 0);

    int n_keys = 0;
    for (int i = 0; i < 12; i++) {
        n_keys += key_track[i];
    }
    // printf("\n");

    int i = 0;

    if (n_keys < 4) {
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

    i = 0;
    int max = -1;
    int max_index = 0;
    for (; i < 72; i++) {
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
    }
    return -6;
}
