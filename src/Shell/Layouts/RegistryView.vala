/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class RegistryView : Gtk.Grid {
        Gtk.SpinButton bank_select;
        Gtk.Button[] registry_buttons;
        Gtk.Button memory_button;

        Core.Registry[,] registry_memory;

        bool assignable = false;
        public signal void notify_recall (int tempo);
        public RegistryView () {
            row_homogeneous = true;
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
            memory_button = new Gtk.Button.with_label (_("Memorize"));
            attach (memory_button, 2, 0, 1, 1);

            var bank_label = new Gtk.Label (_("BANK"));
            bank_label.set_opacity (0.4);
            var registry_label = new Gtk.Label (_("REGISTRY MEMORY"));
            registry_label.set_opacity (0.4);

            attach (bank_label, 0, 1, 1, 1);
            attach (registry_label, 1, 1, 1, 1);

            column_spacing = 4;
            margin = 4;

            this.show_all ();

            load_registry_snapshot ();

            make_events ();
        }

        ~RegistryView () {
            save_registry_snapshot ();
        }

        void make_events () {
            memory_button.clicked.connect (() => {
                assignable = !assignable;
                make_buttons_pulse (assignable);
            });
            registry_buttons[0].clicked.connect (() => {
                if (assignable) {
                    registry_memorize (0);
                    assignable = false;
                } else {
                    registry_recall (0);
                }
            });
            registry_buttons[1].clicked.connect (() => {
                if (assignable) {
                    registry_memorize (1);
                    assignable = false;
                } else {
                    registry_recall (1);
                }
            });
            registry_buttons[2].clicked.connect (() => {
                if (assignable) {
                    registry_memorize (2);
                    assignable = false;
                } else {
                    registry_recall (2);
                }
            });
            registry_buttons[3].clicked.connect (() => {
                if (assignable) {
                    registry_memorize (3);
                    assignable = false;
                } else {
                    registry_recall (3);
                }
            });
            registry_buttons[4].clicked.connect (() => {
                if (assignable) {
                    registry_memorize (4);
                    assignable = false;
                } else {
                    registry_recall (4);
                }
            });
            registry_buttons[5].clicked.connect (() => {
                if (assignable) {
                    registry_memorize (5);
                    assignable = false;
                } else {
                    registry_recall (5);
                }
            });
            registry_buttons[6].clicked.connect (() => {
                if (assignable) {
                    registry_memorize (6);
                    assignable = false;
                } else {
                    registry_recall (6);
                }
            });
            registry_buttons[7].clicked.connect (() => {
                if (assignable) {
                    registry_memorize (7);
                    assignable = false;
                } else {
                    registry_recall (7);
                }
            });
            registry_buttons[8].clicked.connect (() => {
                if (assignable) {
                    registry_memorize (8);
                    assignable = false;
                } else {
                    registry_recall (8);
                }
            });
            registry_buttons[9].clicked.connect (() => {
                if (assignable) {
                    registry_memorize (9);
                    assignable = false;
                } else {
                    registry_recall (9);
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

        public void change_bank (bool up) {
            warning ("hello");
            if (up) {
                if (bank_select.get_value_as_int () < 9) {
                    bank_select.set_value (bank_select.get_value () + 1);
                }
            } else {
                if (bank_select.get_value_as_int () > 1) {
                    bank_select.set_value (bank_select.get_value () - 1);
                }
            }
        }

        void registry_memorize (uint index) {
            if (registry_memory == null) {
                registry_memory = new Core.Registry [16, 10];
            }
            registry_memory[bank_select.get_value_as_int () - 1, index] = new Core.Registry (
                Ensembles.Application.settings.get_int ("voice-r1-index"),
                Ensembles.Application.settings.get_int ("voice-r2-index"),
                Ensembles.Application.settings.get_int ("voice-l-index"),
                Ensembles.Application.settings.get_int ("style-index"),
                Core.CentralBus.get_tempo (),
                Ensembles.Application.settings.get_int ("transpose-level"),
                Ensembles.Application.settings.get_boolean ("transpose-on"),
                Ensembles.Application.settings.get_int ("octave-shift-level"),
                Ensembles.Application.settings.get_boolean ("octave-shift-on"),
                Ensembles.Application.settings.get_int ("reverb-level"),
                Ensembles.Application.settings.get_boolean ("reverb-on"),
                Ensembles.Application.settings.get_int ("chorus-level"),
                Ensembles.Application.settings.get_boolean ("chorus-on"),
                Ensembles.Application.settings.get_boolean ("accomp-on"),
                Ensembles.Application.settings.get_boolean ("layer-on"),
                Ensembles.Application.settings.get_boolean ("split-on"),
                Ensembles.Application.settings.get_int ("harmonizer-type"),
                Ensembles.Application.settings.get_boolean ("harmonizer-on"),
                Ensembles.Application.settings.get_int ("arpeggiator-type"),
                Ensembles.Application.settings.get_boolean ("arpeggiator-on")
            );
            make_buttons_pulse (false);
        }

        public void registry_recall (uint index) {
            uint bank = bank_select.get_value_as_int () - 1;
            if (registry_memory != null && registry_memory[bank, index] != null) {
                Ensembles.Application.settings.set_int ("voice-r1-index", registry_memory[bank, index].voice_r1);
                Ensembles.Application.settings.set_int ("voice-r2-index", registry_memory[bank, index].voice_r2);
                Ensembles.Application.settings.set_int ("voice-l-index", registry_memory[bank, index].voice_l);
                Ensembles.Application.settings.set_int ("style-index", registry_memory[bank, index].style);
                Ensembles.Application.settings.set_int ("transpose-level", registry_memory[bank, index].transpose);
                Ensembles.Application.settings.set_boolean ("transpose-on", registry_memory[bank, index].transpose_on);
                Ensembles.Application.settings.set_int ("octave-shift-level", registry_memory[bank, index].octave);
                Ensembles.Application.settings.set_boolean ("octave-shift-on", registry_memory[bank, index].octave_shift_on);
                Ensembles.Application.settings.set_int ("reverb-level", registry_memory[bank, index].reverb_level);
                Ensembles.Application.settings.set_boolean ("reverb-on", registry_memory[bank, index].reverb_on);
                Ensembles.Application.settings.set_int ("chorus-level", registry_memory[bank, index].chorus_level);
                Ensembles.Application.settings.set_boolean ("chorus-on", registry_memory[bank, index].chorus_on);
                Ensembles.Application.settings.set_boolean ("accomp-on", registry_memory[bank, index].accomp_on);
                Ensembles.Application.settings.set_boolean ("layer-on", registry_memory[bank, index].layer_on);
                Ensembles.Application.settings.set_boolean ("split-on", registry_memory[bank, index].split_on);
                Ensembles.Application.settings.set_int ("harmonizer-type", registry_memory[bank, index].harmonizer_type);
                Ensembles.Application.settings.set_boolean ("harmonizer-on", registry_memory[bank, index].harmonizer_on);
                Ensembles.Application.settings.set_int ("arpeggiator-type", registry_memory[bank, index].arpeggiator_type);
                Ensembles.Application.settings.set_boolean ("arpeggiator-on", registry_memory[bank, index].arpeggiator_on);

                notify_recall (registry_memory[bank, index].tempo);
            }
            make_buttons_pulse (false);
        }

        private void save_registry_snapshot () {
            if (registry_memory != null) {
                string registry_csv = "";
                for (int i = 0; i < 16; i++) {
                    for (int j = 0; j < 10; j++) {
                        string delimited_str = "";
                        if (registry_memory[i, j] != null) {
                            delimited_str = registry_memory[i, j].voice_r1.to_string () + "_";
                            delimited_str += registry_memory[i, j].voice_r2.to_string () + "_";
                            delimited_str += registry_memory[i, j].voice_l.to_string () + "_";
                            delimited_str += registry_memory[i, j].style.to_string () + "_";
                            delimited_str += registry_memory[i, j].tempo.to_string () + "_";
                            delimited_str += registry_memory[i, j].transpose.to_string () + "_";
                            delimited_str += (registry_memory[i, j].transpose_on ? "1" : "0") + "_";
                            delimited_str += registry_memory[i, j].octave.to_string () + "_";
                            delimited_str += (registry_memory[i, j].octave_shift_on ? "1" : "0") + "_";
                            delimited_str += registry_memory[i, j].reverb_level.to_string () + "_";
                            delimited_str += (registry_memory[i, j].reverb_on ? "1" : "0") + "_";
                            delimited_str += registry_memory[i, j].chorus_level.to_string () + "_";
                            delimited_str += (registry_memory[i, j].chorus_on ? "1" : "0") + "_";
                            delimited_str += (registry_memory[i, j].accomp_on ? "1" : "0") + "_";
                            delimited_str += (registry_memory[i, j].layer_on ? "1" : "0") + "_";
                            delimited_str += (registry_memory[i, j].split_on ? "1" : "0") + "_";
                            delimited_str += registry_memory[i, j].harmonizer_type.to_string () + "_";
                            delimited_str += (registry_memory[i, j].harmonizer_on ? "1" : "0") + "_";
                            delimited_str += registry_memory[i, j].arpeggiator_type.to_string () + "_";
                            delimited_str += (registry_memory[i, j].arpeggiator_on ? "1" : "0") + "_";
                        }

                        registry_csv += delimited_str + ",";
                    }
                    registry_csv += ";";
                }
                Ensembles.Application.settings.set_string ("registry-snapshot", registry_csv);
            }
        }

        private void load_registry_snapshot () {
            if (registry_memory == null) {
                registry_memory = new Core.Registry [16, 10];
            }
            string csv = Ensembles.Application.settings.get_string ("registry-snapshot");
            string[] banks = csv.split (";");
            for (int i = 0; i < banks.length - 1; i++) {
                string[] registries = banks[i].split (",");
                for (int j = 0; j < registries.length - 1; j++) {
                    if (registries[j] != "") {
                        string[] settings = registries[j].split ("_");
                        registry_memory[i, j] = new Core.Registry (
                            int.parse (settings[0]),
                            int.parse (settings[1]),
                            int.parse (settings[2]),
                            int.parse (settings[3]),
                            int.parse (settings[4]),
                            int.parse (settings[5]),
                            settings[6] == "1",
                            int.parse (settings[7]),
                            settings[8] == "1",
                            int.parse (settings[9]),
                            settings[10] == "1",
                            int.parse (settings[11]),
                            settings[12] == "1",
                            settings[13] == "1",
                            settings[14] == "1",
                            settings[15] == "1",
                            int.parse (settings[16]),
                            settings[17] == "1",
                            int.parse (settings[18]),
                            settings[19] == "1"
                        );
                    }
                }
            }
        }
    }
}
