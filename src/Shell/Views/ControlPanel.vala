namespace Ensembles.Shell { 
    public class ControlPanel : Gtk.Grid {

        ToggleSwitch accomp_toggle;

        public signal void accomp_change (bool enable);
        public ControlPanel () {
            row_spacing = 4;
            margin = 4;

            accomp_toggle = new ToggleSwitch ("Accompaniment");

            attach (accomp_toggle, 0, 0, 1, 1);
            this.show_all ();
            make_events ();
        }

        public void make_events () {
            accomp_toggle.toggled.connect ((active) => {
                print("onn\n");
                accomp_change (active);
            });
        }
    }
}