/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class JoyStick : Gtk.Grid {
        Gtk.Button x_assign_button;
        Gtk.Button y_assign_button;
        public bool assignable;
        public int assignable_axis = -1;

        Gtk.Fixed touch_feedback_region;
        Gtk.Box touch_feedback;

        public bool dragging;
        private double initial_x;
        private double initial_y;

        private double x_value = 64;
        private double y_value = 64;

        public signal void drag_x (double value);
        public signal void drag_y (double value);
        public signal void assignable_clicked_x (bool assignable);
        public signal void assignable_clicked_y (bool assignable);
        public JoyStick () {
            touch_feedback_region = new Gtk.Fixed () {
                width_request = 140,
                height_request = 140,
                halign = Gtk.Align.CENTER,
                valign = Gtk.Align.CENTER
            };
            touch_feedback = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                width_request = 60,
                height_request = 60
            };
            touch_feedback.get_style_context ().add_class ("touch-feedback");
            touch_feedback_region.put (touch_feedback, 40, 40);

            x_assign_button = new Gtk.Button.with_label (_("X-Assign"));
            x_assign_button.clicked.connect (() => {
                assignable = !assignable;
                y_assign_button.sensitive = !assignable;
                assignable_axis = 0;
                assignable_clicked_x (assignable);
            });
            y_assign_button = new Gtk.Button.with_label (_("Y-Assign"));
            y_assign_button.clicked.connect (() => {
                assignable = !assignable;
                x_assign_button.sensitive = !assignable;
                assignable_axis = 1;
                assignable_clicked_y (assignable);
            });
            var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                margin_top = 4,
                margin_bottom = 4,
                margin_start = 4,
                margin_end = 4,
                width_request = 140
            };
            button_box.append (x_assign_button);
            button_box.append (y_assign_button);
            attach (button_box, 0, 0, 1, 1);

            var main_overlay = new Gtk.Overlay () {
                height_request = 150,
                width_request = 150,
                halign = Gtk.Align.CENTER,
                valign = Gtk.Align.CENTER
            };

            var main_box = new Gtk.Grid () {
                vexpand = true,
                margin_start = 4,
                margin_end = 4,
                margin_top = 4,
                margin_bottom = 4
            };
            main_box.get_style_context ().add_class ("joystick-pad");

            var event_box = new Gtk.EventBox ();
            event_box.event.connect (handle_event);
            event_box.vexpand = true;

            main_overlay.add (main_box);
            main_overlay.add_overlay (touch_feedback_region);
            main_overlay.add_overlay (event_box);
            attach (main_overlay, 0, 1, 1, 1);
            get_style_context ().add_class ("joystick-background");
        }

        public void make_all_sensitive () {
            x_assign_button.sensitive = true;
            y_assign_button.sensitive = true;
        }

        public bool handle_event (Gdk.Event event) {
            if (event.type == Gdk.EventType.BUTTON_PRESS) {
                initial_x = event.motion.x_root;
                initial_y = event.motion.y_root;
                dragging = true;
                show_touch_feedback (true);
            }
            if (event.type == Gdk.EventType.BUTTON_RELEASE) {
                initial_x = 0;
                initial_y = 0;
                dragging = false;
                x_value = 64;
                y_value = 64;
                drag_x (64);
                drag_y (64);
                show_touch_feedback (false);
            }

            if (event.type == Gdk.EventType.MOTION_NOTIFY && dragging) {
                double x = event.motion.x_root - initial_x;
                double y = event.motion.y_root - initial_y;
                x = (127.0 / 120.0) * (x + 60.0);
                y = (127.0 / 120.0) * (y + 60.0);
                if (x >= 0 && x <= 127) {
                    x_value = x;
                    drag_x (x);
                }
                if (y >= 0 && y <= 127) {
                    y_value = y;
                    drag_y (127.0 - y);
                }
            }
            update_touch_feedback_position ();
            return false;
        }

        private void show_touch_feedback (bool show) {
            if (show) {
                touch_feedback.get_style_context ().add_class ("touch-feedback-active");
            } else {
                touch_feedback.get_style_context ().remove_class ("touch-feedback-active");
            }
        }

        private void update_touch_feedback_position () {
            double x_coordinate = (80.0 / 127.0) * x_value;
            double y_coordinate = (80.0 / 127.0) * y_value;
            touch_feedback_region.move (touch_feedback, (int) x_coordinate, (int) y_coordinate);
        }
    }
}
