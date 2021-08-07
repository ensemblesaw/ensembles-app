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


#include <portmidi.h>
#include <stdio.h>
#include <string.h>
#include <gtk/gtk.h>



PortMidiStream* controller_input_stream;
gchar* controller_input_device_name;
int controller_input_device_available;
int controller_input_device_count;
int controller_input_device_names_length1 = 2;
int countroller_input_device_id_length1 = 2;

void
controller_init () {
    Pm_Initialize ();
}

void
controller_query_device_info (int id) {
    const PmDeviceInfo* device = Pm_GetDeviceInfo (id);
    if (device->input > 0) {
        controller_input_device_available = 1;
    }
    else {
        controller_input_device_available = 0;
    }
    controller_input_device_name = NULL;
    controller_input_device_name = (char*)malloc(sizeof(char*) * strlen (device->name));
    strcpy(controller_input_device_name, device->name);
}

int
controller_query_input_device_count () {
    //printf("%d\n", Pm_CountDevices ());
    return Pm_CountDevices ();
}


int
controller_connect_device (int id) {
    if (Pm_OpenInput (&controller_input_stream, id, NULL, 256, NULL, NULL) == 0) {
        printf("Connected\n");
        return 1;
    }
    return 0;
}

int
controller_poll_device() {
    return Pm_Poll (controller_input_stream);
}

int32_t
controller_read_device_stream () {
    PmEvent* controller_event_stream = (PmEvent*)malloc (sizeof (PmEvent)*256);
    Pm_Read (controller_input_stream, controller_event_stream, 256);
    return (controller_event_stream->message);
}

void
controller_close_connection () {
    Pm_Close (controller_input_stream);
}

void
controller_destruct () {
    Pm_Terminate ();
}
