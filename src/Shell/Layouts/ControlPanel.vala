/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

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
        public signal void reverb_change (int level);
        public signal void reverb_active_change (bool active);
        public signal void chorus_change (int level);
        public signal void chorus_active_change (bool active);
        public signal void dial_rotate (bool direction, int amount);
        public signal void start_metronome (bool active);
        public signal void dial_activate ();
        public signal void update_split ();
        public signal void open_recorder ();
        public ControlPanel () {
            row_spacing = 4;
            column_spacing = 4;
            column_homogeneous = true;
            hexpand = true;
            valign = Gtk.Align.START;
            margin = 4;
            width_request = 340;

            accomp_toggle = new ToggleSwitch (_("Chords"));
            accomp_toggle.sensitive = false;
            layer_toggle = new ToggleSwitch (_("Layer"));
            layer_toggle.sensitive = false;
            split_toggle = new ToggleSwitch (_("Split"));
            split_toggle.sensitive = false;
            metronome_toggle = new ToggleSwitch (_("Metronome"));
            metronome_toggle.sensitive = false;

            transpose_toggle = new ToggleSwitch (_("Transpose"));
            transpose_toggle.sensitive = false;
            octave_toggle = new ToggleSwitch (_("Octave"));
            octave_toggle.sensitive = false;
            arpeggiator_toggle = new ToggleSwitch (_("Arpeggiator"));
            arpeggiator_toggle.sensitive = false;
            harmonizer_toggle = new ToggleSwitch (_("Harmonizer"));
            harmonizer_toggle.sensitive = false;
            reverb_toggle = new ToggleSwitch (_("Reverb"));
            reverb_toggle.sensitive = false;
            chorus_toggle = new ToggleSwitch (_("Chorus"));
            chorus_toggle.sensitive = false;

            transpose_spin_button = new Gtk.SpinButton.with_range (-12, 12, 1);
            transpose_spin_button.set_value (0);
            octave_spin_button = new Gtk.SpinButton.with_range (-2, 2, 1);
            octave_spin_button.set_value (0);
            arpeggiator_spin_button = new Gtk.SpinButton.with_range (1, 12, 1);
            arpeggiator_spin_button.set_value (1);
            harmonizer_spin_button = new Gtk.SpinButton.with_range (1, 6, 1);
            harmonizer_spin_button.set_value (1);
            reverb_spin_button = new Gtk.SpinButton.with_range (0, 10, 1);
            reverb_spin_button.set_value (5);
            chorus_spin_button = new Gtk.SpinButton.with_range (0, 10, 1);
            chorus_spin_button.set_value (1);

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
                Ensembles.Application.settings.set_boolean ("accomp-on", active);
                update_split ();

                // Send to Sequencer for recording
                if (RecorderScreen.sequencer != null && RecorderScreen.sequencer.current_state == Core.MidiRecorder.RecorderState.RECORDING) {
                    var event = new Core.MidiEvent ();
                    event.event_type = Core.MidiEvent.EventType.ACCOMP;
                    event.value1 = active ? 1 : 0;

                    Shell.RecorderScreen.sequencer.record_event (event);
                }
            });
            layer_toggle.toggled.connect ((active) => {
                Ensembles.Application.settings.set_boolean ("layer-on", active);
                Ensembles.Core.CentralBus.set_layer_on (active);

                // Send to Sequencer for recording
                if (RecorderScreen.sequencer != null && RecorderScreen.sequencer.current_state == Core.MidiRecorder.RecorderState.RECORDING) {
                    var event = new Core.MidiEvent ();
                    event.event_type = Core.MidiEvent.EventType.LAYER;
                    event.value1 = active ? 1 : 0;

                    Shell.RecorderScreen.sequencer.record_event (event);
                }
            });
            split_toggle.toggled.connect ((active) => {
                Ensembles.Application.settings.set_boolean ("split-on", active);
                Ensembles.Core.CentralBus.set_split_on (active);
                update_split ();

                // Send to Sequencer for recording
                if (RecorderScreen.sequencer != null && RecorderScreen.sequencer.current_state == Core.MidiRecorder.RecorderState.RECORDING) {
                    var event = new Core.MidiEvent ();
                    event.event_type = Core.MidiEvent.EventType.SPLIT;
                    event.value1 = active ? 1 : 0;

                    Shell.RecorderScreen.sequencer.record_event (event);
                }
            });
            metronome_toggle.toggled.connect ((active) => {
                start_metronome (active);
            });
            main_dial.activate_clicked.connect (() => {
                dial_activate ();
            });
            main_dial.rotate.connect ((direction, amount) => {
                dial_rotate (direction, amount);
            });
            main_dial.open_recorder_screen.connect (() => {
                open_recorder ();
            });
            transpose_toggle.toggled.connect ((active) => {
                Ensembles.Core.Synthesizer.set_transpose_active (active);
                Ensembles.Application.settings.set_boolean ("transpose-on", active);

                if (active) {
                    Application.main_window.main_display_unit.update_transpose (Core.Synthesizer.get_transpose ());
                } else {
                    Application.main_window.main_display_unit.update_transpose (0);
                }
            });
            octave_toggle.toggled.connect ((active) => {
                Ensembles.Core.Synthesizer.set_octave_shifted (active);
                Ensembles.Application.settings.set_boolean ("octave-shift-on", active);

                if (active) {
                    Application.main_window.main_display_unit.update_octave (Core.Synthesizer.get_octave ());
                } else {
                    Application.main_window.main_display_unit.update_octave (0);
                }
            });
            reverb_toggle.toggled.connect ((active) => {
                reverb_active_change (active);
                Ensembles.Application.settings.set_boolean ("reverb-on", active);
            });
            chorus_toggle.toggled.connect ((active) => {
                chorus_active_change (active);
                Ensembles.Application.settings.set_boolean ("chorus-on", active);
            });
            arpeggiator_toggle.toggled.connect ((active) => {
                Ensembles.Application.settings.set_boolean ("arpeggiator-on", active);
            });
            harmonizer_toggle.toggled.connect ((active) => {
                Ensembles.Application.settings.set_boolean ("harmonizer-on", active);
            });
        }

        private void transpose_spin_handler () {
            int level = (int)(transpose_spin_button.value);
            Ensembles.Application.settings.set_int ("transpose-level", level);
            Ensembles.Core.Synthesizer.set_transpose (level);

            if (Core.Synthesizer.get_transpose_active ()) {
                Application.main_window.main_display_unit.update_transpose (level);
            } else {
                Application.main_window.main_display_unit.update_transpose (0);
            }
        }

        private void octave_spin_handler () {
            int level = (int)(octave_spin_button.value);
            Ensembles.Application.settings.set_int ("octave-shift-level", level);
            Ensembles.Core.Synthesizer.set_octave (level);

            if (Core.Synthesizer.get_octave_shifted ()) {
                Application.main_window.main_display_unit.update_octave (level);
            } else {
                Application.main_window.main_display_unit.update_octave (0);
            }
        }

        private void chorus_spin_handler () {
            int level = (int)(chorus_spin_button.get_value ());
            Ensembles.Application.settings.set_int ("chorus-level", level);
            chorus_change (level);
        }

        private void reverb_spin_handler () {
            int level = (int)(reverb_spin_button.get_value ());
            Ensembles.Application.settings.set_int ("reverb-level", level);
            reverb_change (level);
        }

        private void arpeggiator_spin_handler () {
            int type = (int)(arpeggiator_spin_button.get_value ());
            Ensembles.Application.settings.set_int ("arpeggiator-type", type);
        }

        private void harmonizer_spin_handler () {
            int type = (int)(harmonizer_spin_button.get_value ());
            Ensembles.Application.settings.set_int ("harmonizer-type", type);
        }

        private void connect_events () {
            transpose_spin_button.value_changed.connect (transpose_spin_handler);
            octave_spin_button.value_changed.connect (octave_spin_handler);
            reverb_spin_button.value_changed.connect (reverb_spin_handler);
            chorus_spin_button.value_changed.connect (chorus_spin_handler);
            arpeggiator_spin_button.value_changed.connect (arpeggiator_spin_handler);
            harmonizer_spin_button.value_changed.connect (harmonizer_spin_handler);
        }

        private void disconnect_events () {
            transpose_spin_button.value_changed.disconnect (transpose_spin_handler);
            octave_spin_button.value_changed.disconnect (octave_spin_handler);
            reverb_spin_button.value_changed.disconnect (reverb_spin_handler);
            chorus_spin_button.value_changed.disconnect (chorus_spin_handler);
            arpeggiator_spin_button.value_changed.disconnect (arpeggiator_spin_handler);
            harmonizer_spin_button.value_changed.disconnect (harmonizer_spin_handler);
        }

        public void load_settings () {
            disconnect_events ();

            bool active = Ensembles.Application.settings.get_boolean ("accomp-on");
            accomp_change (active);
            accomp_toggle.set_active (active);
            active = Ensembles.Application.settings.get_boolean ("layer-on");
            Ensembles.Core.CentralBus.set_layer_on (active);
            layer_toggle.set_active (active);
            active = Ensembles.Application.settings.get_boolean ("split-on");
            Ensembles.Core.CentralBus.set_split_on (active);
            split_toggle.set_active (active);
            active = Ensembles.Application.settings.get_boolean ("transpose-on");
            transpose_toggle.set_active (active);
            Ensembles.Core.Synthesizer.set_transpose_active (active);
            active = Ensembles.Application.settings.get_boolean ("octave-shift-on");
            octave_toggle.set_active (active);
            Ensembles.Core.Synthesizer.set_octave_shifted (active);
            active = Ensembles.Application.settings.get_boolean ("arpeggiator-on");
            arpeggiator_toggle.set_active (active);
            active = Ensembles.Application.settings.get_boolean ("harmonizer-on");
            harmonizer_toggle.set_active (active);
            active = Ensembles.Application.settings.get_boolean ("reverb-on");
            reverb_toggle.set_active (active);
            reverb_active_change (active);
            active = Ensembles.Application.settings.get_boolean ("chorus-on");
            chorus_toggle.set_active (active);
            chorus_active_change (active);

            int level = Ensembles.Application.settings.get_int ("reverb-level");
            reverb_change (level);
            reverb_spin_button.set_value ((double) level);
            level = Ensembles.Application.settings.get_int ("chorus-level");
            chorus_change (level);
            chorus_spin_button.set_value ((double) level);
            level = Ensembles.Application.settings.get_int ("transpose-level");
            Ensembles.Core.Synthesizer.set_transpose (level);
            transpose_spin_button.set_value ((double) level);
            level = Ensembles.Application.settings.get_int ("octave-shift-level");
            octave_spin_button.set_value ((double) level);
            Ensembles.Core.Synthesizer.set_octave (level);
            level = Ensembles.Application.settings.get_int ("arpeggiator-type");
            arpeggiator_spin_button.set_value ((double) level);
            level = Ensembles.Application.settings.get_int ("harmonizer-type");
            harmonizer_spin_button.set_value ((double) level);

            update_split ();

            connect_events ();

            set_panel_sensitive (true);
        }

        public void set_panel_sensitive (bool sensitive) {
            accomp_toggle.sensitive = sensitive;
            layer_toggle.sensitive = sensitive;
            split_toggle.sensitive = sensitive;
            metronome_toggle.sensitive = sensitive;

            transpose_toggle.sensitive = sensitive;
            octave_toggle.sensitive = sensitive;
            arpeggiator_toggle.sensitive = sensitive;
            harmonizer_toggle.sensitive = sensitive;
            reverb_toggle.sensitive = sensitive;
            chorus_toggle.sensitive = sensitive;
        }
    }
}
