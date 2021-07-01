namespace Ensembles.Shell { 
    public class SliderBoardView : Gtk.Grid {
        Knob modulator_knob_a;
        Knob modulator_knob_b;
        Knob modulator_knob_c;
        Knob modulator_knob_d;
        SuperKnob super_knob;
        Gtk.Button knob_assign_button;
        Gtk.Button super_assign_button;
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

        public signal void change_modulator (int id, double value);
        public signal void send_assignable_mode (bool assignable);

        bool assign_mode;
        int assignable_slider_index = -1;

        int[] slider_0_variables;
        int[] slider_1_variables;
        int[] slider_2_variables;
        int[] slider_3_variables;
        int[] slider_4_variables;
        int[] slider_5_variables;
        int[] slider_6_variables;
        int[] slider_7_variables;
        int[] slider_8_variables;
        int[] slider_9_variables;

        int[] knob_a_variables;
        int[] knob_b_variables;
        int[] knob_c_variables;
        int[] knob_d_variables;

        public SliderBoardView () {
            row_spacing = 4;
            halign = Gtk.Align.START;
            valign = Gtk.Align.START;
            margin = 4;
            width_request = 293;
            height_request = 236;


            modulator_knob_a = new Knob ();
            modulator_knob_b = new Knob ();
            modulator_knob_c = new Knob ();
            modulator_knob_d = new Knob ();

            super_knob = new SuperKnob ();


            knob_assign_button = new Gtk.Button.with_label ("Knob Assign");
            super_assign_button = new Gtk.Button.with_label ("Super Assign");
            var knob_assign_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            knob_assign_box.add(knob_assign_button);
            knob_assign_box.add(super_assign_button);
            knob_assign_box.set_layout (Gtk.ButtonBoxStyle.EXPAND);

            slider_assign_button = new Gtk.Button.with_label ("Slider Assign");

            slider_0 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);
            slider_0.height_request = 85;
            slider_0.inverted = true;
            slider_0.draw_value = false;
            slider_1 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);
            slider_1.height_request = 85;
            slider_1.inverted = true;
            slider_1.draw_value = false;
            slider_2 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);
            slider_2.height_request = 85;
            slider_2.inverted = true;
            slider_2.draw_value = false;
            slider_3 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);
            slider_3.height_request = 85;
            slider_3.inverted = true;
            slider_3.draw_value = false;
            slider_4 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);
            slider_4.height_request = 85;
            slider_4.inverted = true;
            slider_4.draw_value = false;
            slider_5 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);
            slider_5.height_request = 85;
            slider_5.inverted = true;
            slider_5.draw_value = false;
            slider_6 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);
            slider_6.height_request = 85;
            slider_6.inverted = true;
            slider_6.draw_value = false;
            slider_7 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);
            slider_7.height_request = 85;
            slider_7.inverted = true;
            slider_7.draw_value = false;
            slider_8 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);
            slider_8.height_request = 85;
            slider_8.inverted = true;
            slider_8.draw_value = false;
            slider_9 = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);
            slider_9.height_request = 85;
            slider_9.inverted = true;
            slider_9.draw_value = false;

            var slider_grid = new Gtk.Grid ();
            slider_grid.column_spacing = 14;
            slider_grid.margin_start = 8;

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

            for (int i = 0; i < 10; i++) {
                slider_grid.attach (new Gtk.Label ((i + 1).to_string ()), i, 1, 1, 1);
            }

            attach (knob_assign_box,  0, 0, 5, 1);
            attach (modulator_knob_a, 0, 1, 1, 1);
            attach (new Gtk.Label ("1"), 0, 2, 1, 1);
            attach (modulator_knob_b, 1, 1, 1, 1);
            attach (new Gtk.Label ("2"), 1, 2, 1, 1);
            attach (modulator_knob_c, 2, 1, 1, 1);
            attach (new Gtk.Label ("3"), 2, 2, 1, 1);
            attach (modulator_knob_d, 3, 1, 1, 1);
            attach (new Gtk.Label ("4"), 3, 2, 1, 1);
            attach (slider_assign_button, 0, 3, 4, 1);
            attach (super_knob, 4, 1, 1, 3);
            attach (slider_grid, 0, 4, 5, 1);

            
            show_all ();


            slider_assign_button.clicked.connect (() => {
                assign_mode = !assign_mode;
                send_assignable_mode (assign_mode);
                if (assign_mode) {
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
                }
            });

            slider_0.change_value.connect ((scroll, value) => {
                if  (slider_0_variables != null) {
                    Ensembles.Core.Synthesizer.set_modulator_value (slider_0_variables[0], slider_0_variables[1], slider_0_variables[2], (int)(value * 127));
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
                return false;
            });
            slider_1.change_value.connect ((scroll, value) => {
                if  (slider_1_variables != null) {
                    Ensembles.Core.Synthesizer.set_modulator_value (slider_1_variables[0], slider_1_variables[1], slider_1_variables[2], (int)(value * 127));
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
                return false;
            });
            slider_2.change_value.connect ((scroll, value) => {
                if  (slider_2_variables != null) {
                    Ensembles.Core.Synthesizer.set_modulator_value (slider_2_variables[0], slider_2_variables[1], slider_2_variables[2], (int)(value * 127));
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
                return false;
            });
            slider_3.change_value.connect ((scroll, value) => {
                if  (slider_3_variables != null) {
                    Ensembles.Core.Synthesizer.set_modulator_value (slider_3_variables[0], slider_3_variables[1], slider_3_variables[2], (int)(value * 127));
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
                return false;
            });
            slider_4.change_value.connect ((scroll, value) => {
                if  (slider_4_variables != null) {
                    Ensembles.Core.Synthesizer.set_modulator_value (slider_4_variables[0], slider_4_variables[1], slider_4_variables[2], (int)(value * 127));
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
                return false;
            });
            slider_5.change_value.connect ((scroll, value) => {
                if  (slider_5_variables != null) {
                    Ensembles.Core.Synthesizer.set_modulator_value (slider_5_variables[0], slider_5_variables[1], slider_5_variables[2], (int)(value * 127));
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
                return false;
            });
            slider_6.change_value.connect ((scroll, value) => {
                if  (slider_6_variables != null) {
                    Ensembles.Core.Synthesizer.set_modulator_value (slider_6_variables[0], slider_6_variables[1], slider_6_variables[2], (int)(value * 127));
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
                return false;
            });
            slider_7.change_value.connect ((scroll, value) => {
                if  (slider_7_variables != null) {
                    Ensembles.Core.Synthesizer.set_modulator_value (slider_7_variables[0], slider_7_variables[1], slider_7_variables[2], (int)(value * 127));
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
                return false;
            });
            slider_8.change_value.connect ((scroll, value) => {
                if  (slider_8_variables != null) {
                    Ensembles.Core.Synthesizer.set_modulator_value (slider_8_variables[0], slider_8_variables[1], slider_8_variables[2], (int)(value * 127));
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
                return false;
            });
            slider_9.change_value.connect ((scroll, value) => {
                if  (slider_9_variables != null) {
                    Ensembles.Core.Synthesizer.set_modulator_value (slider_9_variables[0], slider_9_variables[1], slider_9_variables[2], (int)(value * 127));
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
                return false;
            });
        }

        public void send_modulator (int synth_index, int channel, int modulator) {
            if (assign_mode) {
                switch (assignable_slider_index) {
                    case 0:
                    slider_0_variables = { synth_index, channel, modulator };
                    break;
                    case 1:
                    slider_1_variables = { synth_index, channel, modulator };
                    break;
                    case 2:
                    slider_2_variables = { synth_index, channel, modulator };
                    break;
                    case 3:
                    slider_3_variables = { synth_index, channel, modulator };
                    break;
                    case 4:
                    slider_4_variables = { synth_index, channel, modulator };
                    break;
                    case 5:
                    slider_5_variables = { synth_index, channel, modulator };
                    break;
                    case 6:
                    slider_6_variables = { synth_index, channel, modulator };
                    break;
                    case 7:
                    slider_7_variables = { synth_index, channel, modulator };
                    break;
                    case 8:
                    slider_8_variables = { synth_index, channel, modulator };
                    break;
                    case 9:
                    slider_9_variables = { synth_index, channel, modulator };
                    break;
                }
                assignable_slider_index = -1;
                assign_mode = false;
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
        }
    }
}