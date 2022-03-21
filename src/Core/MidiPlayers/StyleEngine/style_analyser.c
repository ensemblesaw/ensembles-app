/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "style_analyser.h"

int time_stamps[15];
int time_stamp_index;

int time_signature_n;
int time_signature_d;

char config_delimiters[3] = { ':', ';', ',' };

char* copyright_string;

int
style_analyser (char* style)
{
    FILE *fp;
    char *buffer = NULL;
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
        // Find the copyright notice
        if (*(buffer + i) == 0xffffffff && *(buffer + i + 1) == 0x02)
        {
            int length = (*(buffer + i + 2));
            if (copyright_string)
            {
                free(copyright_string);
            }
            copyright_string = (char *) calloc(length, sizeof(char));
            for (int j = 0; j < length; j++)
            {
                *(copyright_string + j) = *(buffer + i + 3 + j);
            }
        }
        // Find the ticks per beat from MTHD header
        if (*(buffer + i) == 0x4D) {
            if (*(buffer + i + 1) == 0x54)
            {
                if (*(buffer + i + 2) == 0x68)
                {
                    if (*(buffer + i + 3) == 0x64)
                    {
                        int a = *(buffer + i + 12);
                        int b = *(buffer + i + 13);
                        ticks_per_beat = (a << 8) | (b & 0x000000ff);
                        //printf ("Ticks: ///////// %d //////\n", ticks_per_beat);
                    }
                }
            }
        }

        if (*(buffer + i) == 0xffffffff && ticks_per_beat > 0)
        {
            // Find time signature
            if (*(buffer + i + 1) == 0x58)
            {
                if (*(buffer + i + 2) == 0x04)
                {
                    time_signature_n = *(buffer + i + 3);
                    set_central_beats_per_bar (time_signature_n);
                    time_signature_d = pow (2, *(buffer + i + 4));
                    set_central_quarter_notes_per_bar (time_signature_d);
                    //printf ("Time Signature = %d/%d\n", time_signature_n, time_signature_d);
                }
            }

            // Get marker data
            if (*(buffer + i + 1) == 0x06)
            {
                // Get marker string length
                int length = (*(buffer + i + 2));
                char* string = (char *) malloc (sizeof(char) * length);
                for (int j = 0; j < length; j++)
                {
                    *(string + j) = *(buffer + i + 3 + j);
                }
                // Get Measure
                char *e;
                e = strchr(string, config_delimiters[0]);
                int index_measure = (int)(e - string);
                int measure = 0;
                if (index_measure < length && index_measure > 0)
                {
                    char subbuff[length - index_measure + 1];
                    memcpy (subbuff, &string[index_measure + 1], length - index_measure );
                    subbuff[length - index_measure] = '\0';
                    measure = atoi (subbuff);
                }

                // Get Tempo
                int tempo = 0;
                char* f;
                f = strchr(string, config_delimiters[1]);
                int index_tempo = (int)(f - string);
                if (index_tempo < length && index_tempo > 0)
                {
                    char subbuff[length - index_tempo + 1];
                    memcpy (subbuff, &string[index_tempo + 1], length - index_tempo );
                    subbuff[length - index_tempo] = '\0';
                    tempo = atoi (subbuff);
                    if (tempo > 30)
                    {
                        set_central_tempo (tempo);
                        set_central_loaded_tempo (tempo);
                    }
                }

                // Get Scale Type (whether the style is recorded in major or minor)
                int chord_type = 0;
                char* g;
                g = strchr(string, config_delimiters[2]);
                int index_chord_type = (int)(g - string);
                if (index_chord_type < length && index_chord_type > 0)
                {
                    char subbuff[length - index_chord_type + 1];
                    memcpy (subbuff, &string[index_chord_type + 1], length - index_chord_type );
                    subbuff[length - index_chord_type] = '\0';
                    chord_type = atoi (subbuff);
                    set_central_style_original_chord_type (chord_type);
                }

                // Record timestamp from the marker (convert measure to timestamp)
                time_stamps[time_stamp_index++] = (int)(((measure - 1) * 4 * time_signature_n  * ticks_per_beat) / time_signature_d);
                //printf ("Style: /// %d %s %d\n", time_stamp_index - 1, string, time_stamps[time_stamp_index-1]);
                free(string);
            }
        }
    }
    // All timestamps loaded, store it somewhere
    set_loaded_style_time_stamps (time_stamps);
    return get_central_loaded_tempo ();
}

int
style_analyser_analyze (char* mid_file)
{
    time_stamp_index = 0;
    time_signature_n = 4;
    time_signature_d = 4;
    return style_analyser (mid_file);
}
