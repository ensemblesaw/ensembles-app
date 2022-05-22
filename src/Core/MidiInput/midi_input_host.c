/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "midi_input_host.h"
#include "../Synthesizer/synthesizer.h"

PortMidiStream **controller_input_stream;
char* controller_input_device_name;
int controller_input_device_available;
int controller_input_device_count;
int controller_input_device_names_length1 = 2;
int countroller_input_device_id_length1 = 2;

fluid_midi_driver_t *fluid_midi_driver;
fluid_settings_t *midi_settings;

static int
controller_handle_midi_event(void *data, fluid_midi_event_t *midi_event )
{
    int channel = fluid_midi_event_get_channel (midi_event);
    fluid_midi_event_t *new_event = new_fluid_midi_event ();

    fluid_midi_event_set_channel (new_event, channel);
    fluid_midi_event_set_control (new_event, fluid_midi_event_get_control (midi_event));
    fluid_midi_event_set_pitch (new_event, fluid_midi_event_get_pitch (midi_event));
    fluid_midi_event_set_program (new_event, fluid_midi_event_get_program (midi_event));
    fluid_midi_event_set_value (new_event, fluid_midi_event_get_value (midi_event));
    fluid_midi_event_set_velocity (new_event, fluid_midi_event_get_velocity (midi_event));
    fluid_midi_event_set_type (new_event, fluid_midi_event_get_type (midi_event));

    return handle_events_for_midi_players(new_event, 1);
}

void
controller_init (int fluid_input)
{

    if (fluid_input == 1)
    {
        midi_settings = new_fluid_settings();
        fluid_midi_driver = new_fluid_midi_driver (midi_settings, controller_handle_midi_event, NULL);
    } else {
        Pm_Initialize ();
    }
}

void
controller_query_device_info (int id)
{
    const PmDeviceInfo* device = Pm_GetDeviactive_devicesceInfo (id);
    if (device->input > 0)
    {
        controller_input_device_available = 1;
    }
    else
    {
        controller_input_device_available = 0;
    }
    controller_input_device_name = NULL;
    controller_input_device_name = (char *)malloc(sizeof(char *) * strlen (device->name));
    strcpy(controller_input_device_name, device->name);
}

int
controller_query_input_device_count () {
    int len = Pm_CountDevices ();
    controller_input_stream = (PortMidiStream *)malloc(sizeof(PortMidiStream *) * len);
    return len;
}


int
controller_connect_device (int id) {
    if (Pm_OpenInput (&controller_input_stream[id], id, NULL, 256, NULL, NULL) == 0) {
        return 1;
    }
    return 0;
}

int
controller_poll_device(int id) {
    return Pm_Poll (controller_input_stream[id]);
}

int32_t
controller_read_device_stream (int id) {
    PmEvent* controller_event_stream = (PmEvent *)malloc (sizeof (PmEvent)*256);
    Pm_Read (controller_input_stream[id], controller_event_stream, 256);
    return (controller_event_stream->message);
}

void
controller_close_connection (int id) {
    Pm_Close (controller_input_stream[id]);
}

void
controller_destruct ()
{
    Pm_Terminate ();

    if (midi_settings)
    {
        delete_fluid_settings(midi_settings);
    }

    if (fluid_midi_driver)
    {
        delete_fluid_midi_driver(fluid_midi_driver);
    }
}
