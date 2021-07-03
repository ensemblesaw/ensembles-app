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

#ifndef CENTRAL_BUS_H
#define CENTRAL_BUS_H

/** Central Clock becomes 1 every time a beat starts and then it goes to 0
 */
/** This function gives you the current value of the clock
 */
int get_central_clock ();
/** This function allows you to set the value manually, but it's not
 * recommended to use this function in your code unless it's for resetting 
 * purposes (set to 0) only
 */
void set_central_clock (int value);




/** Central halt signal is used to stop all synthesizer sounds except the
 * ones in channel 10 i.e. drums
 * Its also used by the UI to stop UI events where necessary
 */
/** This function gives you the current value of halt signal
 */ 
int get_central_halt ();
/** This is used to rais a halt signal
 */
void set_central_halt (int value);

/** Ready signals are used to notify the rest of the application that a 
 * particular module is ready. Useful for controlling certain UI elements
 * show based on whether the underlying system is ready.
 */
/** Returns 1 if styles modules are ready
 * and 0 if still processing
 */
int get_styles_ready ();
/** set_style_ready (int value) is used to raise styles ready signal
 */
void set_styles_ready (int value);

/** UI signals are used to communicate with the UI frontend.
 */

/** Used to get the style ticks or time stamps
 */
int* get_loaded_style_time_stamps ();
/** Used to get style time stamps from particular stored index
 */
int get_loaded_style_time_stamps_by_index (int index);
/** Used to set style time stamps or ticks based on style parts
 */
void set_loaded_style_time_stamps (int* value);

/** The function returns the time stamp index for the currently playing
 * part of style
 */
int get_central_style_section ();
/** This function is used to set the currently playing style part
 */
void set_central_style_section (int value);

/** This function returns the current time signature value as loaded
 * from the style file after analysis
 */
int get_central_time_signature ();
/** Used by style_analyser to set the time signature of the current style
 */
void set_central_time_signature (int value);

/** This function returns the current value of measure of the playing style
 */
int get_central_measure ();
/** This function is used by the style_player to increment the measure value
 */
void set_central_measure (int value);


int get_central_tempo ();
void set_central_tempo (int value);

/** This function returns the current tempo of the style in BPM
 */
int get_central_loaded_tempo ();
/** This function can be used by style analyser to set tempo of loaded style
 * in BPM. It is also used by style_player after modifying tempo to a custom
 * value; either from previous style in a continuation or from the user
 */
void set_central_loaded_tempo (int value);

/** This function returns 1 if the style is playing else it returns 0
 */
int get_central_style_looping ();
/** This function is used by style_player to set the style looping signal
 * based on whether the style is currenty playing
 */
void set_central_style_looping (int value);

/** This function returns 1 if sync start is on else it returns 0
 */
int get_central_style_sync_start ();
/** This function can be used to set sync start on or off (1 or 0)
 */
void set_central_style_sync_start (int value);

/** This function returns the chord type that the style was originally recorded
 * on:
 * 0 : Major
 * 1 : Minor
 */
int get_central_style_original_chord_type ();
/** This function is used by style analyser to set the original chord type
 * (major or minor) the style was recorded on
 */
void set_central_style_original_chord_type (int value);

/** This function returns the current keyboard split key number
 */
int get_central_split_key ();
/** This function can be used to set keyboard plit key number
 */
void set_central_split_key (int value);

/** This function returns 1 if chord is on else it returns 0
 */
int get_central_accompaniment_mode ();
/** This function can be used to set chord mode on
 */
void set_central_accompaniment_mode (int value);

/** This function return 1 if keyboard split is enabled
 */
int get_central_split_on ();

/** This function is used to set keyboard split on / off
 */
void set_central_split_on (int value);

/** This function returns 1 if layering is on else it returns 0
 */
int get_central_layer_on ();
/** This function can be used to set layering mode on / off
 */
void set_central_layer_on (int value);


#endif /* CENTRAL_BUS_H */
