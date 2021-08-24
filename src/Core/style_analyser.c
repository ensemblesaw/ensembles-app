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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "style_analyser.h"
#include "central_bus.h"

int time_stamps[14];
int time_stamp_index;

int time_signature_n;
int time_signature_d;

// long from_seq(char *in)
// {
// 	long r = 0;
 
// 	do {
// 		r = (r << 7) | (long)(*in & 127);
// 	} while (*in++ & 128);
 
// 	return r;
// }

int
style_analyser (char* style) {
    FILE *fp;
    char *buffer;
    long filelen;

    fp = fopen(style, "rb");  // Open the file in binary mode
    fseek(fp, 0, SEEK_END);
    filelen = ftell(fp);
    rewind (fp);

    buffer = (char *)malloc(filelen * sizeof (char));
    if (fread(buffer, filelen, 1, fp) == 0) {
        printf ("Error: Invalid style\n");
    }
    fclose(fp);
    int ticks_per_beat = 0;

    for (long i = 0; i < filelen; i++) {
        if (*(buffer + i) == 0x4D) {
            if (*(buffer + i + 1) == 0x54) {
                if (*(buffer + i + 2) == 0x68) {
                    if (*(buffer + i + 3) == 0x64) {
                        int a = *(buffer + i + 12);
                        int b = *(buffer + i + 13);
                        ticks_per_beat = (a << 8) | (b & 0x000000ff);
                        printf ("Ticks: ///////// %d //////\n", ticks_per_beat);
                    }
                }
            }
        }
        if (*(buffer + i) == 0xffffffff && ticks_per_beat > 0) {
            if (*(buffer + i + 1) == 0x58) {
                if (*(buffer + i + 2) == 0x04) {
                    time_signature_n = *(buffer + i + 3);
                    set_central_beats_per_bar (time_signature_n);
                    time_signature_d = pow (2, *(buffer + i + 4));
                    set_central_quarter_notes_per_bar (time_signature_d);
                    printf ("Time Signature = %d/%d\n", time_signature_n, time_signature_d);
                }
            }
            if (*(buffer + i + 1) == 0x06) {
                int length = (*(buffer + i + 2));
                char* string = (char *) malloc (sizeof(char) * length);
                for (int j = 0; j < length; j++) {
                    *(string + j) = *(buffer + i + 3 + j);
                }
                char *e;
                e = strchr(string, ':');
                int index_measure = (int)(e - string);
                int measure = 0;
                if (index_measure < length && index_measure > 0) {
                    char subbuff[length - index_measure + 1];
                    memcpy (subbuff, &string[index_measure + 1], length - index_measure );
                    subbuff[length - index_measure] = '\0';
                    measure = atoi (subbuff);
                }
                int tempo = 0;
                char* f;
                f = strchr(string, ';');
                int index_tempo = (int)(f - string);
                if (index_tempo < length && index_tempo > 0) {
                    char subbuff[length - index_tempo + 1];
                    memcpy (subbuff, &string[index_tempo + 1], length - index_tempo );
                    subbuff[length - index_tempo] = '\0';
                    tempo = atoi (subbuff);
                    if (tempo > 30) {
                        set_central_tempo (tempo);
                        set_central_loaded_tempo (tempo);
                    }
                }
                int chord_type = 0;
                char* g;
                g = strchr(string, ',');
                int index_chord_type = (int)(g - string);
                if (index_chord_type < length && index_chord_type > 0) {
                    char subbuff[length - index_chord_type + 1];
                    memcpy (subbuff, &string[index_chord_type + 1], length - index_chord_type );
                    subbuff[length - index_chord_type] = '\0';
                    chord_type = atoi (subbuff);
                    set_central_style_original_chord_type (chord_type);
                }
                time_stamps[time_stamp_index++] = (int)(((measure - 1) * 4 * time_signature_n  * ticks_per_beat) / time_signature_d);
                printf ("Style: /// %s %d\n", string, time_stamps[time_stamp_index-1]);
                free(string);
                //string = NULL;
            }
            // if (*(buffer + i + 1) == 0x51) {
            //     if (*(buffer + i + 2) == 0x03) {
            //         char tempo_bytes[3];
            //         tempo_bytes[0] = *(buffer + i + 3);
            //         tempo_bytes[1] = *(buffer + i + 4);
            //         tempo_bytes[2] = *(buffer + i + 5);
            //         printf ("Tempo = %x\n", from_seq (tempo_bytes));
            //     }
            // }
        }
    }
    set_loaded_style_time_stamps (time_stamps);
    return get_central_loaded_tempo ();
}

int
style_analyser_analyze (char* mid_file) {
    time_stamp_index = 0;
    time_signature_n = 4;
    time_signature_d = 4;
    return style_analyser (mid_file);
}
