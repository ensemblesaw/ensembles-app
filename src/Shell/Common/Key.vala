namespace Ensembles.Shell { 
    public class Key : Gtk.Button {
        public Key (bool black_key) {
            margin_top = 23;
            if (black_key) {
                hexpand = true;
                height_request = 84;
                get_style_context ().add_class ("black-key-normal");
            } else {
                height_request = 146;
                hexpand = true;
                get_style_context ().add_class ("white-key-normal");
            }
        }
    }
}