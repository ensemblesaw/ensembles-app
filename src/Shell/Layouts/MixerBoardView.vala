/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class MixerBoardView : Gtk.Grid {
        public const int UI_INDEX_MIXER_STYLE_1 = 25;
        public const int UI_INDEX_MIXER_STYLE_2 = 26;
        public const int UI_INDEX_MIXER_STYLE_3 = 27;
        public const int UI_INDEX_MIXER_STYLE_4 = 28;
        public const int UI_INDEX_MIXER_STYLE_5 = 29;
        public const int UI_INDEX_MIXER_STYLE_6 = 30;
        public const int UI_INDEX_MIXER_STYLE_7 = 31;
        public const int UI_INDEX_MIXER_STYLE_8 = 32;
        public const int UI_INDEX_MIXER_STYLE_9 = 33;
        public const int UI_INDEX_MIXER_STYLE_10 = 34;
        public const int UI_INDEX_MIXER_STYLE_11 = 35;
        public const int UI_INDEX_MIXER_STYLE_12 = 36;
        public const int UI_INDEX_MIXER_STYLE_13 = 37;
        public const int UI_INDEX_MIXER_STYLE_14 = 38;
        public const int UI_INDEX_MIXER_STYLE_15 = 39;
        public const int UI_INDEX_MIXER_STYLE_16 = 40;
        public const int UI_INDEX_MIXER_VOICE_L = 41;
        public const int UI_INDEX_MIXER_VOICE_R1 = 42;
        public const int UI_INDEX_MIXER_VOICE_R2 = 43;
        public const int UI_INDEX_MIXER_SAMPLING_PAD = 44;

        public const int UI_INDEX_MIXER_LOCK_1 = 45;
        public const int UI_INDEX_MIXER_LOCK_2 = 46;
        public const int UI_INDEX_MIXER_LOCK_3 = 47;
        public const int UI_INDEX_MIXER_LOCK_4 = 48;
        public const int UI_INDEX_MIXER_LOCK_5 = 49;
        public const int UI_INDEX_MIXER_LOCK_6 = 50;
        public const int UI_INDEX_MIXER_LOCK_7 = 51;
        public const int UI_INDEX_MIXER_LOCK_8 = 52;
        public const int UI_INDEX_MIXER_LOCK_9 = 53;
        public const int UI_INDEX_MIXER_LOCK_10 = 54;
        public const int UI_INDEX_MIXER_LOCK_11 = 55;
        public const int UI_INDEX_MIXER_LOCK_12 = 56;
        public const int UI_INDEX_MIXER_LOCK_13 = 57;
        public const int UI_INDEX_MIXER_LOCK_14 = 58;
        public const int UI_INDEX_MIXER_LOCK_15 = 59;
        public const int UI_INDEX_MIXER_LOCK_16 = 60;
        public const int UI_INDEX_MIXER_LOCK_L = 61;
        public const int UI_INDEX_MIXER_LOCK_R1 = 62;
        public const int UI_INDEX_MIXER_LOCK_R2 = 63;
        public const int UI_INDEX_MIXER_LOCK_SP = 64;

        private Gtk.Scale[] style_gain_sliders;

        private Gtk.Scale voice_l_gain_slider;
        private Gtk.Scale voice_r1_gain_slider;
        private Gtk.Scale voice_r2_gain_slider;
        private Gtk.Scale sampler_pad_gain_slider;

        private Gtk.Button[] lock_buttons;

        private bool watch;

        public signal void set_sampler_gain (double gain);

        // A panel where you can modify the gain modulators of various channels
        public MixerBoardView () {
            vexpand = true;
            column_homogeneous = true;
            margin_start = 8;
            margin_end = 8;
            int i = 0;
            style_gain_sliders = new Gtk.Scale [16];

            get_style_context ().add_class ("mixer-sliders");

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

            voice_l_gain_slider.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (voice_l_gain_slider, UI_INDEX_MIXER_VOICE_L);
                    return true;
                }

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

            voice_r1_gain_slider.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (voice_r1_gain_slider, UI_INDEX_MIXER_VOICE_R1);
                    return true;
                }

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

            voice_r2_gain_slider.button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (voice_r2_gain_slider, UI_INDEX_MIXER_VOICE_R2);
                    return true;
                }

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
                lock_buttons[0].set_image (
                    new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON)
                );
            });
            lock_buttons[1].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (1);
                lock_buttons[1].sensitive = false;
                lock_buttons[1].set_image (
                    new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON)
                );
            });
            lock_buttons[2].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (2);
                lock_buttons[2].sensitive = false;
                lock_buttons[2].set_image (
                    new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON)
                );
            });
            lock_buttons[3].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (3);
                lock_buttons[3].sensitive = false;
                lock_buttons[3].set_image (
                    new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON)
                );
            });
            lock_buttons[4].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (4);
                lock_buttons[4].sensitive = false;
                lock_buttons[4].set_image (
                    new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON)
                );
            });
            lock_buttons[5].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (5);
                lock_buttons[5].sensitive = false;
                lock_buttons[5].set_image (
                    new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON)
                );
            });
            lock_buttons[6].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (6);
                lock_buttons[6].sensitive = false;
                lock_buttons[6].set_image (
                    new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON)
                );
            });
            lock_buttons[7].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (7);
                lock_buttons[7].sensitive = false;
                lock_buttons[7].set_image (
                    new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON)
                );
            });
            lock_buttons[8].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (8);
                lock_buttons[8].sensitive = false;
                lock_buttons[8].set_image (
                    new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON)
                );
            });
            lock_buttons[9].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (9);
                lock_buttons[9].sensitive = false;
                lock_buttons[9].set_image (
                    new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON)
                );
            });
            lock_buttons[10].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (10);
                lock_buttons[10].sensitive = false;
                lock_buttons[10].set_image (
                    new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON)
                );
            });
            lock_buttons[11].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (11);
                lock_buttons[11].sensitive = false;
                lock_buttons[11].set_image (
                    new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON)
                );
            });
            lock_buttons[12].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (12);
                lock_buttons[12].sensitive = false;
                lock_buttons[12].set_image (
                    new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON)
                );
            });
            lock_buttons[13].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (13);
                lock_buttons[13].sensitive = false;
                lock_buttons[13].set_image (
                    new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON)
                );
            });
            lock_buttons[14].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (14);
                lock_buttons[14].sensitive = false;
                lock_buttons[14].set_image (
                    new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON)
                );
            });
            lock_buttons[15].clicked.connect (() => {
                Ensembles.Core.Synthesizer.lock_gain (15);
                lock_buttons[15].sensitive = false;
                lock_buttons[15].set_image (
                    new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON)
                );
            });
        }

        private bool handle_change_gain (int index, double value) {
            if (value >= 0) {
                change_gain (index, (int)(value * 127));
                lock_buttons[index].set_image (
                    new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON)
                );
                lock_buttons[index].sensitive = true;
            }
            return false;
        }

        private void connect_style_sliders () {
            style_gain_sliders[0].change_value.connect ((scroll, value) => {
                return handle_change_gain (0, value);
            });

            style_gain_sliders[0].button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (style_gain_sliders[0], UI_INDEX_MIXER_STYLE_1);
                    return true;
                }

                return false;
            });

            style_gain_sliders[1].change_value.connect ((scroll, value) => {
                return handle_change_gain (1, value);
            });

            style_gain_sliders[1].button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (style_gain_sliders[1], UI_INDEX_MIXER_STYLE_2);
                    return true;
                }

                return false;
            });

            style_gain_sliders[2].change_value.connect ((scroll, value) => {
                return handle_change_gain (2, value);
            });

            style_gain_sliders[2].button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (style_gain_sliders[2], UI_INDEX_MIXER_STYLE_3);
                    return true;
                }

                return false;
            });

            style_gain_sliders[3].change_value.connect ((scroll, value) => {
                return handle_change_gain (3, value);
            });

            style_gain_sliders[3].button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (style_gain_sliders[3], UI_INDEX_MIXER_STYLE_4);
                    return true;
                }

                return false;
            });

            style_gain_sliders[4].change_value.connect ((scroll, value) => {
                return handle_change_gain (4, value);
            });

            style_gain_sliders[4].button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (style_gain_sliders[4], UI_INDEX_MIXER_STYLE_5);
                    return true;
                }

                return false;
            });

            style_gain_sliders[5].change_value.connect ((scroll, value) => {
                return handle_change_gain (5, value);
            });

            style_gain_sliders[5].button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (style_gain_sliders[5], UI_INDEX_MIXER_STYLE_6);
                    return true;
                }

                return false;
            });

            style_gain_sliders[6].change_value.connect ((scroll, value) => {
                return handle_change_gain (6, value);
            });

            style_gain_sliders[6].button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (style_gain_sliders[6], UI_INDEX_MIXER_STYLE_7);
                    return true;
                }

                return false;
            });

            style_gain_sliders[7].change_value.connect ((scroll, value) => {
                return handle_change_gain (7, value);
            });

            style_gain_sliders[7].button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (style_gain_sliders[7], UI_INDEX_MIXER_STYLE_8);
                    return true;
                }

                return false;
            });

            style_gain_sliders[8].change_value.connect ((scroll, value) => {
                return handle_change_gain (8, value);
            });

            style_gain_sliders[8].button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (style_gain_sliders[8], UI_INDEX_MIXER_STYLE_9);
                    return true;
                }

                return false;
            });

            style_gain_sliders[9].change_value.connect ((scroll, value) => {
                return handle_change_gain (9, value);
            });

            style_gain_sliders[9].button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (style_gain_sliders[9], UI_INDEX_MIXER_STYLE_10);
                    return true;
                }

                return false;
            });

            style_gain_sliders[10].change_value.connect ((scroll, value) => {
                return handle_change_gain (10, value);
            });

            style_gain_sliders[10].button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (style_gain_sliders[10], UI_INDEX_MIXER_STYLE_11);
                    return true;
                }

                return false;
            });

            style_gain_sliders[11].change_value.connect ((scroll, value) => {
                return handle_change_gain (11, value);
            });

            style_gain_sliders[11].button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (style_gain_sliders[11], UI_INDEX_MIXER_STYLE_12);
                    return true;
                }

                return false;
            });

            style_gain_sliders[12].change_value.connect ((scroll, value) => {
                return handle_change_gain (12, value);
            });

            style_gain_sliders[12].button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (style_gain_sliders[12], UI_INDEX_MIXER_STYLE_13);
                    return true;
                }

                return false;
            });

            style_gain_sliders[13].change_value.connect ((scroll, value) => {
                return handle_change_gain (13, value);
            });

            style_gain_sliders[13].button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (style_gain_sliders[13], UI_INDEX_MIXER_STYLE_14);
                    return true;
                }

                return false;
            });

            style_gain_sliders[14].change_value.connect ((scroll, value) => {
                return handle_change_gain (14, value);
            });

            style_gain_sliders[14].button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (style_gain_sliders[14], UI_INDEX_MIXER_STYLE_15);
                    return true;
                }

                return false;
            });

            style_gain_sliders[15].change_value.connect ((scroll, value) => {
                return handle_change_gain (15, value);
            });

            style_gain_sliders[15].button_press_event.connect ((button_event) => {
                if (button_event.button == 3) {
                    Application.main_window.show_context_menu (style_gain_sliders[15], UI_INDEX_MIXER_STYLE_16);
                    return true;
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

        public void handle_midi_controller_event (int index, int value) {
            if (index < UI_INDEX_MIXER_VOICE_L) {
                style_gain_sliders[index - UI_INDEX_MIXER_STYLE_1].change_value(Gtk.ScrollType.JUMP, (double)((value < 0 ? 0 : value) / 127.0));
            }
        }
    }
}
