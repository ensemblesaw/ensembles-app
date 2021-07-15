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
    public class MixerBoardView : Gtk.Grid {
        Gtk.Scale[] style_gain_sliders;

        Gtk.Scale voice_l_gain_slider;
        Gtk.Scale voice_r1_gain_slider;
        Gtk.Scale voice_r2_gain_slider;
        Gtk.Scale style_chord_gain_slider;

        Gtk.Button[] lock_buttons;

        bool watch;

        public MixerBoardView () {
            halign = Gtk.Align.CENTER;
            vexpand = true;
            int i = 0;
            style_gain_sliders = new Gtk.Scale [16];

            for (i = 0; i < 16; i++) {
                style_gain_sliders[i] = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);
                style_gain_sliders[i].inverted = true;
                style_gain_sliders[i].draw_value = false;
                attach (style_gain_sliders[i], i, 0, 1, 1);
            }
            style_gain_sliders[0].vexpand = true;
            connect_style_sliders ();

            voice_l_gain_slider = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);
            voice_l_gain_slider.inverted = true;
            voice_l_gain_slider.draw_value = false;
            voice_l_gain_slider.margin_start = 4;
            voice_l_gain_slider.height_request = 72;
            attach (voice_l_gain_slider, i++, 0, 1, 1);
            voice_l_gain_slider.change_value.connect ((scroll, value) => {
                change_gain (0, 2, (int)(value * 127));
                return false;
            });


            voice_r1_gain_slider = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);
            voice_r1_gain_slider.inverted = true;
            voice_r1_gain_slider.draw_value = false;
            attach (voice_r1_gain_slider, i++, 0, 1, 1);
            voice_r1_gain_slider.change_value.connect ((scroll, value) => {
                change_gain (0, 0, (int)(value * 127));
                return false;
            });


            voice_r2_gain_slider = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1);
            voice_r2_gain_slider.inverted = true;
            voice_r2_gain_slider.draw_value = false;
            attach (voice_r2_gain_slider, i++, 0, 1, 1);
            voice_r2_gain_slider.change_value.connect ((scroll, value) => {
                change_gain (0, 1, (int)(value * 127));
                return false;
            });


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

            lock_buttons = new Gtk.Button[16];
            for (i = 0; i < 16; i++) {
                lock_buttons[i] = new Gtk.Button.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON);
                lock_buttons[i].sensitive = false;
                attach (lock_buttons[i], i, 2, 1, 1);
            }
            connect_unlock_buttons ();

            this.show_all ();
            watch = true;
            new Thread<int> ("synth_gain_watch", synth_gain_watch);
        }

        private void change_gain (int synth_index, int channel, int value) {
            Ensembles.Core.Synthesizer.set_modulator_value (synth_index, channel, 7, value);
        }

        private void connect_unlock_buttons () {
            lock_buttons[0].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (0);
                lock_buttons[0].sensitive = false;
                lock_buttons[0].set_image (new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON));
            });
            lock_buttons[1].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (1);
                lock_buttons[1].sensitive = false;
                lock_buttons[1].set_image (new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON));
            });
            lock_buttons[2].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (2);
                lock_buttons[2].sensitive = false;
                lock_buttons[2].set_image (new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON));
            });
            lock_buttons[3].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (3);
                lock_buttons[3].sensitive = false;
                lock_buttons[3].set_image (new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON));
            });
            lock_buttons[4].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (4);
                lock_buttons[4].sensitive = false;
                lock_buttons[4].set_image (new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON));
            });
            lock_buttons[5].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (5);
                lock_buttons[5].sensitive = false;
                lock_buttons[5].set_image (new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON));
            });
            lock_buttons[6].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (6);
                lock_buttons[6].sensitive = false;
                lock_buttons[6].set_image (new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON));
            });
            lock_buttons[7].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (7);
                lock_buttons[7].sensitive = false;
                lock_buttons[7].set_image (new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON));
            });
            lock_buttons[8].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (8);
                lock_buttons[8].sensitive = false;
                lock_buttons[8].set_image (new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON));
            });
            lock_buttons[9].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (9);
                lock_buttons[9].sensitive = false;
                lock_buttons[9].set_image (new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON));
            });
            lock_buttons[10].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (10);
                lock_buttons[10].sensitive = false;
                lock_buttons[10].set_image (new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON));
            });
            lock_buttons[11].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (11);
                lock_buttons[11].sensitive = false;
                lock_buttons[11].set_image (new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON));
            });
            lock_buttons[12].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (12);
                lock_buttons[12].sensitive = false;
                lock_buttons[12].set_image (new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON));
            });
            lock_buttons[13].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (13);
                lock_buttons[13].sensitive = false;
                lock_buttons[13].set_image (new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON));
            });
            lock_buttons[14].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (14);
                lock_buttons[14].sensitive = false;
                lock_buttons[14].set_image (new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON));
            });
            lock_buttons[15].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (15);
                lock_buttons[15].sensitive = false;
                lock_buttons[15].set_image (new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON));
            });
        }

        private void connect_style_sliders () {
            style_gain_sliders[0].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (1, 0, (int)(value * 127));
                    lock_buttons[0].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[0].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[1].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (1, 1, (int)(value * 127));
                    lock_buttons[1].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[1].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[2].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (1, 2, (int)(value * 127));
                    lock_buttons[2].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[2].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[3].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (1, 3, (int)(value * 127));
                    lock_buttons[3].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[3].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[4].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (1, 4, (int)(value * 127));
                    lock_buttons[4].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[4].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[5].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (1, 5, (int)(value * 127));
                    lock_buttons[5].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[5].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[6].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (1, 6, (int)(value * 127));
                    lock_buttons[6].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[6].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[7].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (1, 7, (int)(value * 127));
                    lock_buttons[7].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[7].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[8].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (1, 8, (int)(value * 127));
                    lock_buttons[8].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[8].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[9].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (1, 9, (int)(value * 127));
                    lock_buttons[9].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[9].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[10].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (1, 10, (int)(value * 127));
                    lock_buttons[10].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[10].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[11].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (1, 11, (int)(value * 127));
                    lock_buttons[11].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[11].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[12].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (1, 12, (int)(value * 127));
                    lock_buttons[12].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[12].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[13].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (1, 13, (int)(value * 127));
                    lock_buttons[13].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[13].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[14].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (1, 14, (int)(value * 127));
                    lock_buttons[14].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[14].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[15].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (1, 15, (int)(value * 127));
                    lock_buttons[15].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[15].sensitive = true;
                }
                return false;
            });
        }

        ~MixerBoardView () {
            watch = false;
        }

        public void set_gain_value (int synth_index, int channel, int value) {
            Idle.add (() => {
                if (synth_index == 0) {
                    switch (channel) {
                        case 0:
                        voice_r1_gain_slider.set_value ((double)value / 127);
                        break;
                        case 1:
                        voice_r2_gain_slider.set_value ((double)value / 127);
                        break;
                        case 2:
                        voice_l_gain_slider.set_value ((double)value / 127);
                        break;
                    }
                } else {
                    style_gain_sliders[channel].set_value ((double)value / 127);
                }
                return false;
            });
        }

        int synth_gain_watch () {
            while (watch) {
                Thread.usleep (200000);
                for (int i = 0; i < 3; i++) {
                    set_gain_value (0, i, Ensembles.Core.Synthesizer.get_modulator_value (0, i, 7));
                    Thread.usleep (100000);
                }
                for (int i = 0; i < 16; i++) {
                    set_gain_value (1, i, Ensembles.Core.Synthesizer.get_modulator_value (1, i, 7));
                    Thread.usleep (100000);
                }
            }
            return 0;
        }
    }
}
