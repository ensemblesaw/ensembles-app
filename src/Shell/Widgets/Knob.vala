/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class Knob : Gtk.Box {
        public string tooltip;
        public bool dragging;
        private double dragging_direction_x;
        private double dragging_direction_y;

        public double value = 27;
        public int drag_force = 0;
        protected Gtk.Box knob_socket_graphic;
        protected Gtk.Box knob_cover;
        protected Gtk.Box knob_background;
        protected Gtk.Fixed fixed;
        protected int center;

        protected const double RADIUS = 10;

        public signal void change_value (double value);

        public Knob () {
            center = 25;
            knob_socket_graphic = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                width_request = 5,
                height_request = 5
            };
            knob_socket_graphic.get_style_context ().add_class ("knob-socket-graphic");

            knob_cover = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true,
                vexpand = true,
                margin_start = 4,
                margin_end = 4,
                margin_top = 4,
                margin_bottom = 4,
                halign = Gtk.Align.CENTER,
                valign = Gtk.Align.CENTER,
                width_request = 50,
                height_request = 50
            };
            knob_cover.get_style_context ().add_class ("knob-cover-graphic");

            fixed = new Gtk.Fixed () {
                hexpand = true,
                vexpand = true,
                margin_start = 4,
                margin_end = 4,
                margin_top = 4,
                margin_bottom = 4,
                halign = Gtk.Align.CENTER,
                valign = Gtk.Align.CENTER,
                width_request = 50,
                height_request = 50
            };
            double px = RADIUS * GLib.Math.cos (value / Math.PI);
            double py = RADIUS * GLib.Math.sin (value / Math.PI);
            fixed.put (knob_socket_graphic, (int)(px + center), (int)(py + center));

            knob_background = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true,
                vexpand = true,
                halign = Gtk.Align.CENTER,
                valign = Gtk.Align.CENTER,
                margin_start = 4,
                margin_end = 4,
                margin_top = 4,
                margin_bottom = 4,
                width_request = 50,
                width_request = 50
            };

            var event_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true,
                vexpand = true
            };
            //  event_box.event.connect (handle_event);

            var overlay = new Gtk.Overlay ();
            overlay.set_child (knob_background);
            overlay.add_overlay (knob_cover);
            overlay.add_overlay (fixed);
            overlay.add_overlay (event_box);

            append (overlay);

            this.hexpand = true;
            this.vexpand = true;
            this.halign = Gtk.Align.FILL;
            this.valign = Gtk.Align.FILL;
            this.width_request = 58;
            this.height_request = 58;
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

        //  public bool handle_event (Gdk.Event event) {
        //      //  if (event.type == Gdk.EventType.ENTER_NOTIFY) {
        //      //      set_cursor_from_name ("ew-resize");
        //      //  }
        //      //  if (event.type == Gdk.EventType.LEAVE_NOTIFY) {
        //      //      set_cursor (Gdk.CursorType.ARROW);
        //      //  }
        //      if (event.type == Gdk.EventType.BUTTON_PRESS) {
        //          dragging = true;
        //      }
        //      if (event.type == Gdk.EventType.BUTTON_RELEASE) {
        //          dragging = false;
        //          dragging_direction_x = 0;
        //          dragging_direction_y = 0;
        //      }

        //      if (event.type == Gdk.EventType.MOTION_NOTIFY && dragging) {
        //          if (dragging_direction_x == 0) {
        //              dragging_direction_x = event.motion.x;
        //          }
        //          if (dragging_direction_y == 0) {
        //              dragging_direction_y = event.motion.y;
        //          }
        //          double delta = 0.0;
        //          if (dragging_direction_x > event.motion.x || event.motion.x_root == 0) {
        //              delta -= 0.1 * (dragging_direction_x - event.motion.x);
        //              dragging_direction_x = event.motion.x;
        //          } else {
        //              delta += 0.1 * (event.motion.x - dragging_direction_x);
        //              dragging_direction_x = event.motion.x;
        //          }
        //          if (dragging_direction_y > event.motion.y || event.motion.y_root == 0) {
        //              delta += 0.1 * (dragging_direction_y - event.motion.y);
        //              dragging_direction_y = event.motion.y;
        //          } else {
        //              delta -= 0.1 * (event.motion.y - dragging_direction_y);
        //              dragging_direction_y = event.motion.y;
        //          }
        //          value += delta;
        //          if (value < 27) {
        //              value = 27;
        //          }
        //          if (value > 42) {
        //              value = 42;
        //          }
        //          rotate_dial (value);
        //      }
        //      return false;
        //  }
    }
}
