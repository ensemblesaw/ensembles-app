/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Widgets {
    public class Key : Gtk.Box {
        public uint8 index { get; protected set; }
        public bool is_black { get; protected set; }
        private Gtk.EventControllerMotion motion_controller;
        private Gtk.GestureClick click_gesture;

        private bool _activated;
        public bool activated {
            get {
                return _activated;
            }
            set {
                _activated = value;
                if (value) {
                    add_css_class ("activated");
                } else {
                    remove_css_class ("activated");
                }
            }
        }

        public Key (uint8 index, bool is_black) {
            Object (
                index: index,
                is_black: is_black
            );

            if (is_black) {
                add_css_class ("black");
            }
        }

        construct {
            build_ui ();
            build_event ();
        }

        private void build_ui () {
            add_css_class ("key");
        }

        private void build_event () {
            motion_controller = new Gtk.EventControllerMotion ();
            add_controller (motion_controller);

            click_gesture = new Gtk.GestureClick ();
            click_gesture.pressed.connect (() => {
                activated = true;
            });
            click_gesture.released.connect (() => {
                activated = false;
            });
            add_controller (click_gesture);
        }

        public bool inside (Octave parent, double x, double y) {
            double _x, _y;
            parent.translate_coordinates (this, x, y, out _x, out _y);
            return contains (_x, _y);
        }
    }
}
