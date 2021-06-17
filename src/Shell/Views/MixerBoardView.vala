namespace Ensembles.Shell { 
    public class MixerBoardView : Gtk.Grid {
        Gtk.Scale[] style_gain_sliders;

        Gtk.Scale voice_l_gain_slider;
        Gtk.Scale voice_r1_gain_slider;
        Gtk.Scale voice_r2_gain_slider;
        Gtk.Scale style_chord_gain_slider;

        Gtk.Button[] mute_buttons;
        public MixerBoardView () {
            halign = Gtk.Align.CENTER;
            int i = 0;            
            style_gain_sliders = new Gtk.Scale [16];

            for (i = 0; i < 16; i++) {
                style_gain_sliders[i] = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);
                style_gain_sliders[i].inverted = true;
                style_gain_sliders[i].draw_value = false;
                attach (style_gain_sliders[i], i, 0, 1, 1);
            }

            voice_l_gain_slider =     new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);
            voice_l_gain_slider.inverted = true;
            voice_l_gain_slider.draw_value = false;
            voice_l_gain_slider.margin_start = 4;
            voice_l_gain_slider.height_request = 72;
            attach (voice_l_gain_slider, i++, 0, 1, 1);
            voice_r1_gain_slider =    new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);

            voice_r1_gain_slider.inverted = true;
            voice_r1_gain_slider.draw_value = false;
            attach (voice_r1_gain_slider, i++, 0, 1, 1);
            voice_r2_gain_slider =    new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);

            voice_r2_gain_slider.inverted = true;
            voice_r2_gain_slider.draw_value = false;
            attach (voice_r2_gain_slider, i++, 0, 1, 1);
            style_chord_gain_slider = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);
            
            style_chord_gain_slider.inverted = true;
            style_chord_gain_slider.draw_value = false;
            attach (style_chord_gain_slider, i++, 0, 1, 1);

            for (i = 0; i < 16; i++) {
                attach (new Gtk.Label ((i + 1).to_string ()), i, 1, 1, 1);
            }

            attach (new Gtk.Label (" L"), i++, 1, 1, 1);
            attach (new Gtk.Label ("R1"), i++, 1, 1, 1);
            attach (new Gtk.Label ("R2"), i++, 1, 1, 1);
            attach (new Gtk.Label ("C"), i++, 1, 1, 1);

            mute_buttons = new Gtk.Button[20];
            for (i = 0; i < 20; i++) {
                mute_buttons[i] = new Gtk.Button.from_icon_name ("audio-volume-high-symbolic", Gtk.IconSize.BUTTON);
                attach (mute_buttons[i], i, 2, 1, 1);
                if (i == 16) {
                    mute_buttons[i].margin_start = 4;
                }
            }

            this.show_all ();
        }
    }
}