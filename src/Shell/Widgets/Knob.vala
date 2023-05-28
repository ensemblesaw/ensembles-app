/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Widgets {
    /**
     * A `Knob` is a rotary control used to select a numeric value
     */
    public class Knob : Gtk.Widget, Gtk.Accessible {
        /**
         * The adjustment that is controlled by the knob.
         */
        public Gtk.Adjustment adjustment { get; set; }
        /**
         * Current value of the knob.
         */
        public double value {
            get {
                return adjustment.value;
            }
            set {
                pointing_angle = Utils.Math.map_range_unclamped (
                    value,
                    adjustment.lower,
                    adjustment.upper,
                    pointing_angle_lower,
                    pointing_angle_lower + pointing_angle_upper
                );

                if (pointing_angle < pointing_angle_lower) {
                    pointing_angle = pointing_angle_lower;
                } else if (pointing_angle > pointing_angle_upper + pointing_angle_lower) {
                    pointing_angle = pointing_angle_upper + pointing_angle_lower;
                }

                adjustment.value = value;
            }
        }

        // Knob UI
        private Gtk.BinLayout bin_layout;
        protected Gtk.Box knob_socket_graphic;
        protected Gtk.Box knob_cover;
        protected Gtk.DrawingArea knob_meter;
        protected Gtk.Box knob_background;

        protected List<double?> marks;

        private Gtk.GestureRotate touch_rotation_gesture;
        private Gtk.GestureDrag drag_gesture;
        private Gtk.EventControllerScroll wheel_gesture;

        /**
         * The current angle in degrees towards which the knob is pointing.
         */
        public double pointing_angle { get; private set; }
        /**
         * The angle in degrees which the knob will point towards
         * when `value` is minimum.
         */
        public double pointing_angle_lower { get; protected set; }
        /**
         * The angle in degrees which the knob will point towards
         * when `value` is maximum.
         */
        public double pointing_angle_upper { get; protected set; }
        private double current_deg;
        private double previous_deg;

        /**
         * Number of decimal places that are displayed in the value.
         */
        public uint8 digits { get; set; }
        /**
         * Whether the current value is displayed as a string inside the knob.
         */
        public bool draw_value { get; set; }

        private uint radius = 0;

        public signal void value_changed (double value);

        /**
         * Creates a new `Knob` widget.
         *
         * @param adjustment the [class@Gtk.Adjustment] which sets the range of
         * the knob, or null to create a new adjustment.
         */
        public Knob (Gtk.Adjustment? adjustment = null) {
            Object (
                name: "knob",
                accessible_role: Gtk.AccessibleRole.SPIN_BUTTON
            );

            if (adjustment != null) {
                this.adjustment.lower = adjustment.lower;
                this.adjustment.upper = adjustment.upper;
                this.adjustment.step_increment = adjustment.step_increment;
            }

            pointing_angle = pointing_angle_lower;
        }

        /**
         * Creates a new `Knob` widget with a range from min to max.
         *
         * Let's the user input a number between min and max (including min and
         * max) with the increment step. step must be nonzero; it’s the distance
         * the meter moves to adjust the knob value.
         *
         * @param min minimum value
         * @param max maximum value
         * @param step increment (tick size)
         */
        public Knob.with_range (double min, double max, double step) {
            Object (
                name: "knob",
                accessible_role: Gtk.AccessibleRole.SPIN_BUTTON
            );
            this.adjustment.lower = min;
            this.adjustment.upper = max;
            this.adjustment.step_increment = step;
            pointing_angle = pointing_angle_lower;
        }

        construct {
            adjustment = new Gtk.Adjustment (0, 0, 100,
                1, 0, 0);
            marks = new List<double?> ();
            pointing_angle_upper = 275;
            pointing_angle_lower = 135;
            build_layout ();
            realize.connect (() => {
                build_ui ();
            });
            build_events ();
        }

        private void build_layout () {
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

        protected void draw_meter (Gtk.DrawingArea meter, Cairo.Context ctx, int width, int height) {
            var gb = Utils.Math.map_range_unclamped (
                adjustment.value,
                adjustment.lower,
                adjustment.upper,
                0,
                1
            );
            // Draw meter
            ctx.arc (radius + 0.2, radius, radius - 7,
                pointing_angle_lower * (Math.PI / 180.0),
                pointing_angle * (Math.PI / 180.0));
            ctx.set_line_width (2);
            ctx.set_source_rgba (1 - gb, gb, gb, 1);
            ctx.stroke ();

            // Draw marks
            foreach (var mark in marks) {
                var mark_angle = Utils.Math.map_range_unclamped (
                    mark,
                    adjustment.lower,
                    adjustment.upper,
                    pointing_angle_lower,
                    pointing_angle_lower + pointing_angle_upper
                );
                ctx.arc (
                    radius + 0.2, radius, radius - 2,
                    (mark_angle - 1) * (Math.PI / 180.0),
                    (mark_angle + 1) * (Math.PI / 180.0)
                );

                ctx.set_source_rgba (1, 1, 1, adjustment.value == mark ? 1 : 0.3);
                ctx.stroke ();
            }

            if (draw_value) {
                string text = (adjustment.step_increment >= 1 ? "%.lf" : "%.1lf").printf (adjustment.value);
                ctx.select_font_face ("Michroma", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
                ctx.set_font_size (Math.fmax (10, radius / 3));

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

                var delta_deg = previous_deg - current_deg;

                if (delta_deg < 270 && delta_deg > -270) {
                    pointing_angle += delta_deg;

                    if (pointing_angle < pointing_angle_lower) {
                        pointing_angle = pointing_angle_lower;
                    } else if (pointing_angle > pointing_angle_upper + pointing_angle_lower) {
                        pointing_angle = pointing_angle_upper + pointing_angle_lower;
                    }

                    adjustment.value = Utils.Math.map_range_unclamped (
                        pointing_angle,
                        pointing_angle_lower,
                        pointing_angle_lower + pointing_angle_upper,
                        adjustment.lower,
                        adjustment.upper
                    );
                    value_changed (adjustment.value);
                }

                previous_deg = current_deg;
            });

            touch_rotation_gesture = new Gtk.GestureRotate ();
            add_controller (touch_rotation_gesture);

            wheel_gesture = new Gtk.EventControllerScroll (Gtk.EventControllerScrollFlags.VERTICAL);
            add_controller (wheel_gesture);

            wheel_gesture.scroll.connect ((dx, dy) => {
                var value = adjustment.value - adjustment.step_increment * dy;
                pointing_angle = Utils.Math.map_range_unclamped (
                    value,
                    adjustment.lower,
                    adjustment.upper,
                    pointing_angle_lower,
                    pointing_angle_lower + pointing_angle_upper
                );

                if (value > adjustment.upper) {
                    value = adjustment.upper;
                } else if (value < adjustment.lower) {
                    value = adjustment.lower;
                }

                if (pointing_angle < pointing_angle_lower) {
                    pointing_angle = pointing_angle_lower;
                } else if (pointing_angle > pointing_angle_upper + pointing_angle_lower) {
                    pointing_angle = pointing_angle_upper + pointing_angle_lower;
                }

                adjustment.value = value;
                value_changed (value);
                return true;
            });

            touch_rotation_gesture.angle_changed.connect ((angle, angle_delta) => {
                pointing_angle += angle_delta;

                if (pointing_angle < pointing_angle_lower) {
                    pointing_angle = pointing_angle_lower;
                } else if (pointing_angle > pointing_angle_upper + pointing_angle_lower) {
                    pointing_angle = pointing_angle_upper + pointing_angle_lower;
                }

                adjustment.value = Utils.Math.map_range_unclamped (
                    pointing_angle,
                    pointing_angle_lower,
                    pointing_angle_lower + pointing_angle_upper,
                    adjustment.lower,
                    adjustment.upper
                );
                value_changed (adjustment.value);
            });

            adjustment.value_changed.connect (() => {
                Idle.add (() => {
                    knob_meter.queue_draw ();
                    return false;
                });
            });
        }

        /**
         * Adds a mark at value.
         *
         * A mark is indicated visually by drawing a tick mark outside the knob.
         *
         * @param value the value at which the mark is placed, must be between
         * the lower and upper limits of the scales’ adjustment
         */
        public void add_mark (double value) {
            marks.append (value);
        }

        /**
         * Removes any marks that have been added.
         */
        public void clear_marks () {
            foreach (var mark in marks) {
                marks.remove (mark);
            }
        }
    }
}
