namespace Ensembles.Shell { 
    public class Key : Gtk.Button {
        bool _black_key;
        public Key (bool black_key) {
            margin_top = 23;
            _black_key = black_key;
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

        public void note_on () {
            if (_black_key)
                get_style_context ().add_class ("black-key-normal-active");
            else 
                get_style_context ().add_class ("white-key-normal-active");
        }

        public void note_off () {
            if (_black_key)
                get_style_context ().remove_class ("black-key-normal-active");
            else 
                get_style_context ().remove_class ("white-key-normal-active");
        }
    }
}