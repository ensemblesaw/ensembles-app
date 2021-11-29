/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class MasterKnob : Knob {
        public MasterKnob () {
            // Set up visuals
            center = 40;
            knob_background.get_style_context ().add_class ("knob-background");
            knob_socket_graphic.get_style_context ().add_class ("super-knob-socket-graphic");
            knob_cover.get_style_context ().add_class ("super-knob-cover-graphic");
            knob_cover.width_request = 80;
            knob_cover.height_request = 80;
            knob_background.width_request = 80;
            knob_background.height_request = 80;
            width_request = 80;
            double px = RADIUS * GLib.Math.cos (value / Math.PI);
            double py = RADIUS * GLib.Math.sin (value / Math.PI);
            fixed.move (knob_socket_graphic, (int)(px + center), (int)(py + center));

            knob_background.get_style_context ().add_class ("super-knob-idle");
        }

        public void set_color (bool connected, int int_val) {
            if (connected) {
                for (int i = 0; i <= 10; i++) {
                    if (i != int_val) {
                        knob_background.get_style_context ().remove_class (("super-knob-connected-%d").printf (i));
                    }
                }
                knob_background.get_style_context ().add_class (("super-knob-connected-%d").printf (int_val));
                knob_background.get_style_context ().remove_class ("super-knob-idle");
            } else {
                for (int i = 0; i <= 10; i++) {
                    knob_background.get_style_context ().remove_class (("super-knob-connected-%d").printf (i));
                }
                knob_background.get_style_context ().add_class ("super-knob-idle");
            }
        }
    }
}
