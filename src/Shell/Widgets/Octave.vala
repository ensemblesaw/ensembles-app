/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Widgets {
    public class Octave : Gtk.Widget, Gtk.Accessible {
        public uint8 index { get; protected set; }
        public unowned Keyboard keyboard { get; protected set; }
        private const uint8[] BLACK_KEYS = { 1, 3, 6, 8, 10 };
        private const uint8[] WHITE_KEYS = { 0, 2, 4, 5, 7, 9, 11 };
        private const double[] BLACK_KEY_OFFSETS = { 0.932, 2.758, 5.56, 7.38, 9.24 };

        Gtk.Box white_key_box;
        private Key[] keys = new Key[12];

        public signal void key_pressed (uint8 index);
        public signal void key_released (uint8 index);

        public Octave (Keyboard keyboard, uint8 index) {
            Object (
                index: index,
                name: "octave",
                accessible_role: Gtk.AccessibleRole.TABLE,
                keyboard: keyboard,
                accessible_role: Gtk.AccessibleRole.TABLE,
                layout_manager: new Gtk.BinLayout (),
                width_request: 200,
                height_request: 100,
                hexpand: true,
                vexpand: true
            );

            build_ui ();
        }

        construct {
            build_events ();
        }

        private void build_ui () {
            white_key_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true,
                vexpand = true,
                homogeneous = true
            };
            white_key_box.set_parent (this);

            keys = new Key[12];
            // Arrange all the white keys
            for (uint8 i = 0; i < 7; i++) {
                var key = new Key (WHITE_KEYS[i], false);
                white_key_box.append (key);
                keys[WHITE_KEYS[i]] = (owned) key;
            }

            // Arrange all the black keys
            for (uint8 i = 0; i < 5; i++) {
                var key = new Key (BLACK_KEYS[i], true);
                key.set_parent (this);
                keys[BLACK_KEYS[i]] = (owned) key;
            }
        }

        public void draw_keys () {
            int w_max = get_allocated_width ();
            double offset = w_max * 0.09;
            int h_max = get_allocated_height ();
            int black_key_width = w_max / 10;
            int black_key_height = (int) (h_max / 1.5);

            for (uint8 i = 0; i < 5; i++) {
                int left, right, top, bottom;
                box_to_margins (
                    (int) (BLACK_KEY_OFFSETS[i] * offset),
                    0,
                    black_key_width,
                    black_key_height,
                    w_max,
                    h_max,
                    out left,
                    out right,
                    out top,
                    out bottom
                );
                keys[BLACK_KEYS[i]].margin_start = left;
                keys[BLACK_KEYS[i]].margin_end = right;
                keys[BLACK_KEYS[i]].margin_bottom = bottom;
            }
        }

        private void build_events () {

        }

        private void box_to_margins(int x, int y, int width, int height, int w_max, int h_max, out int left, out int right, out int top, out int bottom) {
            // Calculate margins based on the given box and parent box dimensions
            left = x;
            right = w_max - (x + width);
            top = y;
            bottom = h_max - (y + height);
        }
    }
}
