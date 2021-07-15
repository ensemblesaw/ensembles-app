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
    public class EqualizerBar : Gtk.Bin {
        //  DrawingArea drawing_area;
        private int _velocity;
        public int velocity {
            get {
                return _velocity;
            }
            set {
                _velocity = 127 - value;
                queue_draw ();
            }
        }
        public EqualizerBar () {
            set_size_request (19, 40);
            velocity = 0;
        }

        public override bool draw (Cairo.Context cr) {
            cr.move_to (0, 0);
            cr.set_source_rgba (0.6, 0.6, 0.6, 0.2);
            for (int i = 0; i < 7; i++) {
                cr.rectangle (0, i * 5, 19, 4);
            }
            cr.fill ();
            cr.set_source_rgba (0.42, 0.56, 0.015, 1);
            for (int i = 6; i >= 0; i--) {
                cr.rectangle (0, i * 5, 19, 4);
                if (i * 16 < _velocity) {
                    break;
                }
                cr.fill ();
            }

            return base.draw (cr);
        }
    }
}
