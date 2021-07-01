namespace Ensembles.Shell { 
    public class ChannelModulatorScreen : Gtk.Grid {
        int _synth_index;
        int _channel;

        public signal void close_screen ();
        Gtk.Label header;

        bool monitoring;


        // Spin Buttons
        Gtk.SpinButton pan_spin_button;
        Gtk.SpinButton reverb_spin_button;
        Gtk.SpinButton chorus_spin_button;
        Gtk.SpinButton sustain_spin_button;
        Gtk.SpinButton expression_spin_button;
        Gtk.SpinButton modulation_spin_button;
        Gtk.SpinButton cut_off_spin_button;
        Gtk.SpinButton resonance_spin_button;

        public ChannelModulatorScreen (int synth_index, int channel) {
            _synth_index = synth_index;
            _channel = channel;
            set_size_request (424, 236);
            row_spacing = 8;
            get_style_context ().add_class ("channel-modulator-screen");

            var close_button = new Gtk.Button.from_icon_name ("window-close-symbolic", Gtk.IconSize.BUTTON);
            close_button.get_style_context ().add_class ("channel-modulator-close-button");
            close_button.clicked.connect (() => {
                monitoring = false;
                close_screen ();
            });
            attach (close_button, 0, 0, 1, 1);

            header = new Gtk.Label ("");
            header.get_style_context ().add_class ("channel-modulator-header");
            header.halign = Gtk.Align.START;
            header.hexpand = true;
            attach (header, 1, 0, 1, 1);

            var mod_grid = new Gtk.Grid ();
            mod_grid.column_homogeneous = true;
            mod_grid.column_spacing = 6;

            mod_grid.get_style_context ().add_class ("channel-modulator-grid");

            var pan_button = new Gtk.Button.with_label ("Pan");
            pan_spin_button = new Gtk.SpinButton.with_range (-64, 63, 1);
            pan_button.vexpand = true;
            pan_spin_button.vexpand = true;
            mod_grid.attach (pan_button, 0, 0, 1, 1);
            mod_grid.attach (pan_spin_button, 0, 1, 1, 1);

            var reverb_button = new Gtk.Button.with_label ("Reverb");
            reverb_spin_button = new Gtk.SpinButton.with_range (0, 127, 1);
            reverb_button.vexpand = true;
            reverb_spin_button.vexpand = true;
            mod_grid.attach (reverb_button, 1, 0, 1, 1);
            mod_grid.attach (reverb_spin_button, 1, 1, 1, 1);

            var chorus_button = new Gtk.Button.with_label ("Chorus");
            chorus_spin_button = new Gtk.SpinButton.with_range (0, 127, 1);
            chorus_button.vexpand = true;
            chorus_spin_button.vexpand = true;
            mod_grid.attach (chorus_button, 2, 0, 1, 1);
            mod_grid.attach (chorus_spin_button, 2, 1, 1, 1);

            var sustain_button = new Gtk.Button.with_label ("Sustain");
            sustain_spin_button = new Gtk.SpinButton.with_range (0, 127, 1);
            sustain_spin_button.vexpand = true;
            pan_spin_button.vexpand = true;
            mod_grid.attach (sustain_button, 3, 0, 1, 1);
            mod_grid.attach (sustain_spin_button, 3, 1, 1, 1);

            var expression_button = new Gtk.Button.with_label ("Expression");
            expression_spin_button = new Gtk.SpinButton.with_range (0, 127, 1);
            expression_button.vexpand = true;
            expression_spin_button.vexpand = true;
            mod_grid.attach (expression_button, 0, 2, 1, 1);
            mod_grid.attach (expression_spin_button, 0, 3, 1, 1);

            var modulation_button = new Gtk.Button.with_label ("Modulation");
            modulation_spin_button = new Gtk.SpinButton.with_range (0, 127, 1);
            modulation_button.vexpand = true;
            modulation_spin_button.vexpand = true;
            mod_grid.attach (modulation_button, 1, 2, 1, 1);
            mod_grid.attach (modulation_spin_button, 1, 3, 1, 1);

            var cut_off_button = new Gtk.Button.with_label ("Cut Off");
            cut_off_spin_button = new Gtk.SpinButton.with_range (0, 127, 1);
            cut_off_button.vexpand = true;
            cut_off_spin_button.vexpand = true;
            mod_grid.attach (cut_off_button, 2, 2, 1, 1);
            mod_grid.attach (cut_off_spin_button, 2, 3, 1, 1);

            var resonance_button = new Gtk.Button.with_label ("Resonance");
            resonance_spin_button = new Gtk.SpinButton.with_range (0, 127, 1);
            resonance_button.vexpand = true;
            resonance_spin_button.vexpand = true;
            mod_grid.attach (resonance_button, 3, 2, 1, 1);
            mod_grid.attach (resonance_spin_button, 3, 3, 1, 1);

            attach (mod_grid, 0, 1, 2, 1);
            show_all ();
        }

        public void set_synth_channel_to_edit (int synth_index, int channel) {
            _synth_index = synth_index;
            _channel = channel;
            if (synth_index == 0) {
                switch (channel) {
                    case 0:
                    header.set_text ("Monitoring Voice Channel R1");
                    break;
                    case 1:
                    header.set_text ("Monitoring Voice Channel R2");
                    break;
                    case 2:
                    header.set_text ("Monitoring Voice Channel L");
                    break;
                }
            } else {
                header.set_text ("Monitoring Style Channel " + (channel + 1).to_string ());
            }
            monitor_modulators ();
        }

        void monitor_modulators () {
            monitoring = true;
            Timeout.add (200, () => {
                pan_spin_button.value = (double)(Ensembles.Core.Synthesizer.get_modulator_value (_synth_index, _channel, 10)) - 64;
                reverb_spin_button.value = (double)(Ensembles.Core.Synthesizer.get_modulator_value (_synth_index, _channel, 91));;
                chorus_spin_button.value = (double)(Ensembles.Core.Synthesizer.get_modulator_value (_synth_index, _channel, 93));;
                sustain_spin_button.value = (double)(Ensembles.Core.Synthesizer.get_modulator_value (_synth_index, _channel, 64));;
                expression_spin_button.value = (double)(Ensembles.Core.Synthesizer.get_modulator_value (_synth_index, _channel, 11));;
                modulation_spin_button.value = (double)(Ensembles.Core.Synthesizer.get_modulator_value (_synth_index, _channel, 1));;
                cut_off_spin_button.value = (double)(Ensembles.Core.Synthesizer.get_modulator_value (_synth_index, _channel, 74));;
                resonance_spin_button.value = (double)(Ensembles.Core.Synthesizer.get_modulator_value (_synth_index, _channel, 71));;
                return monitoring;
            });
        }
    }
}