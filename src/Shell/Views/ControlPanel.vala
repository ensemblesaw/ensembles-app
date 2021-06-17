namespace Ensembles.Shell { 
    public class ControlPanel : Gtk.Grid {

        ToggleSwitch accomp_toggle;
        ToggleSwitch layer_toggle;
        ToggleSwitch split_toggle;
        ToggleSwitch metronome_toggle;

        ToggleSwitch transpose_toggle;
        ToggleSwitch octave_toggle;
        ToggleSwitch arpeggiator_toggle;
        ToggleSwitch harmonizer_toggle;
        ToggleSwitch reverb_toggle;
        ToggleSwitch chorus_toggle;

        Gtk.SpinButton transpose_spin_button;
        Gtk.SpinButton octave_spin_button;
        Gtk.SpinButton arpeggiator_spin_button;
        Gtk.SpinButton harmonizer_spin_button;
        Gtk.SpinButton reverb_spin_button;
        Gtk.SpinButton chorus_spin_button;

        Dial main_dial;

        public signal void accomp_change (bool enable);
        public signal void dial_rotate (bool direction, int amount);
        public signal void dial_activate ();
        public ControlPanel () {
            row_spacing = 4;
            column_spacing = 4;
            column_homogeneous = true;
            halign = Gtk.Align.END;
            valign = Gtk.Align.START;
            margin = 4;
            width_request = 294;

            accomp_toggle = new ToggleSwitch ("Accompaniment");
            layer_toggle = new ToggleSwitch ("Layer");
            split_toggle = new ToggleSwitch ("Split");
            metronome_toggle = new ToggleSwitch ("Metronome");

            transpose_toggle = new ToggleSwitch ("Transpose");
            octave_toggle = new ToggleSwitch ("Octave");
            arpeggiator_toggle = new ToggleSwitch ("Arpeggiator");
            harmonizer_toggle = new ToggleSwitch ("Harmonizer");
            reverb_toggle = new ToggleSwitch ("Reverb");
            chorus_toggle = new ToggleSwitch ("Chorus");




            transpose_spin_button = new Gtk.SpinButton.with_range (-12, 12, 1);
            octave_spin_button = new Gtk.SpinButton.with_range (-2, 2, 1);
            arpeggiator_spin_button = new Gtk.SpinButton.with_range (0, 16, 1);
            harmonizer_spin_button = new Gtk.SpinButton.with_range (0, 16, 1);
            reverb_spin_button = new Gtk.SpinButton.with_range (0, 10, 1);
            chorus_spin_button = new Gtk.SpinButton.with_range (0, 10, 1);

            main_dial = new Dial ();
            attach (main_dial, 0, 0, 2, 4);
            

            attach (accomp_toggle, 2, 0, 1, 1);
            attach (layer_toggle, 2, 1, 1, 1);
            attach (split_toggle, 2, 2, 1, 1);
            attach (metronome_toggle, 2, 3, 1, 1);

            attach (transpose_toggle, 0, 4, 1, 1);
            attach (octave_toggle, 1, 4, 1, 1);
            attach (arpeggiator_toggle, 2, 4, 1, 1);

            attach (transpose_spin_button, 0, 5, 1, 1);
            attach (octave_spin_button, 1, 5, 1, 1);
            attach (arpeggiator_spin_button, 2, 5, 1, 1);

            attach (reverb_toggle, 0, 6, 1, 1);
            attach (chorus_toggle, 1, 6, 1, 1);
            attach (harmonizer_toggle, 2, 6, 1, 1);

            attach (reverb_spin_button, 0, 7, 1, 1);
            attach (chorus_spin_button, 1, 7, 1, 1);
            attach (harmonizer_spin_button, 2, 7, 1, 1);
            this.show_all ();
            make_events ();
        }

        public void make_events () {
            accomp_toggle.toggled.connect ((active) => {
                accomp_change (active);
            });
            main_dial.activate.connect (() => {
                dial_activate ();
            });
            main_dial.rotate.connect ((direction, amount) => {
                dial_rotate (direction, amount);
            });
        }
    }
}