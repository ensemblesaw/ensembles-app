/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

 namespace Ensembles.Shell.Widgets.Display {
    /**
     * Widget that responds to the Ensembles Scroll Wheel widget
     */
    public abstract class WheelScrollableWidget : Gtk.Box {
        public int scroll_wheel_location;
        public int max_value = -1;
        public int min_value = -1;
        public signal void wheel_scrolled_absolute (int value);
        public signal void wheel_scrolled_relative (bool direction, int amount);

        public void scroll_wheel_scroll (bool direction, int amount) {
            if (max_value != -1 && min_value != -1) {
                if (direction) {
                    if (scroll_wheel_location + amount < max_value) {
                        scroll_wheel_location += amount;
                    } else if (scroll_wheel_location != max_value) {
                        scroll_wheel_location = max_value;
                    }
                } else {
                    if (scroll_wheel_location - amount > min_value) {
                        scroll_wheel_location -= amount;
                    } else if (scroll_wheel_location != min_value) {
                        scroll_wheel_location = min_value;
                    }
                }

                wheel_scrolled_absolute (scroll_wheel_location);
            } else {
                wheel_scrolled_relative (direction, amount);
            }
        }
    }
}
