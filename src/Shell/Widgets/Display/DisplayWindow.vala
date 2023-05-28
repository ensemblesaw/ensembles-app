/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Shell.Widgets.Display;

namespace Ensembles.Shell.Layouts.Display {
    /**
     * Display Window is a window that may contain other widgets
     * that are to be displayed inside the info display of Ensembles
     */
    public class DisplayWindow : WheelScrollableWidget {
        private Gtk.Button close_button;
        private Gtk.Box header_bar;
        private Gtk.Box window_title_box;
        private Gtk.Label title_label;
        private Gtk.Label subtitle_label;
        private Gtk.Box header_container;

        private string _title;
        public string title {
            get {
                return _title;
            }
            set {
                _title = value;
                if (title_label != null) {
                    title_label.set_text (value);
                }
            }
        }

        private string _subtitle;
        public string subtitle {
            get {
                return _subtitle;
            }
            set {
                _subtitle = value;
                if (subtitle_label != null) {
                    subtitle_label.set_text (value);
                }
            }
        }

        private Gtk.Widget _header_addon_widget;
        public Gtk.Widget header_addon_widget {
            get {
                return _header_addon_widget;
            }
            set {
                _header_addon_widget = value;
            }
        }

        public signal void close ();

        construct {
            build_ui ();
        }

        public DisplayWindow (string title = "", string subtitle = "") {
            Object (
                title: title,
                subtitle: subtitle
            );
        }

        private void build_ui () {
            add_css_class ("display-window-background");
            orientation = Gtk.Orientation.VERTICAL;

            header_bar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                spacing = 16
            };
            append (header_bar);
            header_bar.add_css_class ("display-window-header-bar");

            close_button = new Gtk.Button.from_icon_name ("application-exit-symbolic") {
                halign = Gtk.Align.START,
                valign = Gtk.Align.CENTER,
                width_request = 36,
                height_request = 36
            };
            close_button.add_css_class ("accented");
            close_button.clicked.connect (() => { close (); });
            header_bar.append (close_button);

            window_title_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                halign = Gtk.Align.START,
                valign = Gtk.Align.CENTER
            };

            title_label = new Gtk.Label (title) {
                xalign = 0
            };
            title_label.add_css_class ("title");
            window_title_box.append (title_label);

            subtitle_label = new Gtk.Label (subtitle) {
                xalign = 0
            };
            subtitle_label.add_css_class ("subtitle");
            window_title_box.append (subtitle_label);

            if (Application.kiosk_mode) {
                header_bar.append (window_title_box);
            } else {
                var window_handle = new Gtk.WindowHandle () {
                    hexpand = true
                };
                header_bar.append (window_handle);
                window_handle.set_child (window_title_box);
            }

            header_container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            header_bar.append (header_container);
        }

        public void set_child (Gtk.Widget widget) {
            append (widget);
        }

        public void add_to_header (Gtk.Widget widget) {
            header_container.append (widget);
        }
    }
}
