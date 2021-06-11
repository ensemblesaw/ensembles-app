#include <pthread.h>
#include <stdio.h>
#include "central_bus.h"

int time_stamps[13];
int time_stamp_index;
void *style_analyser (char* style) {
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

    printf ("Analyzing...\n");
    for (long i = 0; i < filelen; i++) {
        if (*(buffer + i) == 0xffffffff) {
            //printf("meta\n");
            if (*(buffer + i + 1) == 0x06) {
                //printf("marker\n");
                int length = (*(buffer + i + 2));
                char* string = (char *) malloc (sizeof(char) * length);
                for (int j = 0; j < length; j++) {
                    *(string + j) = *(buffer + i + 3 + j);
                }
                char *e;
                e = strchr(string, ':');
                int index = (int)(e - string);
                int ticks = 0;
                if (index < length) {
                    char subbuff[length - index + 1];
                    memcpy (subbuff, &string[index + 1], length - index );
                    subbuff[length - index] = '\0';
                    ticks = atoi (subbuff);
                }
                time_stamps[time_stamp_index++] = (int)(ticks/2);
                printf ("%s %d\n", string, ticks);
                free(string);
                //string = NULL;
            }
        }
    }
    printf ("Done.\n");
    loaded_style_time_stamps = time_stamps;
}

void style_analyser_analyze (char* mid_file) {
    time_stamp_index = 0;
    // pthread_t thread_id;
    // pthread_create(&thread_id, NULL, style_analyser, mid_file);
    style_analyser (mid_file);
}