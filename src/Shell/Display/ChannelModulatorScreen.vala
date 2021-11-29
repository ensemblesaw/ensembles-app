/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

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
        Gtk.SpinButton pitch_spin_button;
        Gtk.SpinButton expression_spin_button;
        Gtk.SpinButton modulation_spin_button;
        Gtk.SpinButton cut_off_spin_button;
        Gtk.SpinButton resonance_spin_button;

        Gtk.Button pan_button;
        Gtk.Button reverb_button;
        Gtk.Button chorus_button;
        Gtk.Button pitch_button;
        Gtk.Button expression_button;
        Gtk.Button modulation_button;
        Gtk.Button cut_off_button;
        Gtk.Button resonance_button;

        bool pan_lock;
        bool reverb_lock;
        bool chorus_lock;
        bool pitch_lock;
        bool expression_lock;
        bool modulation_lock;
        bool cut_off_lock;
        bool resonance_lock;

        bool assignable;

        public signal void broadcast_assignment (int synth_index, int channel, int modulator);

        public ChannelModulatorScreen (int synth_index, int channel) {
            _synth_index = synth_index;
            _channel = channel;
            set_size_request (424, 236);
            row_spacing = 8;
            get_style_context ().add_class ("quick-mod");

            var close_button = new Gtk.Button.from_icon_name ("window-close-symbolic", Gtk.IconSize.BUTTON);
            close_button.get_style_context ().add_class ("quick-mod-close-button");
            close_button.clicked.connect (() => {
                monitoring = false;
                close_screen ();
            });
            attach (close_button, 0, 0, 1, 1);

            header = new Gtk.Label ("");
            header.get_style_context ().add_class ("quick-mod-header");
            header.halign = Gtk.Align.START;
            header.hexpand = true;
            attach (header, 1, 0, 1, 1);

            var mod_grid = new Gtk.Grid ();
            mod_grid.column_homogeneous = true;
            mod_grid.column_spacing = 6;

            mod_grid.get_style_context ().add_class ("quick-mod-grid");

            pan_button = new Gtk.Button.with_label (_("Pan"));
            pan_button.get_style_context ().add_class ("quick-mod-button");
            pan_spin_button = new Gtk.SpinButton.with_range (-64, 63, 1);
            pan_button.vexpand = true;
            pan_spin_button.vexpand = true;
            mod_grid.attach (pan_button, 0, 0, 2, 1);
            mod_grid.attach (pan_spin_button, 0, 1, 2, 1);

            reverb_button = new Gtk.Button.with_label (_("Reverb"));
            reverb_button.get_style_context ().add_class ("quick-mod-button");
            reverb_spin_button = new Gtk.SpinButton.with_range (0, 127, 1);
            reverb_button.vexpand = true;
            reverb_spin_button.vexpand = true;
            mod_grid.attach (reverb_button, 2, 0, 2, 1);
            mod_grid.attach (reverb_spin_button, 2, 1, 2, 1);

            chorus_button = new Gtk.Button.with_label (_("Chorus"));
            chorus_button.get_style_context ().add_class ("quick-mod-button");
            chorus_spin_button = new Gtk.SpinButton.with_range (0, 127, 1);
            chorus_button.vexpand = true;
            chorus_spin_button.vexpand = true;
            mod_grid.attach (chorus_button, 4, 0, 2, 1);
            mod_grid.attach (chorus_spin_button, 4, 1, 2, 1);

            pitch_button = new Gtk.Button.with_label (_("Pitch"));
            pitch_button.get_style_context ().add_class ("quick-mod-button");
            pitch_spin_button = new Gtk.SpinButton.with_range (-64, 63, 1);
            pitch_spin_button.vexpand = true;
            pan_spin_button.vexpand = true;
            mod_grid.attach (pitch_button, 6, 0, 2, 1);
            mod_grid.attach (pitch_spin_button, 6, 1, 2, 1);

            expression_button = new Gtk.Button.with_label (_("Expression"));
            expression_button.get_style_context ().add_class ("quick-mod-button");
            expression_spin_button = new Gtk.SpinButton.with_range (0, 127, 1);
            expression_button.vexpand = true;
            expression_spin_button.vexpand = true;
            mod_grid.attach (expression_button, 0, 2, 2, 1);
            mod_grid.attach (expression_spin_button, 0, 3, 2, 1);

            modulation_button = new Gtk.Button.with_label (_("Modulation"));
            modulation_button.get_style_context ().add_class ("quick-mod-button");
            modulation_spin_button = new Gtk.SpinButton.with_range (0, 127, 1);
            modulation_button.vexpand = true;
            modulation_spin_button.vexpand = true;
            mod_grid.attach (modulation_button, 2, 2, 2, 1);
            mod_grid.attach (modulation_spin_button, 2, 3, 2, 1);

            cut_off_button = new Gtk.Button.with_label (_("Cut Off"));
            cut_off_button.get_style_context ().add_class ("quick-mod-button");
            cut_off_spin_button = new Gtk.SpinButton.with_range (0, 127, 1);
            cut_off_button.vexpand = true;
            cut_off_spin_button.vexpand = true;
            mod_grid.attach (cut_off_button, 4, 2, 2, 1);
            mod_grid.attach (cut_off_spin_button, 4, 3, 2, 1);

            resonance_button = new Gtk.Button.with_label (_("Resonance"));
            resonance_button.get_style_context ().add_class ("quick-mod-button");
            resonance_spin_button = new Gtk.SpinButton.with_range (0, 127, 1);
            resonance_button.vexpand = true;
            resonance_spin_button.vexpand = true;
            mod_grid.attach (resonance_button, 6, 2, 2, 1);
            mod_grid.attach (resonance_spin_button, 6, 3, 2, 1);

            attach (mod_grid, 0, 1, 2, 1);
            show_all ();

            make_events ();
        }

        public void set_synth_channel_to_edit (int synth_index, int channel) {
            _synth_index = synth_index;
            _channel = channel;
            if (synth_index == 0) {
                switch (channel) {
                    case 0:
                    header.set_text (_("Voice Right 1 Modulators"));
                    break;
                    case 1:
                    header.set_text (_("Voice Right 2 Modulators"));
                    break;
                    case 2:
                    header.set_text (_("Voice Left Modulators"));
                    break;
                }
            } else {
                header.set_text (_("Style Channel %s Modulators").printf ((channel + 1).to_string ()));
            }
            modulation_button.get_style_context ().remove_class ("quick-mod-button-locked");
            pan_button.get_style_context ().remove_class ("quick-mod-button-locked");
            expression_button.get_style_context ().remove_class ("quick-mod-button-locked");
            pitch_button.get_style_context ().remove_class ("quick-mod-button-locked");
            resonance_button.get_style_context ().remove_class ("quick-mod-button-locked");
            cut_off_button.get_style_context ().remove_class ("quick-mod-button-locked");
            reverb_button.get_style_context ().remove_class ("quick-mod-button-locked");
            chorus_button.get_style_context ().remove_class ("quick-mod-button-locked");
            if (_synth_index == 1) {
                if (Ensembles.Core.Synthesizer.get_modulator_lock (1, _channel) == true) {
                    modulation_button.get_style_context ().add_class ("quick-mod-button-locked");
                }
                if (Ensembles.Core.Synthesizer.get_modulator_lock (10, _channel) == true) {
                    pan_button.get_style_context ().add_class ("quick-mod-button-locked");
                }
                if (Ensembles.Core.Synthesizer.get_modulator_lock (11, _channel) == true) {
                    expression_button.get_style_context ().add_class ("quick-mod-button-locked");
                }
                if (Ensembles.Core.Synthesizer.get_modulator_lock (3, _channel) == true) {
                    pitch_button.get_style_context ().add_class ("quick-mod-button-locked");
                }
                if (Ensembles.Core.Synthesizer.get_modulator_lock (71, _channel) == true) {
                    resonance_button.get_style_context ().add_class ("quick-mod-button-locked");
                }
                if (Ensembles.Core.Synthesizer.get_modulator_lock (74, _channel) == true) {
                    cut_off_button.get_style_context ().add_class ("quick-mod-button-locked");
                }
                if (Ensembles.Core.Synthesizer.get_modulator_lock (91, _channel) == true) {
                    reverb_button.get_style_context ().add_class ("quick-mod-button-locked");
                }
                if (Ensembles.Core.Synthesizer.get_modulator_lock (66, _channel) == true) {
                    chorus_button.get_style_context ().add_class ("quick-mod-button-locked");
                }
            }
            monitor_modulators ();
        }

        void monitor_modulators () {
            monitoring = true;
            Timeout.add (200, () => {
                if (monitoring) {
                    pan_lock = false;
                    pan_spin_button.value = (double)(Ensembles.Core.Synthesizer.get_modulator_value (_synth_index, _channel, 10)) - 64;
                    pan_lock = true;
                    reverb_lock = false;
                    reverb_spin_button.value = (double)(Ensembles.Core.Synthesizer.get_modulator_value (_synth_index, _channel, 91));
                    reverb_lock = true;
                    chorus_lock = false;
                    chorus_spin_button.value = (double)(Ensembles.Core.Synthesizer.get_modulator_value (_synth_index, _channel, 93));
                    chorus_lock = true;
                    pitch_lock = false;
                    pitch_spin_button.value = (double)(Ensembles.Core.Synthesizer.get_modulator_value (_synth_index, _channel, 3)) - 64;
                    pitch_lock = true;
                    expression_lock = false;
                    expression_spin_button.value = (double)(Ensembles.Core.Synthesizer.get_modulator_value (_synth_index, _channel, 11));
                    expression_lock = true;
                    modulation_lock = false;
                    modulation_spin_button.value = (double)(Ensembles.Core.Synthesizer.get_modulator_value (_synth_index, _channel, 1));
                    modulation_lock = true;
                    cut_off_lock = false;
                    cut_off_spin_button.value = (double)(Ensembles.Core.Synthesizer.get_modulator_value (_synth_index, _channel, 74));
                    cut_off_lock = true;
                    resonance_lock = false;
                    resonance_spin_button.value = (double)(Ensembles.Core.Synthesizer.get_modulator_value (_synth_index, _channel, 71));
                    resonance_lock = true;
                }
                return monitoring;
            });
        }

        void make_events () {
            modulation_spin_button.value_changed.connect (() => {
                if (modulation_lock) {
                    Ensembles.Core.Synthesizer.set_modulator_value (_synth_index, _channel, 1, (int)modulation_spin_button.value);
                    if (_synth_index == 1) {
                        modulation_button.get_style_context ().add_class ("quick-mod-button-locked");
                    }
                }
            });
            pan_spin_button.value_changed.connect (() => {
                if (pan_lock) {
                    Ensembles.Core.Synthesizer.set_modulator_value (_synth_index, _channel, 10, (int)pan_spin_button.value + 64);
                    if (_synth_index == 1) {
                        pan_button.get_style_context ().add_class ("quick-mod-button-locked");
                    }
                }
            });
            expression_spin_button.value_changed.connect (() => {
                if (expression_lock) {
                    Ensembles.Core.Synthesizer.set_modulator_value (_synth_index, _channel, 11, (int)expression_spin_button.value);
                    if (_synth_index == 1) {
                        expression_button.get_style_context ().add_class ("quick-mod-button-locked");
                    }
                }
            });
            pitch_spin_button.value_changed.connect (() => {
                if (pitch_lock) {
                    Ensembles.Core.Synthesizer.set_modulator_value (_synth_index, _channel, 3, (int)pitch_spin_button.value + 64);
                    if (_synth_index == 1) {
                        pitch_button.get_style_context ().add_class ("quick-mod-button-locked");
                    }
                }
            });
            resonance_spin_button.value_changed.connect (() => {
                if (resonance_lock) {
                    Ensembles.Core.Synthesizer.set_modulator_value (_synth_index, _channel, 71, (int)resonance_spin_button.value);
                    if (_synth_index == 1) {
                        resonance_button.get_style_context ().add_class ("quick-mod-button-locked");
                    }
                }
            });
            cut_off_spin_button.value_changed.connect (() => {
                if (cut_off_lock) {
                    Ensembles.Core.Synthesizer.set_modulator_value (_synth_index, _channel, 74, (int)cut_off_spin_button.value);
                    if (_synth_index == 1) {
                        cut_off_button.get_style_context ().add_class ("quick-mod-button-locked");
                    }
                }
            });
            reverb_spin_button.value_changed.connect (() => {
                if (reverb_lock) {
                    Ensembles.Core.Synthesizer.set_modulator_value (_synth_index, _channel, 91, (int)reverb_spin_button.value);
                    if (_synth_index == 1) {
                        reverb_button.get_style_context ().add_class ("quick-mod-button-locked");
                    }
                }
            });
            chorus_spin_button.value_changed.connect (() => {
                if (chorus_lock) {
                    Ensembles.Core.Synthesizer.set_modulator_value (_synth_index, _channel, 93, (int)chorus_spin_button.value);
                    if (_synth_index == 1) {
                        chorus_button.get_style_context ().add_class ("quick-mod-button-locked");
                    }
                }
            });
            modulation_button.button_release_event.connect ((event) => {
                if (event.button == 3 && _synth_index == 1) {
                    Ensembles.Core.Synthesizer.lock_modulator (1, _channel);
                    modulation_button.get_style_context ().remove_class ("quick-mod-button-locked");
                } else if (event.button == 1 && assignable) {
                    broadcast_assignment (_synth_index, _channel, 1);
                }
                return false;
            });
            pan_button.button_release_event.connect ((event) => {
                if (event.button == 3 && _synth_index == 1) {
                    Ensembles.Core.Synthesizer.lock_modulator (10, _channel);
                    pan_button.get_style_context ().remove_class ("quick-mod-button-locked");
                } else if (event.button == 1 && assignable) {
                    broadcast_assignment (_synth_index, _channel, 10);
                }
                return false;
            });
            expression_button.button_release_event.connect ((event) => {
                if (event.button == 3 && _synth_index == 1) {
                    Ensembles.Core.Synthesizer.lock_modulator (11, _channel);
                    expression_button.get_style_context ().remove_class ("quick-mod-button-locked");
                } else if (event.button == 1 && assignable) {
                    broadcast_assignment (_synth_index, _channel, 11);
                }
                return false;
            });
            pitch_button.button_release_event.connect ((event) => {
                if (event.button == 3 && _synth_index == 1) {
                    Ensembles.Core.Synthesizer.lock_modulator (3, _channel);
                    pitch_button.get_style_context ().remove_class ("quick-mod-button-locked");
                } else if (event.button == 1 && assignable) {
                    broadcast_assignment (_synth_index, _channel, 3);
                }
                return false;
            });
            resonance_button.button_release_event.connect ((event) => {
                if (event.button == 3 && _synth_index == 1) {
                    Ensembles.Core.Synthesizer.lock_modulator (71, _channel);
                    resonance_button.get_style_context ().remove_class ("quick-mod-button-locked");
                } else if (event.button == 1 && assignable) {
                    broadcast_assignment (_synth_index, _channel, 71);
                }
                return false;
            });
            cut_off_button.button_release_event.connect ((event) => {
                if (event.button == 3 && _synth_index == 1) {
                    Ensembles.Core.Synthesizer.lock_modulator (74, _channel);
                    cut_off_button.get_style_context ().remove_class ("quick-mod-button-locked");
                } else if (event.button == 1 && assignable) {
                    broadcast_assignment (_synth_index, _channel, 74);
                }
                return false;
            });
            reverb_button.button_release_event.connect ((event) => {
                if (event.button == 3 && _synth_index == 1) {
                    Ensembles.Core.Synthesizer.lock_modulator (91, _channel);
                    reverb_button.get_style_context ().remove_class ("quick-mod-button-locked");
                } else if (event.button == 1 && assignable) {
                    broadcast_assignment (_synth_index, _channel, 91);
                }
                return false;
            });
            chorus_button.button_release_event.connect ((event) => {
                if (event.button == 3 && _synth_index == 1) {
                    Ensembles.Core.Synthesizer.lock_modulator (93, _channel);
                    chorus_button.get_style_context ().remove_class ("quick-mod-button-locked");
                } else if (event.button == 1 && assignable) {
                    broadcast_assignment (_synth_index, _channel, 93);
                }
                return false;
            });
        }

        public void set_assignable (bool assignable) {
            this.assignable = assignable;
            if (assignable) {
                modulation_button.get_style_context ().add_class ("quick-mod-button-assignable");
                pan_button.get_style_context ().add_class ("quick-mod-button-assignable");
                expression_button.get_style_context ().add_class ("quick-mod-button-assignable");
                pitch_button.get_style_context ().add_class ("quick-mod-button-assignable");
                resonance_button.get_style_context ().add_class ("quick-mod-button-assignable");
                cut_off_button.get_style_context ().add_class ("quick-mod-button-assignable");
                reverb_button.get_style_context ().add_class ("quick-mod-button-assignable");
                chorus_button.get_style_context ().add_class ("quick-mod-button-assignable");
            } else {
                modulation_button.get_style_context ().remove_class ("quick-mod-button-assignable");
                pan_button.get_style_context ().remove_class ("quick-mod-button-assignable");
                expression_button.get_style_context ().remove_class ("quick-mod-button-assignable");
                pitch_button.get_style_context ().remove_class ("quick-mod-button-assignable");
                resonance_button.get_style_context ().remove_class ("quick-mod-button-assignable");
                cut_off_button.get_style_context ().remove_class ("quick-mod-button-assignable");
                reverb_button.get_style_context ().remove_class ("quick-mod-button-assignable");
                chorus_button.get_style_context ().remove_class ("quick-mod-button-assignable");
            }
            set_synth_channel_to_edit (_synth_index, _channel);
        }
    }
}
