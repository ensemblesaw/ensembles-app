/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class MixerBoardView : Gtk.Grid {
        Gtk.Scale[] style_gain_sliders;

        Gtk.Scale voice_l_gain_slider;
        Gtk.Scale voice_r1_gain_slider;
        Gtk.Scale voice_r2_gain_slider;
        Gtk.Scale sampler_pad_gain_slider;

        Gtk.Button[] lock_buttons;

        bool watch;

        public signal void set_sampler_gain (double gain);

        // A panel where you can modify the gain modulators of various channels
        public MixerBoardView () {
            vexpand = true;
            column_homogeneous = true;
            margin_start = 8;
            margin_end = 8;
            int i = 0;
            style_gain_sliders = new Gtk.Scale [16];

            for (i = 0; i < 16; i++) {
                style_gain_sliders[i] = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1) {
                    inverted = true,
                    draw_value = false
                };
                attach (style_gain_sliders[i], i, 0, 1, 1);
            }
            style_gain_sliders[0].vexpand = true;
            connect_style_sliders ();

            voice_l_gain_slider = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1) {
                inverted = true,
                draw_value = false,
                height_request = 72
            };
            attach (voice_l_gain_slider, i++, 0, 1, 1);
            voice_l_gain_slider.change_value.connect ((scroll, value) => {
                change_gain (19, (int)(value * 127));
                return false;
            });


            voice_r1_gain_slider = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1) {
                inverted = true,
                draw_value = false
            };
            attach (voice_r1_gain_slider, i++, 0, 1, 1);
            voice_r1_gain_slider.change_value.connect ((scroll, value) => {
                change_gain (17, (int)(value * 127));
                return false;
            });


            voice_r2_gain_slider = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1) {
                inverted = true,
                draw_value = false
            };
            attach (voice_r2_gain_slider, i++, 0, 1, 1);
            voice_r2_gain_slider.change_value.connect ((scroll, value) => {
                change_gain (18, (int)(value * 127));
                return false;
            });


            sampler_pad_gain_slider = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 0, 1, 0.1) {
                inverted = true,
                draw_value = false
            };
            attach (sampler_pad_gain_slider, i++, 0, 1, 1);
            sampler_pad_gain_slider.set_value (0.9);
            sampler_pad_gain_slider.change_value.connect ((scroll, value) => {
                if (value >= 0 && value <= 1.0) {
                    set_sampler_gain (value);
                }
                return false;
            });

            for (i = 0; i < 16; i++) {
                attach (new Gtk.Label ((i + 1).to_string ()), i, 1, 1, 1);
            }

            attach (new Gtk.Label (" L"), i++, 1, 1, 1);
            attach (new Gtk.Label ("R1"), i++, 1, 1, 1);
            attach (new Gtk.Label ("R2"), i++, 1, 1, 1);
            attach (new Gtk.Label ("SP"), i++, 1, 1, 1);

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

        private void change_gain (int channel, int value) {
            Ensembles.Core.Synthesizer.set_modulator_value (channel, 7, value);
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
                    change_gain (0, (int)(value * 127));
                    lock_buttons[0].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[0].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[1].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (1, (int)(value * 127));
                    lock_buttons[1].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[1].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[2].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (2, (int)(value * 127));
                    lock_buttons[2].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[2].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[3].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (3, (int)(value * 127));
                    lock_buttons[3].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[3].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[4].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (4, (int)(value * 127));
                    lock_buttons[4].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[4].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[5].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (5, (int)(value * 127));
                    lock_buttons[5].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[5].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[6].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (6, (int)(value * 127));
                    lock_buttons[6].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[6].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[7].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (7, (int)(value * 127));
                    lock_buttons[7].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[7].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[8].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (8, (int)(value * 127));
                    lock_buttons[8].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[8].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[9].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (9, (int)(value * 127));
                    lock_buttons[9].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[9].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[10].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (10, (int)(value * 127));
                    lock_buttons[10].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[10].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[11].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (11, (int)(value * 127));
                    lock_buttons[11].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[11].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[12].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (12, (int)(value * 127));
                    lock_buttons[12].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[12].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[13].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (13, (int)(value * 127));
                    lock_buttons[13].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[13].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[14].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (14, (int)(value * 127));
                    lock_buttons[14].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[14].sensitive = true;
                }
                return false;
            });
            style_gain_sliders[15].change_value.connect ((scroll, value) => {
                if (value >= 0) {
                    change_gain (15, (int)(value * 127));
                    lock_buttons[15].set_image (new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON));
                    lock_buttons[15].sensitive = true;
                }
                return false;
            });
        }

        public void stop_watch () {
            watch = false;
        }

        public void set_gain_value (int channel, int value) {
            Idle.add (() => {
                if (watch) {
                    if (channel >= 16) {
                        switch (channel) {
                            case 17:
                            if (voice_r1_gain_slider != null && voice_r1_gain_slider.adjustment != null) {
                                voice_r1_gain_slider.set_value ((double)value / 127);
                            }
                            break;
                            case 18:
                            if (voice_r2_gain_slider != null && voice_r2_gain_slider.adjustment != null) {
                                voice_r2_gain_slider.set_value ((double)value / 127);
                            }
                            break;
                            case 19:
                            if (voice_l_gain_slider != null && voice_l_gain_slider.adjustment != null) {
                                voice_l_gain_slider.set_value ((double)value / 127);
                            }
                            break;
                        }
                    } else {
                        if (style_gain_sliders[channel] != null && style_gain_sliders[channel].adjustment != null) {
                            style_gain_sliders[channel].set_value ((double)value / 127);
                        }
                    }
                }
                return false;
            });
        }

        int synth_gain_watch () {
            while (watch) {
                Thread.usleep (100000);
                if (watch) {
                    for (int i = 0; i < 20; i++) {
                        if (i != 16) {
                        set_gain_value (i, Ensembles.Core.Synthesizer.get_modulator_value (i, 7));
                        }
                        Thread.usleep (100000);
                    }
                }
            }
            return 0;
        }
    }
}
