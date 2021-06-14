#include <stdio.h>
#include "central_bus.h"

int time_stamps[14];
int time_stamp_index;

// long from_seq(char *in)
// {
// 	long r = 0;
 
// 	do {
// 		r = (r << 7) | (long)(*in & 127);
// 	} while (*in++ & 128);
 
// 	return r;
// }

void*
style_analyser (char* style) {
    FILE *fp;
    char *buffer;
    long filelen;

    fp = fopen(style, "rb");  // Open the file in binary mode
    fseek(fp, 0, SEEK_END);
    filelen = ftell(fp);
    rewind (fp);

    buffer = (char *)malloc(filelen * sizeof (char));
    fread(buffer, filelen, 1, fp);
    fclose(fp);

    for (long i = 0; i < filelen; i++) {
        if (*(buffer + i) == 0xffffffff) {
            if (*(buffer + i + 1) == 0x06) {
                int length = (*(buffer + i + 2));
                char* string = (char *) malloc (sizeof(char) * length);
                for (int j = 0; j < length; j++) {
                    *(string + j) = *(buffer + i + 3 + j);
                }
                char *e;
                e = strchr(string, ':');
                int index_ticks = (int)(e - string);
                int ticks = 0;
                if (index_ticks < length && index_ticks > 0) {
                    char subbuff[length - index_ticks + 1];
                    memcpy (subbuff, &string[index_ticks + 1], length - index_ticks );
                    subbuff[length - index_ticks] = '\0';
                    ticks = atoi (subbuff);
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
                    if (tempo > 10) {
                        central_tempo = tempo;
                        central_loaded_tempo = tempo;
                    }
                }
                time_stamps[time_stamp_index++] = (int)(ticks/2);
                //printf ("%s %d %d\n", string, ticks, central_loaded_tempo);
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
    loaded_style_time_stamps = time_stamps;
    return central_loaded_tempo;
}

int
style_analyser_analyze (char* mid_file) {
    time_stamp_index = 0;
    // pthread_t thread_id;
    // pthread_create(&thread_id, NULL, style_analyser, mid_file);
    return style_analyser (mid_file);
}