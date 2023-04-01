/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Widgets {
    /**
     * This widget represents a knob that can be rotate either using mouse,
     * wheel or using finger gestures.
     */
    public class Knob : Gtk.Widget, Gtk.Accessible {
        public Gtk.Adjustment adjustment { get; set; }
        public double value {
            get {
                return adjustment.value;
            }
            set {
                adjustment.value = value;
                pointing_angle = map_range (adjustment.lower,
                pointing_angle_lower,
                adjustment.upper,
                pointing_angle_lower + pointing_angle_upper,
                value);
            }
        }

        private Gtk.BinLayout bin_layout;
        protected Gtk.Box knob_socket_graphic;
        protected Gtk.Box knob_cover;
        protected Gtk.DrawingArea knob_meter;
        protected Gtk.Box knob_background;

        private Gtk.GestureRotate touch_rotation_gesture;
        private Gtk.GestureDrag drag_gesture;
        private Gtk.EventControllerScroll wheel_gesture;

        public double pointing_angle { get; private set; }
        public double pointing_angle_lower { get; protected set; }
        public double pointing_angle_upper { get; protected set; }
        private double current_deg;
        private double previous_deg;

        public bool show_value { get; set; }
        public bool show_lower_bar { get; set; }
        public bool show_upper_bar { get; set; }

        private uint radius = 0;

        public signal void value_changed ();

        public Knob ()
        {
            Object (
                name: "knob",
                accessible_role: Gtk.AccessibleRole.SPIN_BUTTON
            );

            pointing_angle = pointing_angle_lower;
        }

        construct {
            pointing_angle_upper = 275;
            pointing_angle_lower = 135;
            show_value = true;
            show_upper_bar = true;
            show_lower_bar = true;
            build_layout ();
            realize.connect (() => {
                build_ui ();
            });
            build_events ();
        }

        private void build_layout () {
            adjustment = new Gtk.Adjustment (0, 0, 101,
                1, 1, 1);
            bin_layout = new Gtk.BinLayout ();
            set_layout_manager (bin_layout);
        }

        private void build_ui () {
            add_css_class ("knob");

            var width = get_allocated_width () | width_request;
            var height = get_allocated_height () | height_request;

            var diameter = width < height ? width : height;

            radius = diameter / 2;

            if (knob_background == null) {
                knob_background = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                    halign = Gtk.Align.CENTER,
                    valign = Gtk.Align.CENTER
                };
                knob_background.add_css_class ("knob-background");
                knob_background.set_parent (this);
            }
            knob_background.width_request = diameter;
            knob_background.height_request = diameter;

            if (knob_cover == null) {
                knob_cover = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                    halign = Gtk.Align.CENTER,
                    valign = Gtk.Align.CENTER
                };
                knob_cover.add_css_class ("knob-cover");
                knob_cover.set_parent (this);
            }

            knob_cover.width_request = diameter;
            knob_cover.height_request = diameter;

            if (knob_meter == null) {
                knob_meter = new Gtk.DrawingArea () {
                    halign = Gtk.Align.CENTER,
                    valign = Gtk.Align.CENTER,
                    width_request = diameter,
                    height_request = diameter
                };
                knob_meter.set_parent (this);

                knob_meter.set_draw_func (draw_meter);
            }

            knob_meter.width_request = diameter;
            knob_meter.height_request = diameter;
        }

        public override void size_allocate (int width, int height, int baseline) {
            base.size_allocate (width, height, baseline);
        }

        protected void draw_meter (Gtk.DrawingArea meter, Cairo.Context ctx, int width, int height) {
            var gb = adjustment.value / (adjustment.upper - adjustment.lower);
            // Draw arc
            ctx.arc (radius + 0.2, radius, radius - 7,
                pointing_angle_lower * (Math.PI/180.0),
                pointing_angle * (Math.PI/180.0));
            ctx.set_line_width (2);
            ctx.set_source_rgba (1 - gb, gb, gb, 1);
            ctx.stroke ();

            if (show_lower_bar) {
                ctx.arc (radius + 0.2, radius, radius - 2,
                    pointing_angle_lower * (Math.PI/180.0),
                    (pointing_angle_lower + 3) * (Math.PI/180.0));
                ctx.set_line_width (4);
                ctx.set_source_rgba (1, 1, 1, adjustment.value == adjustment.lower ? 1 : 0.3);
                ctx.stroke ();
            }

            if (show_upper_bar) {
                ctx.arc (radius + 0.2, radius, radius - 2,
                    (pointing_angle_lower + pointing_angle_upper - 3) * (Math.PI/180.0),
                    (pointing_angle_lower + pointing_angle_upper) * (Math.PI/180.0));
                ctx.set_source_rgba (1, 1, 1, adjustment.value >= adjustment.upper - 1 ? 1 : 0.3);
                ctx.stroke ();
            }

            if (show_value) {
                string text = (adjustment.step_increment >= 1 ? "%.lf" : "%.1lf").printf (adjustment.value);
                ctx.select_font_face ("Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
                ctx.set_font_size (10.0);

                Cairo.TextExtents extents;
                ctx.text_extents (text, out extents);
                ctx.move_to (radius - (extents.width / 2), radius + (extents.height / 2));
                ctx.set_source_rgb (0.8, 0.8, 0.8);
                ctx.show_text (text);
            }
        }

        private void build_events () {
            drag_gesture = new Gtk.GestureDrag () {
                propagation_phase = Gtk.PropagationPhase.CAPTURE,
                name = "drag-rotation-capture"
            };
            add_controller (drag_gesture);

            drag_gesture.drag_begin.connect ((x, y) => {
                previous_deg = Math.atan2 (x - radius, y - radius) * (180 / Math.PI);
            });

            drag_gesture.drag_update.connect ((x, y) => {
                double start_x;
                double start_y;
                drag_gesture.get_start_point (out start_x, out start_y);

                double relative_x = start_x + x;
                double relative_y = start_y + y;

                current_deg = Math.atan2 (relative_x - radius, relative_y - radius) * (180 / Math.PI);

                //  print ("current %lf, previous %lf\n", current_deg, previous_deg);

                var delta_deg = previous_deg - current_deg;

                if (delta_deg < 270 && delta_deg > -270) {
                    pointing_angle += delta_deg;

                    if (pointing_angle < pointing_angle_lower) {
                        pointing_angle = pointing_angle_lower;
                    } else if (pointing_angle > pointing_angle_upper + pointing_angle_lower) {
                        pointing_angle = pointing_angle_upper + pointing_angle_lower;
                    }

                    adjustment.value = map_range (pointing_angle_lower,
                        adjustment.lower, pointing_angle_lower + pointing_angle_upper,
                        adjustment.upper, pointing_angle);
                    value_changed ();
                }

                previous_deg = current_deg;
            });

            touch_rotation_gesture = new Gtk.GestureRotate ();
            add_controller (touch_rotation_gesture);

            wheel_gesture = new Gtk.EventControllerScroll (Gtk.EventControllerScrollFlags.VERTICAL);
            add_controller (wheel_gesture);

            wheel_gesture.scroll.connect ((dx, dy) => {
                var value = adjustment.value + adjustment.step_increment * dy;
                pointing_angle = map_range (adjustment.lower,
                    pointing_angle_lower,
                    adjustment.upper,
                    pointing_angle_lower + pointing_angle_upper,
                    value);

                if (pointing_angle < pointing_angle_lower) {
                    pointing_angle = pointing_angle_lower;
                } else if (pointing_angle > pointing_angle_upper + pointing_angle_lower) {
                    pointing_angle = pointing_angle_upper + pointing_angle_lower;
                }

                adjustment.value = value;
                return true;
            });

            adjustment.value_changed.connect (() => {
                Idle.add (() => {
                    knob_meter.queue_draw ();
                    return false;
                });
            });
        }

        protected double map_range (double x0, double y0, double x1, double y1, double xp) {
            return (y0 + ((y1 - y0) / (x1 - x0)) * (xp - x0));
        }
    }
}
