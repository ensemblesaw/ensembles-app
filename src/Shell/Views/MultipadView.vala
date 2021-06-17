namespace Ensembles.Shell { 
    public class MultipadView : Gtk.Grid {
        Gtk.Button[] pads;
        Gtk.Button assign_button;
        Gtk.Button stop_button;
        Gtk.SpinButton bank_select;
        public MultipadView () {
            var header = new Gtk.Label ("MULTIPAD VARIABLES");
            header.valign = Gtk.Align.CENTER;
            header.halign = Gtk.Align.START;
            header.set_opacity (0.4);

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            separator.valign = Gtk.Align.CENTER;

            attach (header, 0, 0, 4, 1);
            attach (separator, 4, 0, 5, 1);

            pads = new Gtk.Button [12];
            for (int i = 0; i < 6; i++) {
                pads[i] = new Gtk.Button();
                pads[i + 6] = new Gtk.Button();
                pads[i].width_request = 32;
                pads[i + 6].width_request = 32;
                attach (pads[i], i, 1, 1, 1);
                attach (pads[i + 6], i, 2, 1, 1);
            }
            assign_button = new Gtk.Button.with_label ("Assign");
            assign_button.height_request = 80;
            assign_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            attach (assign_button, 7, 1, 1, 2);
            
            stop_button = new Gtk.Button.with_label ("Stop");
            stop_button.width_request = 51;
            attach (stop_button, 8, 1, 1, 2);
            margin = 4;
            show_all ();
        }
    }
}