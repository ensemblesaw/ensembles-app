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
    public class RegistryView : Gtk.Grid {
        Gtk.SpinButton bank_select;
        Gtk.Button[] registry_buttons;
        Gtk.Button memory_button;

        Core.Registry[,] registry_memory;

        bool assignable = false;
        public signal void change_tempo (int tempo);
        public signal void notify_recall (int tempo);
        public RegistryView () {
            row_homogeneous = true;
            vexpand = true;
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
            button_box.hexpand = true;
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

            make_events ();
        }

        void make_events () {
            memory_button.clicked.connect (() => {
                assignable = !assignable;
                make_buttons_pulse (assignable);
            });
            registry_buttons[0].clicked.connect (() => {
                if (assignable) {
                    registry_memorize (bank_select.get_value_as_int (), 0);
                    assignable = false;
                } else {
                    registry_recall (bank_select.get_value_as_int (), 0);
                }
            });
        }

        void make_buttons_pulse (bool pulse) {
            for (int i = 0; i < 10; i++) {
                if (pulse) {
                    registry_buttons[i].get_style_context ().add_class ("sampler-pad-assignable");
                } else {
                    registry_buttons[i].get_style_context ().remove_class ("sampler-pad-assignable");
                }
            }
        }

        void registry_memorize (int bank, int index) {
            if (registry_memory == null) {
                registry_memory = new Core.Registry [16, 10];
            }
            registry_memory[bank, index] = new Core.Registry (
                EnsemblesApp.settings.get_int ("voice-r1-index"),
                EnsemblesApp.settings.get_int ("voice-r2-index"),
                EnsemblesApp.settings.get_int ("voice-l-index"),
                EnsemblesApp.settings.get_int ("style-index"),
                Core.CentralBus.get_tempo (),
                EnsemblesApp.settings.get_int ("transpose-level"),
                EnsemblesApp.settings.get_boolean ("transpose-on"),
                EnsemblesApp.settings.get_int ("octave-shift-level"),
                EnsemblesApp.settings.get_boolean ("octave-shift-on"),
                EnsemblesApp.settings.get_int ("reverb-level"),
                EnsemblesApp.settings.get_boolean ("reverb-on"),
                EnsemblesApp.settings.get_int ("chorus-level"),
                EnsemblesApp.settings.get_boolean ("chorus-on"),
                EnsemblesApp.settings.get_boolean ("accomp-on"),
                EnsemblesApp.settings.get_boolean ("layer-on"),
                EnsemblesApp.settings.get_boolean ("split-on"),
                EnsemblesApp.settings.get_int ("harmonizer-type"),
                EnsemblesApp.settings.get_boolean ("harmonizer-on"),
                EnsemblesApp.settings.get_int ("arpeggiator-type"),
                EnsemblesApp.settings.get_boolean ("arpeggiator-on")
            );
            make_buttons_pulse (false);
        }

        void registry_recall (int bank, int index) {
            if (registry_memory != null && registry_memory[bank, index] != null) {
                EnsemblesApp.settings.set_int ("voice-r1-index", registry_memory[bank, index].voice_r1);
                EnsemblesApp.settings.set_int ("voice-r2-index", registry_memory[bank, index].voice_r2);
                EnsemblesApp.settings.set_int ("voice-l-index", registry_memory[bank, index].voice_l);
                EnsemblesApp.settings.set_int ("style-index", registry_memory[bank, index].style);
                change_tempo (registry_memory[bank, index].tempo);
                EnsemblesApp.settings.set_int ("transpose-level", registry_memory[bank, index].transpose);
                EnsemblesApp.settings.set_boolean ("transpose-on", registry_memory[bank, index].transpose_on);
                EnsemblesApp.settings.set_int ("octave-shift-level", registry_memory[bank, index].octave);
                EnsemblesApp.settings.set_boolean ("octave-shift-on", registry_memory[bank, index].octave_shift_on);
                EnsemblesApp.settings.set_int ("reverb-level", registry_memory[bank, index].reverb_level);
                EnsemblesApp.settings.set_boolean ("reverb-on", registry_memory[bank, index].reverb_on);
                EnsemblesApp.settings.set_int ("chorus-level", registry_memory[bank, index].chorus_level);
                EnsemblesApp.settings.set_boolean ("chorus-on", registry_memory[bank, index].chorus_on);
                EnsemblesApp.settings.set_boolean ("accomp-on", registry_memory[bank, index].accomp_on);
                EnsemblesApp.settings.set_boolean ("layer-on", registry_memory[bank, index].layer_on);
                EnsemblesApp.settings.set_boolean ("split-on", registry_memory[bank, index].split_on);
                EnsemblesApp.settings.set_int ("harmonizer-type", registry_memory[bank, index].harmonizer_type);
                EnsemblesApp.settings.set_boolean ("harmonizer-on", registry_memory[bank, index].harmonizer_on);
                EnsemblesApp.settings.set_int ("arpeggiator-type", registry_memory[bank, index].arpeggiator_type);
                EnsemblesApp.settings.set_boolean ("arpeggiator-on", registry_memory[bank, index].arpeggiator_on);

                notify_recall (registry_memory[bank, index].tempo);
            }
            make_buttons_pulse (false);
        }
    }
}
