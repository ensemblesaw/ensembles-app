/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Widgets {
    public class BeatVisualization : Gtk.Box {
        Gtk.Fixed beat_counter_visual;
        private uint beat_count = 0;
        private uint8 tempo = 120;
        private uint8 beats_per_bar = 4;
        private uint8 beat_duration = 4;

        construct {
            build_ui ();
        }

        private void build_ui () {
            beat_counter_visual = new Gtk.Fixed () {
                width_request = 108,
                height_request = 32,
                valign = Gtk.Align.CENTER
            };

            beat_counter_visual.add_css_class ("beat-counter-0");
            append (beat_counter_visual);

            Application.event_bus.beat.connect ((measure, time_sig_n, time_sig_d) => {
                beats_per_bar = time_sig_n;
                beat_duration = time_sig_d;
                beat (measure);
            });

            Application.event_bus.beat_reset.connect (() => {
                beat_count = 0;
            });
        }

        private void beat (bool measure) {
            if (measure) {
                beat_count = 1;
            }

            if (beat_count < 5) {
                set_beat_graphic (beat_count);
                Timeout.add (120000 / (tempo * beat_duration), () => {
                    set_beat_graphic (0);
                    return false;
                });
            } else {
                beat_count = 1;
            }

            beat_count++;
        }

        private void set_beat_graphic (uint val) {
            Idle.add (() => {
                switch (val) {
                    case 0:
                    beat_counter_visual.add_css_class ("beat-counter-0");
                    beat_counter_visual.remove_css_class ("beat-counter-1");
                    beat_counter_visual.remove_css_class ("beat-counter-2");
                    beat_counter_visual.remove_css_class ("beat-counter-3");
                    beat_counter_visual.remove_css_class ("beat-counter-4");
                    break;
                    case 1:
                    beat_counter_visual.remove_css_class ("beat-counter-0");
                    beat_counter_visual.add_css_class ("beat-counter-1");
                    beat_counter_visual.remove_css_class ("beat-counter-2");
                    beat_counter_visual.remove_css_class ("beat-counter-3");
                    beat_counter_visual.remove_css_class ("beat-counter-4");
                    break;
                    case 2:
                    beat_counter_visual.remove_css_class ("beat-counter-0");
                    beat_counter_visual.remove_css_class ("beat-counter-1");
                    beat_counter_visual.add_css_class ("beat-counter-2");
                    beat_counter_visual.remove_css_class ("beat-counter-3");
                    beat_counter_visual.remove_css_class ("beat-counter-4");
                    break;
                    case 3:
                    beat_counter_visual.remove_css_class ("beat-counter-0");
                    beat_counter_visual.remove_css_class ("beat-counter-1");
                    beat_counter_visual.remove_css_class ("beat-counter-2");
                    beat_counter_visual.add_css_class ("beat-counter-3");
                    beat_counter_visual.remove_css_class ("beat-counter-4");
                    break;
                    case 4:
                    beat_counter_visual.remove_css_class ("beat-counter-0");
                    beat_counter_visual.remove_css_class ("beat-counter-1");
                    beat_counter_visual.remove_css_class ("beat-counter-2");
                    beat_counter_visual.remove_css_class ("beat-counter-3");
                    beat_counter_visual.add_css_class ("beat-counter-4");
                    break;
                }

                return false;
            });
        }
    }
}
