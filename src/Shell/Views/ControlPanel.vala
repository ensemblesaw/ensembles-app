/*-
 * Copyright (c) 2021-2022 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License 
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
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
        public signal void chorus_change (int level);
        public signal void dial_rotate (bool direction, int amount);
        public signal void start_metronome (bool active);
        public signal void dial_activate ();
        public signal void update_split ();
        public ControlPanel () {
            row_spacing = 4;
            column_spacing = 4;
            column_homogeneous = true;
            hexpand = true;
            valign = Gtk.Align.START;
            margin = 4;
            width_request = 340;

            accomp_toggle = new ToggleSwitch ("Accompaniment");
            accomp_toggle.sensitive = false;
            layer_toggle = new ToggleSwitch ("Layer");
            layer_toggle.sensitive = false;
            split_toggle = new ToggleSwitch ("Split");
            split_toggle.sensitive = false;
            metronome_toggle = new ToggleSwitch ("Metronome");
            metronome_toggle.sensitive = false;

            transpose_toggle = new ToggleSwitch ("Transpose");
            transpose_toggle.sensitive = false;
            octave_toggle = new ToggleSwitch ("Octave");
            octave_toggle.sensitive = false;
            arpeggiator_toggle = new ToggleSwitch ("Arpeggiator");
            arpeggiator_toggle.sensitive = false;
            harmonizer_toggle = new ToggleSwitch ("Harmonizer");
            harmonizer_toggle.sensitive = false;
            reverb_toggle = new ToggleSwitch ("Reverb");
            reverb_toggle.sensitive = false;
            chorus_toggle = new ToggleSwitch ("Chorus");
            chorus_toggle.sensitive = false;

            transpose_spin_button = new Gtk.SpinButton.with_range (-12, 12, 1);
            transpose_spin_button.set_value (0);
            octave_spin_button = new Gtk.SpinButton.with_range (-2, 2, 1);
            octave_spin_button.set_value (0);
            arpeggiator_spin_button = new Gtk.SpinButton.with_range (1, 12, 1);
            arpeggiator_spin_button.set_value (1);
            harmonizer_spin_button = new Gtk.SpinButton.with_range (1, 16, 1);
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
                EnsemblesApp.settings.set_boolean ("accomp-on", active);
                update_split ();
            });
            layer_toggle.toggled.connect ((active) => {
                EnsemblesApp.settings.set_boolean ("layer-on", active);
                Ensembles.Core.CentralBus.set_layer_on (active);
            });
            split_toggle.toggled.connect ((active) => {
                EnsemblesApp.settings.set_boolean ("split-on", active);
                Ensembles.Core.CentralBus.set_split_on (active);
                update_split ();
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
            transpose_toggle.toggled.connect ((active) => {
                Ensembles.Core.Synthesizer.set_transpose_active (active);
                EnsemblesApp.settings.set_boolean ("transpose-on", active);
            });
            octave_toggle.toggled.connect ((active) => {
                Ensembles.Core.Synthesizer.set_octave_shifted (active);
                EnsemblesApp.settings.set_boolean ("octave-shift-on", active);
            });
            reverb_toggle.toggled.connect ((active) => {
                EnsemblesApp.settings.set_boolean ("reverb-on", active);
            });
            chorus_toggle.toggled.connect ((active) => {
                EnsemblesApp.settings.set_boolean ("chorus-on", active);
            });
            arpeggiator_toggle.toggled.connect ((active) => {
                EnsemblesApp.settings.set_boolean ("arpeggiator-on", active);
            });
            harmonizer_toggle.toggled.connect ((active) => {
                EnsemblesApp.settings.set_boolean ("harmonizer-on", active);
            });
        }

        private void transpose_spin_handler () {
            int level = (int)(transpose_spin_button.value);
            EnsemblesApp.settings.set_int ("transpose-level", level);
            Ensembles.Core.Synthesizer.set_transpose (level);
        }

        private void octave_spin_handler () {
            int level = (int)(octave_spin_button.value);
            EnsemblesApp.settings.set_int ("octave-shift-level", level);
            Ensembles.Core.Synthesizer.set_octave (level);
        }

        private void chorus_spin_handler () {
            int level = (int)(chorus_spin_button.get_value ());
            EnsemblesApp.settings.set_int ("chorus-level", level);
            chorus_change (level);
        }

        private void reverb_spin_handler () {
            int level = (int)(reverb_spin_button.get_value ());
            EnsemblesApp.settings.set_int ("reverb-level", level);
            reverb_change (level);
        }

        private void arpeggiator_spin_handler () {
            int type = (int)(arpeggiator_spin_button.get_value ());
            EnsemblesApp.settings.set_int ("arpeggiator-type", type);
        }

        private void harmonizer_spin_handler () {
            int type = (int)(harmonizer_spin_button.get_value ());
            EnsemblesApp.settings.set_int ("harmonizer-type", type);
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

            bool active = EnsemblesApp.settings.get_boolean ("accomp-on");
            accomp_change (active);
            accomp_toggle.set_active (active);
            active = EnsemblesApp.settings.get_boolean ("layer-on");
            Ensembles.Core.CentralBus.set_layer_on (active);
            layer_toggle.set_active (active);
            active = EnsemblesApp.settings.get_boolean ("split-on");
            Ensembles.Core.CentralBus.set_split_on (active);
            split_toggle.set_active (active);
            active = EnsemblesApp.settings.get_boolean ("transpose-on");
            transpose_toggle.set_active (active);
            Ensembles.Core.Synthesizer.set_transpose_active (active);
            active = EnsemblesApp.settings.get_boolean ("octave-shift-on");
            octave_toggle.set_active (active);
            Ensembles.Core.Synthesizer.set_octave_shifted (active);
            active = EnsemblesApp.settings.get_boolean ("arpeggiator-on");
            arpeggiator_toggle.set_active (active);
            active = EnsemblesApp.settings.get_boolean ("harmonizer-on");
            harmonizer_toggle.set_active (active);
            active = EnsemblesApp.settings.get_boolean ("reverb-on");
            reverb_toggle.set_active (active);
            active = EnsemblesApp.settings.get_boolean ("chorus-on");
            chorus_toggle.set_active (active);

            int level = EnsemblesApp.settings.get_int ("reverb-level");
            reverb_change (level);
            reverb_spin_button.set_value ((double) level);
            level = EnsemblesApp.settings.get_int ("chorus-level");
            chorus_change (level);
            chorus_spin_button.set_value ((double) level);
            level = EnsemblesApp.settings.get_int ("transpose-level");
            Ensembles.Core.Synthesizer.set_transpose (level);
            transpose_spin_button.set_value ((double) level);
            level = EnsemblesApp.settings.get_int ("octave-shift-level");
            octave_spin_button.set_value ((double) level);
            Ensembles.Core.Synthesizer.set_octave (level);
            level = EnsemblesApp.settings.get_int ("arpeggiator-type");
            arpeggiator_spin_button.set_value ((double) level);
            level = EnsemblesApp.settings.get_int ("harmonizer-type");
            harmonizer_spin_button.set_value ((double) level);

            update_split ();

            connect_events ();

            accomp_toggle.sensitive = true;
            layer_toggle.sensitive = true;
            split_toggle.sensitive = true;
            metronome_toggle.sensitive = true;

            transpose_toggle.sensitive = true;
            octave_toggle.sensitive = true;
            arpeggiator_toggle.sensitive = true;
            harmonizer_toggle.sensitive = true;
            reverb_toggle.sensitive = true;
            chorus_toggle.sensitive = true;
        }
    }
}
