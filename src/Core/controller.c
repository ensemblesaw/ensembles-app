/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
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
    return Pm_CountDevices ();
}


int
controller_connect_device (int id) {
    if (Pm_OpenInput (&controller_input_stream, id, NULL, 256, NULL, NULL) == 0) {
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
