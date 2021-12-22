/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class TempoScreen : WheelScrollableWidget {
        Gtk.SpinButton tempo_spin_button;
        Gtk.Button tap_button;

        public signal void close_screen ();
        public signal void changed (int tempo);


        // Tempo Tapper data
        Queue<ulong> tempo_data;
        private Timer tempo_timer;
        private uint beat_count = 0;

        public TempoScreen () {
            min_value = 40;
            max_value = 200;
            row_spacing = 8;
            get_style_context ().add_class ("quick-mod");

            tempo_data = new Queue<ulong> ();

            var close_button = new Gtk.Button.from_icon_name ("window-close-symbolic", Gtk.IconSize.BUTTON);
            close_button.get_style_context ().add_class ("quick-mod-close-button");
            close_button.clicked.connect (() => {
                close_screen ();
                if (tempo_timer != null) {
                    tempo_timer.stop ();
                    tempo_timer = null;
                    beat_count = 0;
                }
            });
            attach (close_button, 0, 0, 1, 1);

            var header = new Gtk.Label (_("Tempo")) {
                xalign = 0,
                hexpand = true
            };
            header.get_style_context ().add_class ("quick-mod-header");
            attach (header, 1, 0, 1, 1);

            var tempo_grid = new Gtk.Grid () {
                column_homogeneous = true,
                row_spacing = 4,
                column_spacing = 4
            };
            tempo_grid.get_style_context ().add_class ("quick-mod-grid");

            var tempo_label = new Gtk.Label (_("Beats Per Minute"));
            tempo_spin_button = new Gtk.SpinButton.with_range (40, 200, 1);
            tempo_grid.attach (tempo_label, 0, 0, 1, 1);
            tempo_grid.attach (tempo_spin_button, 1, 0, 1, 1);

            tap_button = new Gtk.Button.with_label (_("Tap"));
            tap_button.get_style_context ().add_class ("quick-mod-button");
            tap_button.button_press_event.connect (find_tempo);
            tempo_grid.attach (tap_button, 0, 1, 2, 1);


            var tempo_icon = new Gtk.Image.from_resource ("/com/github/subhadeepjasu/ensembles/images/tempo_icon.svg"){
                vexpand = true
            };
            tempo_grid.attach (tempo_icon, 0, 2, 2, 1);


            attach (tempo_grid, 0, 1, 2, 1);

            show_all ();

            tempo_spin_button.changed.connect (tempo_changed);
            key_press_event.connect ((event) => {
                if (event.keyval == KeyboardConstants.KeyMap.SPACE_BAR) {
                    find_tempo ();
                }
                return false;
            });

            wheel_scrolled_absolute.connect ((value) => {
                Idle.add (() => {
                    tempo_spin_button.set_value (value);
                    return false;
                });
            });
        }

        public void set_tempo (int tempo) {
            tempo_spin_button.changed.disconnect (tempo_changed);
            tempo_spin_button.set_value ((double) tempo);
            scroll_wheel_location = tempo;
            tempo_spin_button.changed.connect (tempo_changed);
        }

        private void tempo_changed () {
            changed (tempo_spin_button.get_value_as_int ());
        }

        public void scroll_wheel_activate () {
            close_screen ();
        }

        private bool find_tempo () {
            if (tempo_timer == null) {
                tempo_timer = new Timer ();
            }
            if (tempo_timer.is_active ()) {
                tempo_timer.stop ();
            }
            if (tempo_data.get_length () > 10) {
                tempo_data.pop_tail ();
            }

            tempo_data.push_head ((ulong)(tempo_timer.elapsed () * 1000000));

            tempo_timer.start ();

            ulong average = 0;

            for (uint i = 0; i < tempo_data.length; i++) {
                average += tempo_data.peek_nth (i);
            }

            average /= tempo_data.length;
            if (average > 0) {
                var _tempo = 60000000 / average;
                if (_tempo > 39 && _tempo < 201 && beat_count > 3) {
                    tempo_spin_button.set_value ((double) _tempo);
                }
            }

            beat_count++;


            return false;
        }
    }
}
