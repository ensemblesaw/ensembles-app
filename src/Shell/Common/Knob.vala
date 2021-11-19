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
    public class Knob : Gtk.Overlay {
        public string tooltip;
        public bool dragging;
        private double dragging_direction;

        public double value = 27;
        protected Gtk.Box knob_socket_graphic;
        protected Gtk.Box knob_cover;
        protected Gtk.Box knob_background;
        protected Gtk.Fixed fixed;
        protected int center;

        protected const double RADIUS = 10;

        public signal void change_value (double value);

        public Knob () {
            center = 25;
            knob_socket_graphic = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            knob_socket_graphic.width_request = 5;
            knob_socket_graphic.height_request = 5;
            knob_socket_graphic.get_style_context ().add_class ("knob-socket-graphic");

            knob_cover = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            knob_cover.get_style_context ().add_class ("knob-cover-graphic");
            knob_cover.halign = Gtk.Align.START;
            knob_cover.valign = Gtk.Align.START;
            knob_cover.margin_start = 4;
            knob_cover.width_request = 50;
            knob_cover.height_request = 50;

            fixed = new Gtk.Fixed ();
            fixed.halign = Gtk.Align.START;
            fixed.valign = Gtk.Align.START;
            fixed.margin_start = 4;
            fixed.width_request = 50;
            fixed.height_request = 50;
            double px = RADIUS * GLib.Math.cos (value / Math.PI);
            double py = RADIUS * GLib.Math.sin (value / Math.PI);
            fixed.put (knob_socket_graphic, (int)(px + center), (int)(py + center));

            knob_background = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            knob_background.halign = Gtk.Align.START;
            knob_background.valign = Gtk.Align.START;
            knob_background.margin_start = 4;
            knob_background.width_request = 50;
            knob_background.height_request = 50;

            var event_box = new Gtk.EventBox ();
            event_box.event.connect (handle_event);
            event_box.hexpand = true;
            event_box.vexpand = true;

            add_overlay (knob_background);
            add_overlay (knob_cover);
            add_overlay (fixed);
            add_overlay (event_box);

            this.hexpand = false;
            this.vexpand = true;
            this.width_request = 58;
            this.height_request = 52;
        }

        public void rotate_dial (double value) {
            double px = RADIUS * GLib.Math.cos (value / Math.PI);
            double py = RADIUS * GLib.Math.sin (value / Math.PI);
            fixed.move (knob_socket_graphic, (int)(px + center), (int)(py + center));
            change_value ((value - 27.0) / 15.0);
        }

        public void set_value (double _value) {
            value = 15 * _value + 27;
            double px = RADIUS * GLib.Math.cos (value / Math.PI);
            double py = RADIUS * GLib.Math.sin (value / Math.PI);
            fixed.move (knob_socket_graphic, (int)(px + center), (int)(py + center));
        }

        public bool handle_event (Gdk.Event event) {
            //  if (event.type == Gdk.EventType.ENTER_NOTIFY) {
            //      set_cursor_from_name ("ew-resize");
            //  }
            //  if (event.type == Gdk.EventType.LEAVE_NOTIFY) {
            //      set_cursor (Gdk.CursorType.ARROW);
            //  }
            if (event.type == Gdk.EventType.BUTTON_PRESS) {
                dragging = true;
            }
            if (event.type == Gdk.EventType.BUTTON_RELEASE) {
                dragging = false;
                dragging_direction = 0;
            }

            if (event.type == Gdk.EventType.MOTION_NOTIFY && dragging) {
                if (dragging_direction == 0) {
                    dragging_direction = event.motion.y - event.motion.x;
                }
                if (dragging_direction > event.motion.y - event.motion.x ||
                    event.motion.y_root == 0 ||
                    event.motion.x_root == 0) {
                    value += 0.5;
                    if (value < 27) {
                        value = 27;
                    }
                    if (value > 42) {
                        value = 42;
                    }
                    rotate_dial (value);
                    dragging_direction = event.motion.y - event.motion.x;
                } else {
                    value -= 0.5;
                    if (value < 27) {
                        value = 27;
                    }
                    if (value > 42) {
                        value = 42;
                    }
                    rotate_dial (value);
                    dragging_direction = event.motion.y - event.motion.x;
                }
            }
            return true;
        }
    }
}
