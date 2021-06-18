namespace Ensembles.Shell { 
    public class JoyStick : Gtk.Grid {
        Gtk.Button x_assign_button;
        Gtk.Button y_assign_button;
        public JoyStick () {
            x_assign_button = new Gtk.Button.with_label ("X-Assign");
            y_assign_button = new Gtk.Button.with_label ("Y-Assign");
            var button_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            button_box.margin = 4;
            button_box.width_request = 140;
            button_box.set_layout (Gtk.ButtonBoxStyle.EXPAND);
            button_box.pack_start (x_assign_button);
            button_box.pack_end (y_assign_button);
            attach (button_box, 0, 0, 1, 1);
            var main_box = new Gtk.Grid ();
            main_box.vexpand = true;
            main_box.margin = 4;
            main_box.get_style_context ().add_class ("joystick-pad");
            attach (main_box, 0, 1, 1, 1);
            get_style_context ().add_class ("joystick-background");
            width_request = 150;
        }
    }
}