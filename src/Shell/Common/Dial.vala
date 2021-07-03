namespace Ensembles.Shell { 
    public class Dial : Gtk.Overlay {
        public string tooltip;
        public bool dragging;
        private double dragging_direction;
        private double over_centre_initial;
        private double over_centre;
        private double left_of_centre;
        private double left_of_centre_initial;

        public double value = 0;
        Gtk.Box knob_socket_graphic;
        Gtk.Box dial_cover;
        Gtk.Fixed fixed;
        Gtk.Grid dial_light_graphics;

        public signal void rotate (bool direction, int amount);
        public signal void activate_clicked ();
        private const double RADIUS = 20;

        public Dial () {
            knob_socket_graphic = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            knob_socket_graphic.width_request = 20;
            knob_socket_graphic.height_request = 20;
            knob_socket_graphic.get_style_context ().add_class ("dial-socket-graphic");

            dial_cover = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            dial_cover.get_style_context ().add_class ("dial-cover-graphic");
            dial_cover.halign = Gtk.Align.START;
            dial_cover.valign = Gtk.Align.CENTER;
            dial_cover.margin_start = 6;
            dial_cover.width_request = 100;
            dial_cover.height_request = 100;

            dial_light_graphics = new Gtk.Grid ();
            dial_light_graphics.halign = Gtk.Align.START;
            dial_light_graphics.valign = Gtk.Align.CENTER;
            dial_light_graphics.margin_start = 6;
            dial_light_graphics.width_request = 100;
            dial_light_graphics.height_request = 100;
            dial_light_graphics.get_style_context ().add_class ("dial-graphic");

            fixed = new Gtk.Fixed ();
            fixed.halign = Gtk.Align.START;
            fixed.valign = Gtk.Align.CENTER;
            fixed.margin_start = 6;
            fixed.width_request = 100;
            fixed.height_request = 100;
            fixed.put (knob_socket_graphic, 70, 50);
            var event_box = new Gtk.EventBox ();
            event_box.event.connect (handle_event);
            event_box.hexpand = true;
            event_box.vexpand = true;



            var plus_one_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.BUTTON);
            plus_one_button.halign = Gtk.Align.END;
            plus_one_button.valign = Gtk.Align.START;
            plus_one_button.margin_top = 8;
            plus_one_button.margin_end = 36;
            plus_one_button.width_request = 30;
            plus_one_button.height_request = 30;
            plus_one_button.get_style_context ().add_class ("rounded");
            plus_one_button.get_style_context ().remove_class ("image-button");
            plus_one_button.clicked.connect (() => {
                rotate (true, 1);
            });

            var minus_one_button = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.BUTTON);
            minus_one_button.halign = Gtk.Align.END;
            minus_one_button.valign = Gtk.Align.END;
            minus_one_button.margin_bottom = 8;
            minus_one_button.margin_end = 36;
            minus_one_button.width_request = 30;
            minus_one_button.height_request = 30;
            minus_one_button.get_style_context ().add_class ("rounded");
            minus_one_button.get_style_context ().remove_class ("image-button");
            minus_one_button.clicked.connect (() => {
                rotate (false, 1);
            });

            var activate_button = new Gtk.Button.from_icon_name ("go-next-symbolic", Gtk.IconSize.BUTTON);
            activate_button.halign = Gtk.Align.END;
            activate_button.valign = Gtk.Align.CENTER;
            activate_button.margin_end = 30;
            activate_button.width_request = 30;
            activate_button.height_request = 30;
            activate_button.get_style_context ().add_class ("rounded");
            activate_button.get_style_context ().remove_class ("image-button");
            activate_button.clicked.connect (() => {
                activate_clicked ();
            });


            add_overlay (dial_light_graphics);
            add_overlay (dial_cover);
            add_overlay (fixed);
            add_overlay (event_box);
            add_overlay (plus_one_button);
            add_overlay (minus_one_button);
            add_overlay (activate_button);

            this.hexpand = false;
            this.vexpand = true;
        }

        public void rotate_dial (double value) {
            double px = RADIUS * GLib.Math.cos (value/(Math.PI));
            double py = RADIUS * GLib.Math.sin (value/(Math.PI));
            fixed.move (knob_socket_graphic, (int)(px + 50), (int)(py + 50));
        }

        public void animate_rotate_dial (bool direction) {
            if (direction) {
                dial_light_graphics.get_style_context ().add_class ("dial-graphic-rotate-clockwise");
                Timeout.add (400, () => {
                    dial_light_graphics.get_style_context ().remove_class ("dial-graphic-rotate-clockwise");
                    return false;
                });
            } else {
                dial_light_graphics.get_style_context ().add_class ("dial-graphic-rotate-anticlockwise");
                Timeout.add (400, () => {
                    dial_light_graphics.get_style_context ().remove_class ("dial-graphic-rotate-anticlockwise");
                    return false;
                });
            }
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
                over_centre_initial = event.motion.y_root;
            }
            if (event.type == Gdk.EventType.BUTTON_RELEASE) {
                dragging = false;
                dragging_direction = 0;
            }

            if (event.type == Gdk.EventType.MOTION_NOTIFY && dragging) {
                if (dragging_direction == 0) {
                    dragging_direction = event.motion.x;
                }
                if (over_centre == 0) {
                    over_centre = event.motion.y_root;
                }
    
                if (dragging_direction > event.motion.x || event.motion.x_root == 0) {

                    if (over_centre > over_centre_initial) {
                        value+=0.5;
                        if (value >= 360 || value <= -360) {
                            value = 0;
                        }
                        if ((int)value % 8 == 0) {
                            rotate (true, 5);
                            animate_rotate_dial (true);
                        }
                    }
                    else {
                        value-=0.5;
                        if (value >= 360 || value <= -360) {
                            value = 0;
                        }
                        if ((int)value % 8 == 0) {
                            rotate (false, 5);
                            animate_rotate_dial (false);
                        }
                    }
                    rotate_dial (value);
                    
                    dragging_direction = event.motion.x;
                    over_centre = event.motion.y_root;
                } else {

                    if (over_centre > over_centre_initial) {
                        value-=0.5;
                        if (value >= 360 || value <= -360) {
                            value = 0;
                        }
                        if ((int)value % 8 == 0) {
                            rotate (false, 5);
                            animate_rotate_dial (false);
                        }
                    }
                    else {
                        value+=0.5;
                        if (value >= 360 || value <= -360) {
                            value = 0;
                        }
                        if ((int)value % 8 == 0) {
                            rotate (true, 5);
                            animate_rotate_dial (true);
                        }
                    }
                    rotate_dial (value);
                    
                    dragging_direction = event.motion.x;
                    over_centre = event.motion.y_root;
                }
            }
            return false;
        }
    }
}