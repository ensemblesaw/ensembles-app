namespace Ensembles.Shell { 
    public class RegistryView : Gtk.Grid {
        Gtk.SpinButton bank_select;
        Gtk.Button[] registry_buttons;
        Gtk.Button memory_button;
        public RegistryView () {
            bank_select = new Gtk.SpinButton.with_range (1, 10, 1);
            attach (bank_select, 0, 0, 1, 1);

            var button_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            button_box.width_request = 337;

            registry_buttons = new Gtk.Button [10];
            for (int i = 0; i < 10; i ++) {
                registry_buttons[i] = new Gtk.Button.with_label ((i + 1).to_string ());
                button_box.pack_start (registry_buttons[i]);
            }
            button_box.set_layout (Gtk.ButtonBoxStyle.EXPAND);
            attach (button_box, 1, 0, 1, 1);
            memory_button = new Gtk.Button.with_label ("Memorize");
            attach (memory_button, 2, 0, 1, 1);

            var bank_label = new Gtk.Label ("BANK");
            bank_label.set_opacity (0.4);
            var registry_label = new Gtk.Label ("REGISTRY MEMORY");
            registry_label.set_opacity (0.4);

            attach (bank_label, 0, 1, 1, 1);
            attach (registry_label, 1, 1, 1, 1);

            column_spacing = 4;
            margin = 4;

            this.show_all ();

        }
    }
}