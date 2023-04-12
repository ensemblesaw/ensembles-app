/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Widgets {
    public class Key : Gtk.Box {
        public uint8 index { get; protected set; }
        public bool is_black { get; protected set; }
        public Gtk.EventControllerMotion motion_controller;

        private bool _hovering;
        public bool hovering {
            get {
                return _hovering;
            }
            set {
                _hovering = value;
                if (value) {
                    add_css_class ("hovering");
                } else {
                    remove_css_class ("hovering");
                }
            }
        }

        private bool _pressed;
        public bool pressed {
            get {
                return _pressed;
            }
            set {
                _pressed = value;
                if (value) {
                    add_css_class ("pressed");
                } else {
                    remove_css_class ("pressed");
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
            motion_controller.enter.connect (() => {
                hovering = true;
            });
            motion_controller.leave.connect (() => {
                hovering = false;
            });
            add_controller (motion_controller);
        }

        public bool inside (Octave parent, double x, double y) {
            double _x, _y;
            parent.translate_coordinates (this, x, y, out _x, out _y);
            return contains (_x, _y);
        }
    }
}
