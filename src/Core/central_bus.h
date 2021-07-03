

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

/**
 * @defgroup central_bus Central Bus
 *
 * Functions for managing central bus signals
 */


/** Central Clock becomes 1 every time a beat starts and then it goes to 0
 */
/** get_central_clock () gives you the current value of the clock
 */
int get_central_clock ();
/** set_central_clock () allows you to set the value manually, but it's not
 * recommended to use this function in your code unless it for resetting 
 * purposes (set to 0) only
 */
void set_central_clock (int value);




/** Central halt signal is used to stop all synthesizer sounds except the
 * ones in channel 10 i.e. drums
 * Its also used by the UI to stop UI events where necessary
 */
int get_central_halt ();
void set_central_halt (int value);


int* get_loaded_style_time_stamps ();
int get_loaded_style_time_stamps_by_index (int index);
void set_loaded_style_time_stamps (int* value);


#endif /* CENTRAL_BUS_H */