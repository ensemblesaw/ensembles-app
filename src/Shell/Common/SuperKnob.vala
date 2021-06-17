namespace Ensembles.Shell { 
    public class SuperKnob : Knob {
        public SuperKnob () {

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
            double px = RADIUS * GLib.Math.cos (value/(Math.PI));
            double py = RADIUS * GLib.Math.sin (value/(Math.PI));
            fixed.move (knob_socket_graphic, (int)(px + center), (int)(py + center));

            knob_background.get_style_context ().add_class ("super-knob-idle");
        }
    }
}