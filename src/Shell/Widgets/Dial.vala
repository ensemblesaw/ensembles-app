/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class Dial : Gtk.Overlay {
        public string tooltip;
        public bool dragging;
        private double dragging_direction_x;
        private double dragging_direction_y;

        public double value = 0;
        Gtk.Box knob_socket_graphic;
        Gtk.Box dial_cover;
        Gtk.Fixed fixed;
        Gtk.Grid dial_light_graphics;

        public signal void rotate (bool direction, int amount);
        public signal void activate_clicked ();
        public signal void open_recorder_screen ();
        private const double RADIUS = 20;

        private float[]? buffer_l;
        private float[]? buffer_r;
        private string css = "
        .dial-graphic {
            background: linear-gradient(alpha(#333, 1.0), alpha(#000, 0.5)),
                        linear-gradient(225deg, alpha(@accent_color_complimentary, 0), alpha(@accent_color_complimentary, %0.1f)),
                        linear-gradient(135deg, alpha(@accent_color_complimentary_alternate, 0), alpha(@accent_color_complimentary_alternate, %0.1f));
        }
        ";

        public Dial () {
            knob_socket_graphic = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                width_request = 20,
                height_request = 20
            };
            knob_socket_graphic.get_style_context ().add_class ("dial-socket-graphic");

            dial_cover = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                halign = Gtk.Align.START,
                valign = Gtk.Align.CENTER,
                margin_start = 6,
                width_request = 100,
                height_request = 100
            };
            dial_cover.get_style_context ().add_class ("dial-cover-graphic");

            dial_light_graphics = new Gtk.Grid () {
                halign = Gtk.Align.START,
                valign = Gtk.Align.CENTER,
                margin_start = 6,
                width_request = 100,
                height_request = 100
            };
            dial_light_graphics.get_style_context ().add_class ("dial-graphic");

            fixed = new Gtk.Fixed () {
                halign = Gtk.Align.START,
                valign = Gtk.Align.CENTER,
                margin_start = 6,
                width_request = 100,
                height_request = 100
            };
            fixed.put (knob_socket_graphic, 70, 50);

            var event_box = new Gtk.EventBox () {
                expand = true
            };
            event_box.event.connect (handle_event);



            var plus_one_button = new Gtk.Button.from_icon_name ("list-add-symbolic") {
                halign = Gtk.Align.START,
                valign = Gtk.Align.START,
                margin_top = 8,
                margin_start = 105,
                width_request = 40,
                height_request = 40
            };
            plus_one_button.get_style_context ().add_class ("oval");
            plus_one_button.get_style_context ().remove_class ("image-button");
            plus_one_button.clicked.connect (() => {
                rotate (true, 1);
            });

            var minus_one_button = new Gtk.Button.from_icon_name ("list-remove-symbolic") {
                halign = Gtk.Align.START,
                valign = Gtk.Align.END,
                margin_bottom = 8,
                margin_start = 105,
                width_request = 40,
                height_request = 40
            };
            minus_one_button.get_style_context ().add_class ("oval");
            minus_one_button.get_style_context ().remove_class ("image-button");
            minus_one_button.clicked.connect (() => {
                rotate (false, 1);
            });

            var activate_button = new Gtk.Button.from_icon_name ("go-next-symbolic") {
                halign = Gtk.Align.START,
                valign = Gtk.Align.CENTER,
                margin_top = 4,
                margin_bottom = 4,
                margin_start = 118,
                width_request = 40,
                height_request = 40
            };
            activate_button.get_style_context ().add_class ("oval");
            activate_button.get_style_context ().remove_class ("image-button");
            activate_button.clicked.connect (() => {
                activate_clicked ();
            });

            var recorder_button = new Gtk.Button.with_label (_("Recorder")) {
                halign = Gtk.Align.END,
                valign = Gtk.Align.START
            };
            recorder_button.get_style_context ().add_class ("ctrl-panel-recorder-button");
            recorder_button.clicked.connect (() => {
                open_recorder_screen ();
            });


            add_overlay (dial_light_graphics);
            add_overlay (dial_cover);
            add_overlay (fixed);
            add_overlay (event_box);
            add_overlay (plus_one_button);
            add_overlay (minus_one_button);
            add_overlay (activate_button);
            add_overlay (recorder_button);

            this.hexpand = false;
            this.vexpand = true;

            //  var realtime_css_provider = new Gtk.CssProvider ();

            // This feature will be enabled on Gtk 4
            //  Timeout.add (200, () => {
            //      GLib.Idle.add (() => {
            //          if (buffer_l != null && buffer_r != null) {
            //              var average_l = average_of_buffer (buffer_l) - 0.05;
            //              var average_r = average_of_buffer (buffer_r) - 0.05;

            //              string provider_data = css.printf (average_l, average_r) + "";
            //              try {
            //                  realtime_css_provider.load_from_data (provider_data);
            //                  Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
            //                      realtime_css_provider,
            //                      Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            //              } catch (Error e) {

            //              }
            //          }

            //          return false;
            //      }, 20);

            //      return true;
            //  }, 20);
        }

        //  private float average_of_buffer (float[] buffer) {
        //      float sum = 0;
        //      foreach (var item in buffer) {
        //          sum += item < 0 ? -item : item;
        //      }

        //      return (sum / buffer.length) * 10;
        //  }

        public void rotate_dial (double value) {
            double px = RADIUS * GLib.Math.cos (value / (Math.PI));
            double py = RADIUS * GLib.Math.sin (value / (Math.PI));
            Idle.add (() => {
                fixed.move (knob_socket_graphic, (int)(px + 50), (int)(py + 50));
                fixed.queue_draw ();
                return false;
            });
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

        public void animate_audio (float[]? buffer_l, float[]? buffer_r) {
            this.buffer_l = buffer_l;
            this.buffer_r = buffer_r;
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
                dragging_direction_x = 0;
                dragging_direction_y = 0;
            }


            if (event.type == Gdk.EventType.MOTION_NOTIFY && dragging) {
                if (dragging_direction_x == 0) {
                    dragging_direction_x = event.motion.x;
                }
                if (dragging_direction_y == 0) {
                    dragging_direction_y = event.motion.y;
                }
                double delta = 0.0;
                if (dragging_direction_x > event.motion.x || event.motion.x_root == 0) {
                    delta -= 0.05 * (dragging_direction_x - event.motion.x);
                    dragging_direction_x = event.motion.x;
                } else {
                    delta += 0.05 * (event.motion.x - dragging_direction_x);
                    dragging_direction_x = event.motion.x;
                }
                if (dragging_direction_y > event.motion.y || event.motion.y_root == 0) {
                    delta += 0.05 * (dragging_direction_y - event.motion.y);
                    dragging_direction_y = event.motion.y;
                } else {
                    delta -= 0.05 * (event.motion.y - dragging_direction_y);
                    dragging_direction_y = event.motion.y;
                }
                value += delta;
                if ((int)value % 8 == 0) {
                    rotate (delta > 0, 5);
                    animate_rotate_dial (delta > 0);
                }
                if (value >= 360 || value <= -360) {
                    value = 0;
                }
                rotate_dial (value);
            }
            return false;
        }
    }
}
