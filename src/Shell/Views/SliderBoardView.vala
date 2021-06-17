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
        }
    }
}