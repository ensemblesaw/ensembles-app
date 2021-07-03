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

namespace Ensembles.Shell { 
    public class WheelScrollableWidget : Gtk.Grid { 
        public int scroll_wheel_location;
        public WheelScrollableWidget () {
            width_request = 424;
            height_request = 213;
        }
        public void scroll_wheel_scroll (bool direction, int amount) {
            if (direction) {
                scroll_wheel_location += amount;
            } else {
                scroll_wheel_location -= amount;
            }
        }
    }
}