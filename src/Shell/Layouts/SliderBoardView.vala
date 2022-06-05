/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class SliderBoardView : Gtk.Grid {
        Knob modulator_knob_a;
        Knob modulator_knob_b;
        Knob modulator_knob_c;
        Knob modulator_knob_d;
        MasterKnob master_knob;
        Gtk.Button knob_assign_button;
        Gtk.Button master_assign_button;
        Gtk.Button slider_assign_button;

        Gtk.Scale slider_0;
        Gtk.Scale slider_1;
        Gtk.Scale slider_2;
        Gtk.Scale slider_3;
        Gtk.Scale slider_4;
        Gtk.Scale slider_5;
        Gtk.Scale slider_6;
        Gtk.Scale slider_7;
        Gtk.Scale slider_8;
        Gtk.Scale slider_9;

        JoyStick joystick;

        public signal void change_modulator (int id, double value);
        public signal void send_assignable_mode (bool assignable);
        public signal void open_LFO_editor ();

        bool slider_assign_mode;
        bool knob_assign_mode;
        int assignable_slider_index = -1;
        int assignable_knob_index = -1;

        struct SliderMap {
            bool assigned;
            public int channel;
            public int modulator;
        }

        SliderMap slider_0_variables;
        SliderMap slider_1_variables;
        SliderMap slider_2_variables;
        SliderMap slider_3_variables;
        SliderMap slider_4_variables;
        SliderMap slider_5_variables;
        SliderMap slider_6_variables;
        SliderMap slider_7_variables;
        SliderMap slider_8_variables;
        SliderMap slider_9_variables;

        SliderMap knob_a_variables;
        SliderMap knob_b_variables;
        SliderMap knob_c_variables;
        SliderMap knob_d_variables;

        SliderMap joystick_x_variables;
        SliderMap joystick_y_variables;

        bool[] master_knob_assigns;
        bool master_assign_mode;

        bool monitoring_lfo = false;

        public SliderBoardView (JoyStick joystick_instance) {
            joystick = joystick_instance;
            row_spacing = 4;
            margin = 4;
            width_request = 408;
            height_request = 236;


            modulator_knob_a = new Knob ();
            modulator_knob_b = new Knob ();
            modulator_knob_c = new Knob ();
            modulator_knob_d = new Knob ();

            master_knob = new MasterKnob ();


            knob_assign_button = new Gtk.Button.with_label (_("Knob Assign"));
            master_assign_button = new Gtk.Button.with_label (_("Master Knob Assign"));
            var knob_assign_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            knob_assign_box.add (knob_assign_button);
            knob_assign_box.add (master_assign_button);
            knob_assign_box.set_layout (Gtk.ButtonBoxStyle.EXPAND);

            slider_assign_button = new Gtk.Button.with_label (_("Slider Assign"));

            slider_0 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1) {
                vexpand = true,
                height_request = 127,
                inverted = true,
                draw_value = false
            };
            slider_1 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1) {
                height_request = 127,
                inverted = true,
                draw_value = false
            };
            slider_2 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1) {
                height_request = 127,
                inverted = true,
                draw_value = false
            };
            slider_3 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1) {
                height_request = 127,
                inverted = true,
                draw_value = false
            };
            slider_4 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1) {
                height_request = 127,
                inverted = true,
                draw_value = false
            };
            slider_5 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1) {
                height_request = 127,
                inverted = true,
                draw_value = false
            };
            slider_6 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1) {
                height_request = 127,
                inverted = true,
                draw_value = false
            };
            slider_7 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1) {
                height_request = 127,
                inverted = true,
                draw_value = false
            };
            slider_8 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1) {
                height_request = 127,
                inverted = true,
                draw_value = false
            };
            slider_9 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1) {
                height_request = 127,
                inverted = true,
                draw_value = false
            };

            var slider_grid = new Gtk.Grid () {
                column_spacing = 14,
                margin_start = 8
            };

            slider_grid.attach (slider_0, 0, 0, 1, 1);
            slider_grid.attach (slider_1, 1, 0, 1, 1);
            slider_grid.attach (slider_2, 2, 0, 1, 1);
            slider_grid.attach (slider_3, 3, 0, 1, 1);
            slider_grid.attach (slider_4, 4, 0, 1, 1);
            slider_grid.attach (slider_5, 5, 0, 1, 1);
            slider_grid.attach (slider_6, 6, 0, 1, 1);
            slider_grid.attach (slider_7, 7, 0, 1, 1);
            slider_grid.attach (slider_8, 8, 0, 1, 1);
            slider_grid.attach (slider_9, 9, 0, 1, 1);

            slider_grid.column_homogeneous = true;
            slider_grid.hexpand = true;

            for (int i = 0; i < 10; i++) {
                slider_grid.attach (new Gtk.Label ((i + 1).to_string ()), i, 1, 1, 1);
            }

            attach (knob_assign_box, 0, 0, 5, 1);
            attach (modulator_knob_a, 0, 1, 1, 1);
            attach (new Gtk.Label ("1"), 0, 2, 1, 1);
            attach (modulator_knob_b, 1, 1, 1, 1);
            attach (new Gtk.Label ("2"), 1, 2, 1, 1);
            attach (modulator_knob_c, 2, 1, 1, 1);
            attach (new Gtk.Label ("3"), 2, 2, 1, 1);
            attach (modulator_knob_d, 3, 1, 1, 1);
            attach (new Gtk.Label ("4"), 3, 2, 1, 1);
            attach (slider_assign_button, 0, 3, 4, 1);
            attach (master_knob, 4, 1, 1, 3);
            attach (slider_grid, 0, 4, 5, 1);

            show_all ();

            joystick.assignable_clicked_x.connect ((assignable) => {
                send_assignable_mode (assignable);
            });

            joystick.assignable_clicked_y.connect ((assignable) => {
                send_assignable_mode (assignable);
            });

            slider_assign_button.clicked.connect (() => {
                slider_assign_mode = !slider_assign_mode;
                send_assignable_mode (slider_assign_mode);
                knob_assign_button.sensitive = !slider_assign_mode;
                master_assign_button.sensitive = !slider_assign_mode;
                if (slider_assign_mode) {
                    slider_0.get_style_context ().add_class ("slider-assignable");
                    slider_1.get_style_context ().add_class ("slider-assignable");
                    slider_2.get_style_context ().add_class ("slider-assignable");
                    slider_3.get_style_context ().add_class ("slider-assignable");
                    slider_4.get_style_context ().add_class ("slider-assignable");
                    slider_5.get_style_context ().add_class ("slider-assignable");
                    slider_6.get_style_context ().add_class ("slider-assignable");
                    slider_7.get_style_context ().add_class ("slider-assignable");
                    slider_8.get_style_context ().add_class ("slider-assignable");
                    slider_9.get_style_context ().add_class ("slider-assignable");
                } else {
                    slider_0.get_style_context ().remove_class ("slider-assignable");
                    slider_1.get_style_context ().remove_class ("slider-assignable");
                    slider_2.get_style_context ().remove_class ("slider-assignable");
                    slider_3.get_style_context ().remove_class ("slider-assignable");
                    slider_4.get_style_context ().remove_class ("slider-assignable");
                    slider_5.get_style_context ().remove_class ("slider-assignable");
                    slider_6.get_style_context ().remove_class ("slider-assignable");
                    slider_7.get_style_context ().remove_class ("slider-assignable");
                    slider_8.get_style_context ().remove_class ("slider-assignable");
                    slider_9.get_style_context ().remove_class ("slider-assignable");
                    assignable_slider_index = -1;
                }
            });

            knob_assign_button.clicked.connect (() => {
                knob_assign_mode = !knob_assign_mode;
                send_assignable_mode (knob_assign_mode);
                slider_assign_button.sensitive = !knob_assign_mode;
                master_assign_button.sensitive = !knob_assign_mode;
                if (knob_assign_mode) {
                    modulator_knob_a.get_style_context ().add_class ("knob-assignable");
                    modulator_knob_b.get_style_context ().add_class ("knob-assignable");
                    modulator_knob_c.get_style_context ().add_class ("knob-assignable");
                    modulator_knob_d.get_style_context ().add_class ("knob-assignable");
                } else {
                    modulator_knob_a.get_style_context ().remove_class ("knob-assignable");
                    modulator_knob_b.get_style_context ().remove_class ("knob-assignable");
                    modulator_knob_c.get_style_context ().remove_class ("knob-assignable");
                    modulator_knob_d.get_style_context ().remove_class ("knob-assignable");
                    assignable_knob_index = -1;
                }
            });

            master_assign_button.clicked.connect (() => {
                master_assign_mode = !master_assign_mode;
                master_knob_assigns = new bool[14];
                slider_0.get_style_context ().remove_class ("slider-super-controlled");
                slider_1.get_style_context ().remove_class ("slider-super-controlled");
                slider_2.get_style_context ().remove_class ("slider-super-controlled");
                slider_3.get_style_context ().remove_class ("slider-super-controlled");
                slider_4.get_style_context ().remove_class ("slider-super-controlled");
                slider_5.get_style_context ().remove_class ("slider-super-controlled");
                slider_6.get_style_context ().remove_class ("slider-super-controlled");
                slider_7.get_style_context ().remove_class ("slider-super-controlled");
                slider_8.get_style_context ().remove_class ("slider-super-controlled");
                slider_9.get_style_context ().remove_class ("slider-super-controlled");
                modulator_knob_a.get_style_context ().remove_class ("knob-super-controlled");
                modulator_knob_b.get_style_context ().remove_class ("knob-super-controlled");
                modulator_knob_c.get_style_context ().remove_class ("knob-super-controlled");
                modulator_knob_d.get_style_context ().remove_class ("knob-super-controlled");
                if (master_assign_mode) {
                    slider_0.get_style_context ().add_class ("slider-super-assignable");
                    slider_1.get_style_context ().add_class ("slider-super-assignable");
                    slider_2.get_style_context ().add_class ("slider-super-assignable");
                    slider_3.get_style_context ().add_class ("slider-super-assignable");
                    slider_4.get_style_context ().add_class ("slider-super-assignable");
                    slider_5.get_style_context ().add_class ("slider-super-assignable");
                    slider_6.get_style_context ().add_class ("slider-super-assignable");
                    slider_7.get_style_context ().add_class ("slider-super-assignable");
                    slider_8.get_style_context ().add_class ("slider-super-assignable");
                    slider_9.get_style_context ().add_class ("slider-super-assignable");
                    modulator_knob_a.get_style_context ().add_class ("knob-super-assignable");
                    modulator_knob_b.get_style_context ().add_class ("knob-super-assignable");
                    modulator_knob_c.get_style_context ().add_class ("knob-super-assignable");
                    modulator_knob_d.get_style_context ().add_class ("knob-super-assignable");
                } else {
                    slider_0.get_style_context ().remove_class ("slider-super-assignable");
                    slider_1.get_style_context ().remove_class ("slider-super-assignable");
                    slider_2.get_style_context ().remove_class ("slider-super-assignable");
                    slider_3.get_style_context ().remove_class ("slider-super-assignable");
                    slider_4.get_style_context ().remove_class ("slider-super-assignable");
                    slider_5.get_style_context ().remove_class ("slider-super-assignable");
                    slider_6.get_style_context ().remove_class ("slider-super-assignable");
                    slider_7.get_style_context ().remove_class ("slider-super-assignable");
                    slider_8.get_style_context ().remove_class ("slider-super-assignable");
                    slider_9.get_style_context ().remove_class ("slider-super-assignable");
                    modulator_knob_a.get_style_context ().remove_class ("knob-super-assignable");
                    modulator_knob_b.get_style_context ().remove_class ("knob-super-assignable");
                    modulator_knob_c.get_style_context ().remove_class ("knob-super-assignable");
                    modulator_knob_d.get_style_context ().remove_class ("knob-super-assignable");
                }
                slider_assign_button.sensitive = !master_assign_mode;
                knob_assign_button.sensitive = !master_assign_mode;
                master_knob.set_color (false, 0);
            });

            joystick.drag_x.connect ((value) => {
                if (joystick_x_variables.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (joystick_x_variables.channel,
                                                                    joystick_x_variables.modulator,
                                                                    (int)(value));
                }
            });

            joystick.drag_y.connect ((value) => {
                if (joystick_y_variables.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (joystick_y_variables.channel,
                                                                    joystick_y_variables.modulator,
                                                                    (int)(value));
                }
            });

            slider_0.change_value.connect ((scroll, value) => {
                if (slider_0_variables.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (slider_0_variables.channel,
                                                                    slider_0_variables.modulator,
                                                                    (int)(value * 127));
                }
                assignable_slider_index = 0;
                slider_1.get_style_context ().remove_class ("slider-assignable");
                slider_2.get_style_context ().remove_class ("slider-assignable");
                slider_3.get_style_context ().remove_class ("slider-assignable");
                slider_4.get_style_context ().remove_class ("slider-assignable");
                slider_5.get_style_context ().remove_class ("slider-assignable");
                slider_6.get_style_context ().remove_class ("slider-assignable");
                slider_7.get_style_context ().remove_class ("slider-assignable");
                slider_8.get_style_context ().remove_class ("slider-assignable");
                slider_9.get_style_context ().remove_class ("slider-assignable");
                if (master_assign_mode) {
                    master_knob_assigns[0] = true;
                    slider_0.get_style_context ().add_class ("slider-super-controlled");
                    slider_0.get_style_context ().remove_class ("slider-super-assignable");
                }
                if (slider_assign_mode) {
                    slider_0.get_style_context ().add_class ("slider-assignable");
                }
                return false;
            });
            slider_1.change_value.connect ((scroll, value) => {
                if (slider_1_variables.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_1_variables.channel,
                        slider_1_variables.modulator,
                        (int)(value * 127)
                    );
                }
                assignable_slider_index = 1;
                slider_0.get_style_context ().remove_class ("slider-assignable");
                slider_2.get_style_context ().remove_class ("slider-assignable");
                slider_3.get_style_context ().remove_class ("slider-assignable");
                slider_4.get_style_context ().remove_class ("slider-assignable");
                slider_5.get_style_context ().remove_class ("slider-assignable");
                slider_6.get_style_context ().remove_class ("slider-assignable");
                slider_7.get_style_context ().remove_class ("slider-assignable");
                slider_8.get_style_context ().remove_class ("slider-assignable");
                slider_9.get_style_context ().remove_class ("slider-assignable");
                if (master_assign_mode) {
                    master_knob_assigns[1] = true;
                    slider_1.get_style_context ().add_class ("slider-super-controlled");
                    slider_1.get_style_context ().remove_class ("slider-super-assignable");
                }
                if (slider_assign_mode) {
                    slider_1.get_style_context ().add_class ("slider-assignable");
                }
                return false;
            });
            slider_2.change_value.connect ((scroll, value) => {
                if (slider_2_variables.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_2_variables.channel,
                        slider_2_variables.modulator,
                        (int)(value * 127)
                    );
                }
                assignable_slider_index = 2;
                slider_0.get_style_context ().remove_class ("slider-assignable");
                slider_1.get_style_context ().remove_class ("slider-assignable");
                slider_3.get_style_context ().remove_class ("slider-assignable");
                slider_4.get_style_context ().remove_class ("slider-assignable");
                slider_5.get_style_context ().remove_class ("slider-assignable");
                slider_6.get_style_context ().remove_class ("slider-assignable");
                slider_7.get_style_context ().remove_class ("slider-assignable");
                slider_8.get_style_context ().remove_class ("slider-assignable");
                slider_9.get_style_context ().remove_class ("slider-assignable");
                if (master_assign_mode) {
                    master_knob_assigns[2] = true;
                    slider_2.get_style_context ().add_class ("slider-super-controlled");
                    slider_2.get_style_context ().remove_class ("slider-super-assignable");
                }
                if (slider_assign_mode) {
                    slider_2.get_style_context ().add_class ("slider-assignable");
                }
                return false;
            });
            slider_3.change_value.connect ((scroll, value) => {
                if (slider_3_variables.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_3_variables.channel,
                        slider_3_variables.modulator,
                        (int)(value * 127)
                    );
                }
                assignable_slider_index = 3;
                slider_0.get_style_context ().remove_class ("slider-assignable");
                slider_1.get_style_context ().remove_class ("slider-assignable");
                slider_2.get_style_context ().remove_class ("slider-assignable");
                slider_4.get_style_context ().remove_class ("slider-assignable");
                slider_5.get_style_context ().remove_class ("slider-assignable");
                slider_6.get_style_context ().remove_class ("slider-assignable");
                slider_7.get_style_context ().remove_class ("slider-assignable");
                slider_8.get_style_context ().remove_class ("slider-assignable");
                slider_9.get_style_context ().remove_class ("slider-assignable");
                if (master_assign_mode) {
                    master_knob_assigns[3] = true;
                    slider_3.get_style_context ().add_class ("slider-super-controlled");
                    slider_3.get_style_context ().remove_class ("slider-super-assignable");
                }
                if (slider_assign_mode) {
                    slider_3.get_style_context ().add_class ("slider-assignable");
                }
                return false;
            });
            slider_4.change_value.connect ((scroll, value) => {
                if (slider_4_variables.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_4_variables.channel, slider_4_variables.modulator, (int)(value * 127)
                    );
                }
                assignable_slider_index = 4;
                slider_0.get_style_context ().remove_class ("slider-assignable");
                slider_1.get_style_context ().remove_class ("slider-assignable");
                slider_2.get_style_context ().remove_class ("slider-assignable");
                slider_3.get_style_context ().remove_class ("slider-assignable");
                slider_5.get_style_context ().remove_class ("slider-assignable");
                slider_6.get_style_context ().remove_class ("slider-assignable");
                slider_7.get_style_context ().remove_class ("slider-assignable");
                slider_8.get_style_context ().remove_class ("slider-assignable");
                slider_9.get_style_context ().remove_class ("slider-assignable");
                if (master_assign_mode) {
                    master_knob_assigns[4] = true;
                    slider_4.get_style_context ().add_class ("slider-super-controlled");
                    slider_4.get_style_context ().remove_class ("slider-super-assignable");
                }
                if (slider_assign_mode) {
                    slider_4.get_style_context ().add_class ("slider-assignable");
                }
                return false;
            });
            slider_5.change_value.connect ((scroll, value) => {
                if (slider_5_variables.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_5_variables.channel, slider_5_variables.modulator, (int)(value * 127)
                    );
                }
                assignable_slider_index = 5;
                slider_0.get_style_context ().remove_class ("slider-assignable");
                slider_1.get_style_context ().remove_class ("slider-assignable");
                slider_2.get_style_context ().remove_class ("slider-assignable");
                slider_3.get_style_context ().remove_class ("slider-assignable");
                slider_4.get_style_context ().remove_class ("slider-assignable");
                slider_6.get_style_context ().remove_class ("slider-assignable");
                slider_7.get_style_context ().remove_class ("slider-assignable");
                slider_8.get_style_context ().remove_class ("slider-assignable");
                slider_9.get_style_context ().remove_class ("slider-assignable");
                if (master_assign_mode) {
                    master_knob_assigns[5] = true;
                    slider_5.get_style_context ().add_class ("slider-super-controlled");
                    slider_5.get_style_context ().remove_class ("slider-super-assignable");
                }
                if (slider_assign_mode) {
                    slider_5.get_style_context ().add_class ("slider-assignable");
                }
                return false;
            });
            slider_6.change_value.connect ((scroll, value) => {
                if (slider_6_variables.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_6_variables.channel, slider_6_variables.modulator, (int)(value * 127)
                    );
                }
                assignable_slider_index = 6;
                slider_0.get_style_context ().remove_class ("slider-assignable");
                slider_1.get_style_context ().remove_class ("slider-assignable");
                slider_2.get_style_context ().remove_class ("slider-assignable");
                slider_3.get_style_context ().remove_class ("slider-assignable");
                slider_4.get_style_context ().remove_class ("slider-assignable");
                slider_5.get_style_context ().remove_class ("slider-assignable");
                slider_7.get_style_context ().remove_class ("slider-assignable");
                slider_8.get_style_context ().remove_class ("slider-assignable");
                slider_9.get_style_context ().remove_class ("slider-assignable");
                if (master_assign_mode) {
                    master_knob_assigns[6] = true;
                    slider_6.get_style_context ().add_class ("slider-super-controlled");
                    slider_6.get_style_context ().remove_class ("slider-super-assignable");
                }
                if (slider_assign_mode) {
                    slider_6.get_style_context ().add_class ("slider-assignable");
                }
                return false;
            });
            slider_7.change_value.connect ((scroll, value) => {
                if (slider_7_variables.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_7_variables.channel, slider_7_variables.modulator, (int)(value * 127)
                    );
                }
                assignable_slider_index = 7;
                slider_0.get_style_context ().remove_class ("slider-assignable");
                slider_1.get_style_context ().remove_class ("slider-assignable");
                slider_2.get_style_context ().remove_class ("slider-assignable");
                slider_3.get_style_context ().remove_class ("slider-assignable");
                slider_4.get_style_context ().remove_class ("slider-assignable");
                slider_5.get_style_context ().remove_class ("slider-assignable");
                slider_6.get_style_context ().remove_class ("slider-assignable");
                slider_8.get_style_context ().remove_class ("slider-assignable");
                slider_9.get_style_context ().remove_class ("slider-assignable");
                if (master_assign_mode) {
                    master_knob_assigns[7] = true;
                    slider_7.get_style_context ().add_class ("slider-super-controlled");
                    slider_7.get_style_context ().remove_class ("slider-super-assignable");
                }
                if (slider_assign_mode) {
                    slider_7.get_style_context ().add_class ("slider-assignable");
                }
                return false;
            });
            slider_8.change_value.connect ((scroll, value) => {
                if (slider_8_variables.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_8_variables.channel, slider_8_variables.modulator, (int)(value * 127)
                    );
                }
                assignable_slider_index = 8;
                slider_0.get_style_context ().remove_class ("slider-assignable");
                slider_1.get_style_context ().remove_class ("slider-assignable");
                slider_2.get_style_context ().remove_class ("slider-assignable");
                slider_3.get_style_context ().remove_class ("slider-assignable");
                slider_4.get_style_context ().remove_class ("slider-assignable");
                slider_5.get_style_context ().remove_class ("slider-assignable");
                slider_6.get_style_context ().remove_class ("slider-assignable");
                slider_7.get_style_context ().remove_class ("slider-assignable");
                slider_9.get_style_context ().remove_class ("slider-assignable");
                if (master_assign_mode) {
                    master_knob_assigns[8] = true;
                    slider_8.get_style_context ().add_class ("slider-super-controlled");
                    slider_8.get_style_context ().remove_class ("slider-super-assignable");
                }
                if (slider_assign_mode) {
                    slider_8.get_style_context ().add_class ("slider-assignable");
                }
                return false;
            });
            slider_9.change_value.connect ((scroll, value) => {
                if (slider_9_variables.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_9_variables.channel, slider_9_variables.modulator, (int)(value * 127)
                    );
                }
                assignable_slider_index = 9;
                slider_0.get_style_context ().remove_class ("slider-assignable");
                slider_1.get_style_context ().remove_class ("slider-assignable");
                slider_2.get_style_context ().remove_class ("slider-assignable");
                slider_3.get_style_context ().remove_class ("slider-assignable");
                slider_4.get_style_context ().remove_class ("slider-assignable");
                slider_5.get_style_context ().remove_class ("slider-assignable");
                slider_6.get_style_context ().remove_class ("slider-assignable");
                slider_7.get_style_context ().remove_class ("slider-assignable");
                slider_8.get_style_context ().remove_class ("slider-assignable");
                if (master_assign_mode) {
                    master_knob_assigns[9] = true;
                    slider_9.get_style_context ().add_class ("slider-super-controlled");
                    slider_9.get_style_context ().remove_class ("slider-super-assignable");
                }
                if (slider_assign_mode) {
                    slider_9.get_style_context ().add_class ("slider-assignable");
                }
                return false;
            });
            modulator_knob_a.change_value.connect ((value) => {
                if (knob_a_variables.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        knob_a_variables.channel, knob_a_variables.modulator, (int)(value * 127)
                    );
                }
                assignable_knob_index = 0;
                modulator_knob_b.get_style_context ().remove_class ("knob-assignable");
                modulator_knob_c.get_style_context ().remove_class ("knob-assignable");
                modulator_knob_d.get_style_context ().remove_class ("knob-assignable");
                if (master_assign_mode) {
                    master_knob_assigns[10] = true;
                    modulator_knob_a.get_style_context ().add_class ("knob-super-controlled");
                    modulator_knob_a.get_style_context ().remove_class ("knob-super-assignable");
                }
                if (knob_assign_mode) {
                    modulator_knob_a.get_style_context ().add_class ("knob-assignable");
                }
            });
            modulator_knob_b.change_value.connect ((value) => {
                if (knob_b_variables.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        knob_b_variables.channel, knob_b_variables.modulator, (int)(value * 127)
                    );
                }
                assignable_knob_index = 1;
                modulator_knob_a.get_style_context ().remove_class ("knob-assignable");
                modulator_knob_c.get_style_context ().remove_class ("knob-assignable");
                modulator_knob_d.get_style_context ().remove_class ("knob-assignable");
                if (master_assign_mode) {
                    master_knob_assigns[11] = true;
                    modulator_knob_b.get_style_context ().add_class ("knob-super-controlled");
                    modulator_knob_b.get_style_context ().remove_class ("knob-super-assignable");
                }
                if (knob_assign_mode) {
                    modulator_knob_b.get_style_context ().add_class ("knob-assignable");
                }
            });
            modulator_knob_c.change_value.connect ((value) => {
                if (knob_c_variables.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        knob_c_variables.channel, knob_c_variables.modulator, (int)(value * 127)
                    );
                }
                assignable_knob_index = 2;
                modulator_knob_a.get_style_context ().remove_class ("knob-assignable");
                modulator_knob_b.get_style_context ().remove_class ("knob-assignable");
                modulator_knob_d.get_style_context ().remove_class ("knob-assignable");
                if (master_assign_mode) {
                    master_knob_assigns[12] = true;
                    modulator_knob_c.get_style_context ().add_class ("knob-super-controlled");
                    modulator_knob_c.get_style_context ().remove_class ("knob-super-assignable");
                }
                if (knob_assign_mode) {
                    modulator_knob_c.get_style_context ().add_class ("knob-assignable");
                }
            });
            modulator_knob_d.change_value.connect ((value) => {
                if (knob_d_variables.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        knob_d_variables.channel, knob_d_variables.modulator, (int)(value * 127)
                    );
                }
                assignable_knob_index = 3;
                modulator_knob_a.get_style_context ().remove_class ("knob-assignable");
                modulator_knob_b.get_style_context ().remove_class ("knob-assignable");
                modulator_knob_c.get_style_context ().remove_class ("knob-assignable");
                if (master_assign_mode) {
                    master_knob_assigns[13] = true;
                    modulator_knob_d.get_style_context ().add_class ("knob-super-controlled");
                    modulator_knob_d.get_style_context ().remove_class ("knob-super-assignable");
                }
                if (knob_assign_mode) {
                    modulator_knob_d.get_style_context ().add_class ("knob-assignable");
                }
            });

            master_knob.change_value.connect ((value) => {
                bool assigned = false;
                if (master_knob_assigns != null) {
                    if (master_knob_assigns[0] && slider_0_variables.assigned) {
                        slider_0.set_value (value);
                        Ensembles.Core.Synthesizer.set_modulator_value (
                            slider_0_variables.channel, slider_0_variables.modulator, (int)(value * 127)
                        );
                    }
                    if (master_knob_assigns[1] && slider_1_variables.assigned) {
                        slider_1.set_value (value);
                        Ensembles.Core.Synthesizer.set_modulator_value (
                            slider_1_variables.channel, slider_1_variables.modulator, (int)(value * 127)
                        );
                    }
                    if (master_knob_assigns[2] && slider_2_variables.assigned) {
                        slider_2.set_value (value);
                        Ensembles.Core.Synthesizer.set_modulator_value (
                            slider_2_variables.channel, slider_2_variables.modulator, (int)(value * 127)
                        );
                    }
                    if (master_knob_assigns[3] && slider_3_variables.assigned) {
                        slider_3.set_value (value);
                        Ensembles.Core.Synthesizer.set_modulator_value (
                            slider_3_variables.channel, slider_3_variables.modulator, (int)(value * 127)
                        );
                    }
                    if (master_knob_assigns[4] && slider_4_variables.assigned) {
                        slider_4.set_value (value);
                        Ensembles.Core.Synthesizer.set_modulator_value (
                            slider_4_variables.channel, slider_4_variables.modulator, (int)(value * 127)
                        );
                    }
                    if (master_knob_assigns[5] && slider_5_variables.assigned) {
                        slider_5.set_value (value);
                        Ensembles.Core.Synthesizer.set_modulator_value (
                            slider_5_variables.channel, slider_5_variables.modulator, (int)(value * 127)
                        );
                    }
                    if (master_knob_assigns[6] && slider_6_variables.assigned) {
                        slider_6.set_value (value);
                        Ensembles.Core.Synthesizer.set_modulator_value (
                            slider_6_variables.channel, slider_6_variables.modulator, (int)(value * 127)
                        );
                    }
                    if (master_knob_assigns[7] && slider_7_variables.assigned) {
                        slider_7.set_value (value);
                        Ensembles.Core.Synthesizer.set_modulator_value (
                            slider_7_variables.channel, slider_7_variables.modulator, (int)(value * 127)
                        );
                    }
                    if (master_knob_assigns[8] && slider_8_variables.assigned) {
                        slider_8.set_value (value);
                        Ensembles.Core.Synthesizer.set_modulator_value (
                            slider_8_variables.channel, slider_8_variables.modulator, (int)(value * 127)
                        );
                    }
                    if (master_knob_assigns[9] && slider_9_variables.assigned) {
                        slider_9.set_value (value);
                        Ensembles.Core.Synthesizer.set_modulator_value (
                            slider_9_variables.channel, slider_9_variables.modulator, (int)(value * 127)
                        );
                    }
                    if (master_knob_assigns[10] && knob_a_variables.assigned) {
                        modulator_knob_a.set_value (value);
                        Ensembles.Core.Synthesizer.set_modulator_value (
                            knob_a_variables.channel, knob_a_variables.modulator, (int)(value * 127)
                        );
                    }
                    if (master_knob_assigns[11] && knob_b_variables.assigned) {
                        modulator_knob_b.set_value (value);
                        Ensembles.Core.Synthesizer.set_modulator_value (
                            knob_b_variables.channel, knob_b_variables.modulator, (int)(value * 127)
                        );
                    }
                    if (master_knob_assigns[12] && knob_c_variables.assigned) {
                        modulator_knob_c.set_value (value);
                        Ensembles.Core.Synthesizer.set_modulator_value (
                            knob_c_variables.channel, knob_c_variables.modulator, (int)(value * 127)
                        );
                    }
                    if (master_knob_assigns[13] && knob_d_variables.assigned) {
                        modulator_knob_d.set_value (value);
                        Ensembles.Core.Synthesizer.set_modulator_value (
                            knob_d_variables.channel, knob_d_variables.modulator, (int)(value * 127)
                        );
                    }
                    for (int i = 0; i < 14; i++) {
                        if (master_knob_assigns[i]) {
                            assigned = true;
                            break;
                        }
                    }
                }
                slider_0.get_style_context ().remove_class ("slider-super-assignable");
                slider_1.get_style_context ().remove_class ("slider-super-assignable");
                slider_2.get_style_context ().remove_class ("slider-super-assignable");
                slider_3.get_style_context ().remove_class ("slider-super-assignable");
                slider_4.get_style_context ().remove_class ("slider-super-assignable");
                slider_5.get_style_context ().remove_class ("slider-super-assignable");
                slider_6.get_style_context ().remove_class ("slider-super-assignable");
                slider_7.get_style_context ().remove_class ("slider-super-assignable");
                slider_8.get_style_context ().remove_class ("slider-super-assignable");
                slider_9.get_style_context ().remove_class ("slider-super-assignable");
                modulator_knob_a.get_style_context ().remove_class ("knob-super-assignable");
                modulator_knob_b.get_style_context ().remove_class ("knob-super-assignable");
                modulator_knob_c.get_style_context ().remove_class ("knob-super-assignable");
                modulator_knob_d.get_style_context ().remove_class ("knob-super-assignable");
                master_knob.set_color (assigned, (int)(value * 10));
                if (master_assign_mode) {
                    open_LFO_editor ();
                }
                master_assign_mode = false;
                slider_assign_button.sensitive = true;
                knob_assign_button.sensitive = true;
            });
            monitoring_lfo = true;
            monitor_lfo ();
        }

        public void stop_monitoring () {
            monitoring_lfo = false;
        }

        ~SliderBoardView () {
            stop_monitoring ();
        }

        public void send_modulator (int channel, int modulator) {
            if (slider_assign_mode) {
                switch (assignable_slider_index) {
                    case 0:
                    slider_0_variables = { true, channel, modulator };
                    break;
                    case 1:
                    slider_1_variables = { true, channel, modulator };
                    break;
                    case 2:
                    slider_2_variables = { true, channel, modulator };
                    break;
                    case 3:
                    slider_3_variables = { true, channel, modulator };
                    break;
                    case 4:
                    slider_4_variables = { true, channel, modulator };
                    break;
                    case 5:
                    slider_5_variables = { true, channel, modulator };
                    break;
                    case 6:
                    slider_6_variables = { true, channel, modulator };
                    break;
                    case 7:
                    slider_7_variables = { true, channel, modulator };
                    break;
                    case 8:
                    slider_8_variables = { true, channel, modulator };
                    break;
                    case 9:
                    slider_9_variables = { true, channel, modulator };
                    break;
                }
                assignable_slider_index = -1;
                slider_assign_mode = false;
                send_assignable_mode (false);
                slider_0.get_style_context ().remove_class ("slider-assignable");
                slider_1.get_style_context ().remove_class ("slider-assignable");
                slider_2.get_style_context ().remove_class ("slider-assignable");
                slider_3.get_style_context ().remove_class ("slider-assignable");
                slider_4.get_style_context ().remove_class ("slider-assignable");
                slider_5.get_style_context ().remove_class ("slider-assignable");
                slider_6.get_style_context ().remove_class ("slider-assignable");
                slider_7.get_style_context ().remove_class ("slider-assignable");
                slider_8.get_style_context ().remove_class ("slider-assignable");
                slider_9.get_style_context ().remove_class ("slider-assignable");
            }
            if (knob_assign_mode) {
                switch (assignable_knob_index) {
                    case 0:
                    knob_a_variables = { true, channel, modulator };
                    break;
                    case 1:
                    knob_b_variables = { true, channel, modulator };
                    break;
                    case 2:
                    knob_c_variables = { true, channel, modulator };
                    break;
                    case 3:
                    knob_d_variables = { true, channel, modulator };
                    break;
                }
                assignable_knob_index = -1;
                knob_assign_mode = false;
                send_assignable_mode (false);
                modulator_knob_a.get_style_context ().remove_class ("knob-assignable");
                modulator_knob_b.get_style_context ().remove_class ("knob-assignable");
                modulator_knob_c.get_style_context ().remove_class ("knob-assignable");
                modulator_knob_d.get_style_context ().remove_class ("knob-assignable");
            } else if (joystick.assignable) {
                switch (joystick.assignable_axis) {
                    case 0:
                    joystick_x_variables = { true, channel, modulator };
                    break;
                    case 1:
                    joystick_y_variables = { true, channel, modulator };
                    break;
                }
                joystick.assignable = false;
                joystick.assignable_axis = -1;
                joystick.make_all_sensitive ();
                send_assignable_mode (false);
            }
            slider_assign_button.sensitive = true;
            knob_assign_button.sensitive = true;
            master_assign_button.sensitive = true;
        }

        public void monitor_lfo () {
            Timeout.add (10, () => {
                if (Ensembles.Core.CentralBus.get_lfo_type () > 0) {
                    if (!monitoring_lfo) {
                        return false;
                    }
                    float value = Ensembles.Core.CentralBus.get_lfo ();
                    Idle.add (() => {
                        if (!monitoring_lfo) {
                            return false;
                        }
                        value = value * 0.8f + 0.1f;
                        master_knob.set_value (value);
                        if (master_knob_assigns != null) {
                            if (master_knob_assigns[0] && slider_0_variables.assigned) {
                                slider_0.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_0_variables.channel, slider_0_variables.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[1] && slider_1_variables.assigned) {
                                slider_1.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_1_variables.channel, slider_1_variables.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[2] && slider_2_variables.assigned) {
                                slider_2.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_2_variables.channel, slider_2_variables.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[3] && slider_3_variables.assigned) {
                                slider_3.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_3_variables.channel, slider_3_variables.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[4] && slider_4_variables.assigned) {
                                slider_4.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_4_variables.channel, slider_4_variables.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[5] && slider_5_variables.assigned) {
                                slider_5.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_5_variables.channel, slider_5_variables.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[6] && slider_6_variables.assigned) {
                                slider_6.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_6_variables.channel, slider_6_variables.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[7] && slider_7_variables.assigned) {
                                slider_7.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_7_variables.channel, slider_7_variables.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[8] && slider_8_variables.assigned) {
                                slider_8.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_8_variables.channel, slider_8_variables.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[9] && slider_9_variables.assigned) {
                                slider_9.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_9_variables.channel, slider_9_variables.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[10] && knob_a_variables.assigned) {
                                modulator_knob_a.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    knob_a_variables.channel, knob_a_variables.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[11] && knob_b_variables.assigned) {
                                modulator_knob_b.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    knob_b_variables.channel, knob_b_variables.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[12] && knob_c_variables.assigned) {
                                modulator_knob_c.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    knob_c_variables.channel, knob_c_variables.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[13] && knob_d_variables.assigned) {
                                modulator_knob_d.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    knob_d_variables.channel, knob_d_variables.modulator, (int)(value * 127)
                                );
                            }
                        }
                        return false;
                    });
                }
                return monitoring_lfo;
            });
        }
    }
}
