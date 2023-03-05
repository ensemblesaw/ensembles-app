/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Models;

namespace Ensembles.Shell.Layouts {
    public class StyleControlPanel : Gtk.Box {
        private Gtk.Box intro_box;
        private Gtk.Box variation_box;
        private Gtk.Box ending_box;

        private Gtk.Button intro_1_button;
        private Gtk.Button intro_2_button;
        private Gtk.Button intro_3_button;
        private Gtk.Button break_button;
        private Gtk.Button variation_a_button;
        private Gtk.Button variation_b_button;
        private Gtk.Button variation_c_button;
        private Gtk.Button variation_d_button;
        private Gtk.Button ending_1_button;
        private Gtk.Button ending_2_button;
        private Gtk.Button ending_3_button;

        public StyleControlPanel () {
            Object (
                orientation: Gtk.Orientation.HORIZONTAL,
                spacing: 4,
                hexpand: true
            );
        }

        construct {
            build_ui ();
            build_events ();
        }

        private void build_ui () {
            intro_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true,
                homogeneous = true
            };
            intro_box.get_style_context ().add_class (Granite.STYLE_CLASS_LINKED);
            append (intro_box);

            variation_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true,
                homogeneous = true
            };
            variation_box.get_style_context ().add_class (Granite.STYLE_CLASS_LINKED);
            append (variation_box);

            break_button = new Gtk.Button.with_label (_("BREAK"));
            append (break_button);

            ending_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true,
                homogeneous = true
            };
            ending_box.get_style_context ().add_class (Granite.STYLE_CLASS_LINKED);
            append (ending_box);

            intro_1_button = new Gtk.Button.with_label (_("1"));
            intro_box.append (intro_1_button);
            intro_2_button = new Gtk.Button.with_label (_("2"));
            intro_box.append (intro_2_button);
            intro_3_button = new Gtk.Button.with_label (_("3"));
            intro_box.append (intro_3_button);

            variation_a_button = new Gtk.Button.with_label (_("A"));
            variation_box.append (variation_a_button);
            variation_b_button = new Gtk.Button.with_label (_("B"));
            variation_box.append (variation_b_button);
            variation_c_button = new Gtk.Button.with_label (_("C"));
            variation_box.append (variation_c_button);
            variation_d_button = new Gtk.Button.with_label (_("D"));
            variation_box.append (variation_d_button);

            ending_1_button = new Gtk.Button.with_label (_("1"));
            ending_box.append (ending_1_button);
            ending_2_button = new Gtk.Button.with_label (_("2"));
            ending_box.append (ending_2_button);
            ending_3_button = new Gtk.Button.with_label (_("3"));
            ending_box.append (ending_3_button);
        }

        private void build_events () {
            intro_1_button.clicked.connect (() => {
                Application.event_bus.style_set_part (StylePartType.INTRO_1);
            });

            intro_2_button.clicked.connect (() => {
                Application.event_bus.style_set_part (StylePartType.INTRO_2);
            });

            intro_3_button.clicked.connect (() => {
                Application.event_bus.style_set_part (StylePartType.INTRO_3);
            });

            variation_a_button.clicked.connect (() => {
                Application.event_bus.style_set_part (StylePartType.VARIATION_A);
            });

            variation_b_button.clicked.connect (() => {
                Application.event_bus.style_set_part (StylePartType.VARIATION_B);
            });

            variation_c_button.clicked.connect (() => {
                Application.event_bus.style_set_part (StylePartType.VARIATION_C);
            });

            variation_d_button.clicked.connect (() => {
                Application.event_bus.style_set_part (StylePartType.VARIATION_D);
            });

            ending_1_button.clicked.connect (() => {
                Application.event_bus.style_set_part (StylePartType.ENDING_1);
            });

            ending_2_button.clicked.connect (() => {
                Application.event_bus.style_set_part (StylePartType.ENDING_2);
            });

            ending_3_button.clicked.connect (() => {
                Application.event_bus.style_set_part (StylePartType.ENDING_3);
            });
        }
    }
}
