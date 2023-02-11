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

        struct UIControlMap {
            bool assigned;
            public int channel;
            public int modulator;
        }

        public const int UI_INDEX_SLIDER_0 = 65;
        public const int UI_INDEX_SLIDER_1 = 66;
        public const int UI_INDEX_SLIDER_2 = 67;
        public const int UI_INDEX_SLIDER_3 = 68;
        public const int UI_INDEX_SLIDER_4 = 69;
        public const int UI_INDEX_SLIDER_5 = 70;
        public const int UI_INDEX_SLIDER_6 = 71;
        public const int UI_INDEX_SLIDER_7 = 72;
        public const int UI_INDEX_SLIDER_8 = 73;
        public const int UI_INDEX_SLIDER_9 = 74;
        public const int UI_INDEX_KNOB_A = 75;
        public const int UI_INDEX_KNOB_B = 76;
        public const int UI_INDEX_KNOB_C = 77;
        public const int UI_INDEX_KNOB_D = 78;
        public const int UI_INDEX_JOY_X = 79;
        public const int UI_INDEX_JOY_Y = 80;
        public const int UI_INDEX_MASTER_KNOB = 81;

        UIControlMap slider_0_control_map;
        UIControlMap slider_1_control_map;
        UIControlMap slider_2_control_map;
        UIControlMap slider_3_control_map;
        UIControlMap slider_4_control_map;
        UIControlMap slider_5_control_map;
        UIControlMap slider_6_control_map;
        UIControlMap slider_7_control_map;
        UIControlMap slider_8_control_map;
        UIControlMap slider_9_control_map;

        UIControlMap knob_a_control_map;
        UIControlMap knob_b_control_map;
        UIControlMap knob_c_control_map;
        UIControlMap knob_d_control_map;

        UIControlMap joystick_x_control_map;
        UIControlMap joystick_y_control_map;

        bool[] master_knob_assigns;
        bool master_assign_mode;

        bool monitoring_lfo = false;

        public SliderBoardView (JoyStick joystick_instance) {
            joystick = joystick_instance;
            row_spacing = 4;
            margin_top = 4;
            margin_bottom = 4;
            margin_start = 4;
            margin_end = 4;
            width_request = 408;
            height_request = 236;


            modulator_knob_a = new Knob ();
            modulator_knob_b = new Knob ();
            modulator_knob_c = new Knob ();
            modulator_knob_d = new Knob ();

            master_knob = new MasterKnob ();


            knob_assign_button = new Gtk.Button.with_label (_("Knob Assign"));
            master_assign_button = new Gtk.Button.with_label (_("Master Knob Assign"));
            var knob_assign_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true
            };
            knob_assign_box.append (knob_assign_button);
            knob_assign_box.append (master_assign_button);

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

            show ();

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
                if (joystick_x_control_map.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (joystick_x_control_map.channel,
                                                                    joystick_x_control_map.modulator,
                                                                    (int)(value));
                }
            });

            joystick.drag_y.connect ((value) => {
                if (joystick_y_control_map.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (joystick_y_control_map.channel,
                                                                    joystick_y_control_map.modulator,
                                                                    (int)(value));
                }
            });

            slider_0.change_value.connect ((scroll, value) => {
                if (slider_0_control_map.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (slider_0_control_map.channel,
                                                                    slider_0_control_map.modulator,
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
            slider_0.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (slider_0, UI_INDEX_SLIDER_0);
                    return true;
                }

                return false;
            });
            slider_1.change_value.connect ((scroll, value) => {
                if (slider_1_control_map.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_1_control_map.channel,
                        slider_1_control_map.modulator,
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
            slider_1.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (slider_1, UI_INDEX_SLIDER_1);
                    return true;
                }

                return false;
            });
            slider_2.change_value.connect ((scroll, value) => {
                if (slider_2_control_map.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_2_control_map.channel,
                        slider_2_control_map.modulator,
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
            slider_2.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (slider_2, UI_INDEX_SLIDER_2);
                    return true;
                }

                return false;
            });
            slider_3.change_value.connect ((scroll, value) => {
                if (slider_3_control_map.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_3_control_map.channel,
                        slider_3_control_map.modulator,
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
            slider_3.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (slider_3, UI_INDEX_SLIDER_3);
                    return true;
                }

                return false;
            });
            slider_4.change_value.connect ((scroll, value) => {
                if (slider_4_control_map.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_4_control_map.channel, slider_4_control_map.modulator, (int)(value * 127)
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
            slider_4.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (slider_4, UI_INDEX_SLIDER_4);
                    return true;
                }

                return false;
            });
            slider_5.change_value.connect ((scroll, value) => {
                if (slider_5_control_map.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_5_control_map.channel, slider_5_control_map.modulator, (int)(value * 127)
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
            slider_5.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (slider_5, UI_INDEX_SLIDER_5);
                    return true;
                }

                return false;
            });
            slider_6.change_value.connect ((scroll, value) => {
                if (slider_6_control_map.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_6_control_map.channel, slider_6_control_map.modulator, (int)(value * 127)
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
            slider_6.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (slider_6, UI_INDEX_SLIDER_6);
                    return true;
                }

                return false;
            });
            slider_7.change_value.connect ((scroll, value) => {
                if (slider_7_control_map.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_7_control_map.channel, slider_7_control_map.modulator, (int)(value * 127)
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
            slider_7.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (slider_7, UI_INDEX_SLIDER_7);
                    return true;
                }

                return false;
            });
            slider_8.change_value.connect ((scroll, value) => {
                if (slider_8_control_map.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_8_control_map.channel, slider_8_control_map.modulator, (int)(value * 127)
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
            slider_8.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (slider_8, UI_INDEX_SLIDER_8);
                    return true;
                }

                return false;
            });
            slider_9.change_value.connect ((scroll, value) => {
                if (slider_9_control_map.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_9_control_map.channel, slider_9_control_map.modulator, (int)(value * 127)
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
            slider_9.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (slider_9, UI_INDEX_SLIDER_9);
                    return true;
                }

                return false;
            });
            modulator_knob_a.change_value.connect ((value) => {
                if (knob_a_control_map.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        knob_a_control_map.channel, knob_a_control_map.modulator, (int)(value * 127)
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
            modulator_knob_a.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (modulator_knob_a, UI_INDEX_KNOB_A);
                    return true;
                }

                return false;
            });
            modulator_knob_b.change_value.connect ((value) => {
                if (knob_b_control_map.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        knob_b_control_map.channel, knob_b_control_map.modulator, (int)(value * 127)
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
            modulator_knob_b.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (modulator_knob_b, UI_INDEX_KNOB_B);
                    return true;
                }

                return false;
            });
            modulator_knob_c.change_value.connect ((value) => {
                if (knob_c_control_map.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        knob_c_control_map.channel, knob_c_control_map.modulator, (int)(value * 127)
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
            modulator_knob_c.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (modulator_knob_c, UI_INDEX_KNOB_C);
                    return true;
                }

                return false;
            });
            modulator_knob_d.change_value.connect ((value) => {
                if (knob_d_control_map.assigned) {
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        knob_d_control_map.channel, knob_d_control_map.modulator, (int)(value * 127)
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
            modulator_knob_d.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (modulator_knob_d, UI_INDEX_KNOB_D);
                    return true;
                }

                return false;
            });

            master_knob.change_value.connect ((value) => {
                control_other_sliders_from_master_knob (value);
            });
            master_knob.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (master_knob, UI_INDEX_MASTER_KNOB);
                    return true;
                }

                return false;
            });

            load_settings ();
            monitor_lfo ();
        }

        void load_settings () {
            var maps = Application.settings.get_strv ("ui-control-maps");

            if (maps.length == 0) {
                return;
            }

            var token = maps[0].split (",");
            slider_0_control_map = { token[0] == "1", int.parse (token[1]), int.parse (token[2]) };
            token = maps[1].split (",");
            slider_1_control_map = { token[0] == "1", int.parse (token[1]), int.parse (token[2]) };
            token = maps[2].split (",");
            slider_2_control_map = { token[0] == "1", int.parse (token[1]), int.parse (token[2]) };
            token = maps[3].split (",");
            slider_3_control_map = { token[0] == "1", int.parse (token[1]), int.parse (token[2]) };
            token = maps[4].split (",");
            slider_4_control_map = { token[0] == "1", int.parse (token[1]), int.parse (token[2]) };
            token = maps[5].split (",");
            slider_5_control_map = { token[0] == "1", int.parse (token[1]), int.parse (token[2]) };
            token = maps[6].split (",");
            slider_6_control_map = { token[0] == "1", int.parse (token[1]), int.parse (token[2]) };
            token = maps[7].split (",");
            slider_7_control_map = { token[0] == "1", int.parse (token[1]), int.parse (token[2]) };
            token = maps[8].split (",");
            slider_8_control_map = { token[0] == "1", int.parse (token[1]), int.parse (token[2]) };
            token = maps[9].split (",");
            slider_9_control_map = { token[0] == "1", int.parse (token[1]), int.parse (token[2]) };

            token = maps[10].split (",");
            knob_a_control_map = { token[0] == "1", int.parse (token[1]), int.parse (token[2]) };
            token = maps[11].split (",");
            knob_b_control_map = { token[0] == "1", int.parse (token[1]), int.parse (token[2]) };
            token = maps[12].split (",");
            knob_c_control_map = { token[0] == "1", int.parse (token[1]), int.parse (token[2]) };
            token = maps[13].split (",");
            knob_d_control_map = { token[0] == "1", int.parse (token[1]), int.parse (token[2]) };

            token = maps[14].split (",");
            joystick_x_control_map = { token[0] == "1", int.parse (token[1]), int.parse (token[2]) };
            token = maps[15].split (",");
            joystick_y_control_map = { token[0] == "1", int.parse (token[1]), int.parse (token[2]) };
        }

        void save_settings () {
            var tokens = new string[16];
            tokens[0] = (slider_0_control_map.assigned ? "1" : "0") + ","
                + slider_0_control_map.channel.to_string () + "," + slider_0_control_map.modulator.to_string ();
            tokens[1] = (slider_1_control_map.assigned ? "1" : "0") + ","
                + slider_1_control_map.channel.to_string () + "," + slider_1_control_map.modulator.to_string ();
            tokens[2] = (slider_2_control_map.assigned ? "1" : "0") + ","
                + slider_2_control_map.channel.to_string () + "," + slider_2_control_map.modulator.to_string ();
            tokens[3] = (slider_3_control_map.assigned ? "1" : "0") + ","
                + slider_3_control_map.channel.to_string () + "," + slider_3_control_map.modulator.to_string ();
            tokens[4] = (slider_4_control_map.assigned ? "1" : "0") + ","
                + slider_4_control_map.channel.to_string () + "," + slider_4_control_map.modulator.to_string ();
            tokens[5] = (slider_5_control_map.assigned ? "1" : "0") + ","
                + slider_5_control_map.channel.to_string () + "," + slider_5_control_map.modulator.to_string ();
            tokens[6] = (slider_6_control_map.assigned ? "1" : "0") + ","
                + slider_6_control_map.channel.to_string () + "," + slider_6_control_map.modulator.to_string ();
            tokens[7] = (slider_7_control_map.assigned ? "1" : "0") + ","
                + slider_7_control_map.channel.to_string () + "," + slider_7_control_map.modulator.to_string ();
            tokens[8] = (slider_8_control_map.assigned ? "1" : "0") + ","
                + slider_8_control_map.channel.to_string () + "," + slider_8_control_map.modulator.to_string ();
            tokens[9] = (slider_9_control_map.assigned ? "1" : "0") + ","
                + slider_9_control_map.channel.to_string () + "," + slider_9_control_map.modulator.to_string ();

            tokens[10] = (knob_a_control_map.assigned ? "1" : "0") + ","
                + knob_a_control_map.channel.to_string () + "," + knob_a_control_map.modulator.to_string ();
            tokens[11] = (knob_b_control_map.assigned ? "1" : "0") + ","
                + knob_b_control_map.channel.to_string () + "," + knob_b_control_map.modulator.to_string ();
            tokens[12] = (knob_c_control_map.assigned ? "1" : "0") + ","
                + knob_c_control_map.channel.to_string () + "," + knob_c_control_map.modulator.to_string ();
            tokens[13] = (knob_d_control_map.assigned ? "1" : "0") + ","
                + knob_d_control_map.channel.to_string () + "," + knob_d_control_map.modulator.to_string ();

            tokens[14] = (joystick_x_control_map.assigned ? "1" : "0") + ","
                + joystick_x_control_map.channel.to_string () + "," + joystick_x_control_map.modulator.to_string ();
            tokens[15] = (joystick_y_control_map.assigned ? "1" : "0") + ","
                + joystick_y_control_map.channel.to_string () + "," + joystick_y_control_map.modulator.to_string ();

            //var settings_string = string.joinv (";", tokens);
            Application.settings.set_strv ("ui-control-maps", tokens);
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
                    slider_0_control_map = { true, channel, modulator };
                    break;
                    case 1:
                    slider_1_control_map = { true, channel, modulator };
                    break;
                    case 2:
                    slider_2_control_map = { true, channel, modulator };
                    break;
                    case 3:
                    slider_3_control_map = { true, channel, modulator };
                    break;
                    case 4:
                    slider_4_control_map = { true, channel, modulator };
                    break;
                    case 5:
                    slider_5_control_map = { true, channel, modulator };
                    break;
                    case 6:
                    slider_6_control_map = { true, channel, modulator };
                    break;
                    case 7:
                    slider_7_control_map = { true, channel, modulator };
                    break;
                    case 8:
                    slider_8_control_map = { true, channel, modulator };
                    break;
                    case 9:
                    slider_9_control_map = { true, channel, modulator };
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
                    knob_a_control_map = { true, channel, modulator };
                    break;
                    case 1:
                    knob_b_control_map = { true, channel, modulator };
                    break;
                    case 2:
                    knob_c_control_map = { true, channel, modulator };
                    break;
                    case 3:
                    knob_d_control_map = { true, channel, modulator };
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
                    joystick_x_control_map = { true, channel, modulator };
                    break;
                    case 1:
                    joystick_y_control_map = { true, channel, modulator };
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

            save_settings ();
        }

        public void monitor_lfo () {
            monitoring_lfo = true;
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
                            if (master_knob_assigns[0] && slider_0_control_map.assigned) {
                                slider_0.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_0_control_map.channel, slider_0_control_map.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[1] && slider_1_control_map.assigned) {
                                slider_1.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_1_control_map.channel, slider_1_control_map.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[2] && slider_2_control_map.assigned) {
                                slider_2.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_2_control_map.channel, slider_2_control_map.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[3] && slider_3_control_map.assigned) {
                                slider_3.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_3_control_map.channel, slider_3_control_map.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[4] && slider_4_control_map.assigned) {
                                slider_4.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_4_control_map.channel, slider_4_control_map.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[5] && slider_5_control_map.assigned) {
                                slider_5.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_5_control_map.channel, slider_5_control_map.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[6] && slider_6_control_map.assigned) {
                                slider_6.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_6_control_map.channel, slider_6_control_map.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[7] && slider_7_control_map.assigned) {
                                slider_7.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_7_control_map.channel, slider_7_control_map.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[8] && slider_8_control_map.assigned) {
                                slider_8.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_8_control_map.channel, slider_8_control_map.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[9] && slider_9_control_map.assigned) {
                                slider_9.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    slider_9_control_map.channel, slider_9_control_map.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[10] && knob_a_control_map.assigned) {
                                modulator_knob_a.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    knob_a_control_map.channel, knob_a_control_map.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[11] && knob_b_control_map.assigned) {
                                modulator_knob_b.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    knob_b_control_map.channel, knob_b_control_map.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[12] && knob_c_control_map.assigned) {
                                modulator_knob_c.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    knob_c_control_map.channel, knob_c_control_map.modulator, (int)(value * 127)
                                );
                            }
                            if (master_knob_assigns[13] && knob_d_control_map.assigned) {
                                modulator_knob_d.set_value (value);
                                Ensembles.Core.Synthesizer.set_modulator_value (
                                    knob_d_control_map.channel, knob_d_control_map.modulator, (int)(value * 127)
                                );
                            }
                        }
                        return false;
                    });
                }
                return monitoring_lfo;
            });
        }

        void control_other_sliders_from_master_knob (double value) {
            bool assigned = false;
            if (master_knob_assigns != null) {
                if (master_knob_assigns[0] && slider_0_control_map.assigned) {
                    slider_0.set_value (value);
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_0_control_map.channel, slider_0_control_map.modulator, (int)(value * 127)
                    );
                }
                if (master_knob_assigns[1] && slider_1_control_map.assigned) {
                    slider_1.set_value (value);
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_1_control_map.channel, slider_1_control_map.modulator, (int)(value * 127)
                    );
                }
                if (master_knob_assigns[2] && slider_2_control_map.assigned) {
                    slider_2.set_value (value);
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_2_control_map.channel, slider_2_control_map.modulator, (int)(value * 127)
                    );
                }
                if (master_knob_assigns[3] && slider_3_control_map.assigned) {
                    slider_3.set_value (value);
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_3_control_map.channel, slider_3_control_map.modulator, (int)(value * 127)
                    );
                }
                if (master_knob_assigns[4] && slider_4_control_map.assigned) {
                    slider_4.set_value (value);
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_4_control_map.channel, slider_4_control_map.modulator, (int)(value * 127)
                    );
                }
                if (master_knob_assigns[5] && slider_5_control_map.assigned) {
                    slider_5.set_value (value);
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_5_control_map.channel, slider_5_control_map.modulator, (int)(value * 127)
                    );
                }
                if (master_knob_assigns[6] && slider_6_control_map.assigned) {
                    slider_6.set_value (value);
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_6_control_map.channel, slider_6_control_map.modulator, (int)(value * 127)
                    );
                }
                if (master_knob_assigns[7] && slider_7_control_map.assigned) {
                    slider_7.set_value (value);
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_7_control_map.channel, slider_7_control_map.modulator, (int)(value * 127)
                    );
                }
                if (master_knob_assigns[8] && slider_8_control_map.assigned) {
                    slider_8.set_value (value);
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_8_control_map.channel, slider_8_control_map.modulator, (int)(value * 127)
                    );
                }
                if (master_knob_assigns[9] && slider_9_control_map.assigned) {
                    slider_9.set_value (value);
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_9_control_map.channel, slider_9_control_map.modulator, (int)(value * 127)
                    );
                }
                if (master_knob_assigns[10] && knob_a_control_map.assigned) {
                    modulator_knob_a.set_value (value);
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        knob_a_control_map.channel, knob_a_control_map.modulator, (int)(value * 127)
                    );
                }
                if (master_knob_assigns[11] && knob_b_control_map.assigned) {
                    modulator_knob_b.set_value (value);
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        knob_b_control_map.channel, knob_b_control_map.modulator, (int)(value * 127)
                    );
                }
                if (master_knob_assigns[12] && knob_c_control_map.assigned) {
                    modulator_knob_c.set_value (value);
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        knob_c_control_map.channel, knob_c_control_map.modulator, (int)(value * 127)
                    );
                }
                if (master_knob_assigns[13] && knob_d_control_map.assigned) {
                    modulator_knob_d.set_value (value);
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        knob_d_control_map.channel, knob_d_control_map.modulator, (int)(value * 127)
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
        }

        public void handle_midi_controller_event (int index, int value) {
            switch (index) {
                case UI_INDEX_SLIDER_0:
                    slider_0.change_value (Gtk.ScrollType.JUMP, (double)((value < 0 ? 0 : value) / 127.0));
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_0_control_map.channel, slider_0_control_map.modulator, (int)(value)
                    );
                    break;
                case UI_INDEX_SLIDER_1:
                    slider_1.change_value (Gtk.ScrollType.JUMP, (double)((value < 0 ? 0 : value) / 127.0));
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_1_control_map.channel, slider_1_control_map.modulator, (int)(value)
                    );
                    break;
                case UI_INDEX_SLIDER_2:
                    slider_2.change_value (Gtk.ScrollType.JUMP, (double)((value < 0 ? 0 : value) / 127.0));
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_2_control_map.channel, slider_2_control_map.modulator, (int)(value)
                    );
                    break;
                case UI_INDEX_SLIDER_3:
                    slider_3.change_value (Gtk.ScrollType.JUMP, (double)((value < 0 ? 0 : value) / 127.0));
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_3_control_map.channel, slider_3_control_map.modulator, (int)(value)
                    );
                    break;
                case UI_INDEX_SLIDER_4:
                    slider_4.change_value (Gtk.ScrollType.JUMP, (double)((value < 0 ? 0 : value) / 127.0));
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_4_control_map.channel, slider_4_control_map.modulator, (int)(value)
                    );
                    break;
                case UI_INDEX_SLIDER_5:
                    slider_5.change_value (Gtk.ScrollType.JUMP, (double)((value < 0 ? 0 : value) / 127.0));
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_5_control_map.channel, slider_5_control_map.modulator, (int)(value)
                    );
                    break;
                case UI_INDEX_SLIDER_6:
                    slider_6.change_value (Gtk.ScrollType.JUMP, (double)((value < 0 ? 0 : value) / 127.0));
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_6_control_map.channel, slider_6_control_map.modulator, (int)(value)
                    );
                    break;
                case UI_INDEX_SLIDER_7:
                    slider_7.change_value (Gtk.ScrollType.JUMP, (double)((value < 0 ? 0 : value) / 127.0));
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_7_control_map.channel, slider_7_control_map.modulator, (int)(value)
                    );
                    break;
                case UI_INDEX_SLIDER_8:
                    slider_8.change_value (Gtk.ScrollType.JUMP, (double)((value < 0 ? 0 : value) / 127.0));
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_8_control_map.channel, slider_8_control_map.modulator, (int)(value)
                    );
                    break;
                case UI_INDEX_SLIDER_9:
                    slider_9.change_value (Gtk.ScrollType.JUMP, (double)((value < 0 ? 0 : value) / 127.0));
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        slider_9_control_map.channel, slider_9_control_map.modulator, (int)(value)
                    );
                    break;
                case UI_INDEX_KNOB_A:
                    modulator_knob_a.set_value ((double)((value < 0 ? 0 : value) / 127.0));
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        knob_a_control_map.channel, knob_a_control_map.modulator, (int)(value)
                    );
                    break;
                case UI_INDEX_KNOB_B:
                    modulator_knob_b.set_value ((double)((value < 0 ? 0 : value) / 127.0));
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        knob_b_control_map.channel, knob_b_control_map.modulator, (int)(value)
                    );
                    break;
                case UI_INDEX_KNOB_C:
                    modulator_knob_c.set_value ((double)((value < 0 ? 0 : value) / 127.0));
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        knob_c_control_map.channel, knob_c_control_map.modulator, (int)(value)
                    );
                    break;
                case UI_INDEX_KNOB_D:
                    modulator_knob_d.set_value ((double)((value < 0 ? 0 : value) / 127.0));
                    Ensembles.Core.Synthesizer.set_modulator_value (
                        knob_d_control_map.channel, knob_d_control_map.modulator, (int)(value)
                    );
                    break;
                case UI_INDEX_MASTER_KNOB:
                    master_knob.set_value ((double)((value < 0 ? 0 : value) / 127.0));
                    control_other_sliders_from_master_knob ((double)((value < 0 ? 0 : value) / 127.0));
                    break;
            }
        }
    }
}
