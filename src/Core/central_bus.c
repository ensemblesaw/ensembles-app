
/*-
 * Copyright (c) 2021-2021 Subhadeep Jasu <subhajasu@gmail.com>
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

#include "central_bus.h"


// Clock measure signals
int central_clock;
int get_central_clock () {
    return central_clock;
}
void set_central_clock (int value) {
    central_clock = value;
}
int central_halt;
int get_central_halt () {
    return central_halt;
}
void set_central_halt (int value) {
    central_halt = value;
}

// Ready signals
int styles_ready;
int get_styles_ready () {
    return styles_ready;
}
void set_styles_ready (int value) {
    styles_ready = value;
}

// UI signals
int* loaded_style_time_stamps;
int* get_loaded_style_time_stamps () {
    return loaded_style_time_stamps;
}
int get_loaded_style_time_stamps_by_index (int index) {
    return *(loaded_style_time_stamps + index);
}
void set_loaded_style_time_stamps (int* value) {
    loaded_style_time_stamps = value;
}
int central_style_section;
int get_central_style_section () {
    return central_style_section;
}
void set_central_style_section (int value) {
    central_style_section = value;
}
int central_time_signature;
int get_central_time_signature () {
    return central_time_signature;
}
void set_central_time_signature (int value) {
    central_time_signature = value;
}
int central_measure;
int get_central_measure () {
    return central_measure;
}
void set_central_measure (int value) {
    central_measure = value;
}
int central_tempo;
int get_central_tempo () {
    return central_tempo;
}
void set_central_tempo (int value) {
    central_tempo = value;
}
int central_loaded_tempo;
int get_central_loaded_tempo () {
    return central_loaded_tempo;
}
void set_central_loaded_tempo (int value) {
    central_loaded_tempo = value;
}


// Style parameters
int central_style_looping;
int get_central_style_looping () {
    return central_style_looping;
}
void set_central_style_looping (int value) {
    central_style_looping = value;
}
int central_style_sync_start;
int get_central_style_sync_start () {
    return central_style_sync_start;
}
void set_central_style_sync_start (int value) {
    central_style_sync_start = value;
}
int central_style_original_chord_type;
int get_central_style_original_chord_type () {
    return central_style_original_chord_type;
}
void set_central_style_original_chord_type (int value) {
    central_style_original_chord_type = value;
}

// Voice parameters
int central_split_key = 54;
int get_central_split_key () {
    return central_split_key;
}
void set_central_split_key (int value) {
    central_split_key = value;
}
int central_accompaniment_mode = 0;
int get_central_accompaniment_mode () {
    return central_accompaniment_mode;
}
void set_central_accompaniment_mode (int value) {
    central_accompaniment_mode = value;
}
int central_split_on;
int get_central_split_on () {
    return central_split_on;
}
void set_central_split_on (int value) {
    central_split_on = value;
}
int central_layer_on;
int get_central_layer_on () {
    return central_layer_on;
}
void set_central_layer_on (int value) {
    central_layer_on = value;
}