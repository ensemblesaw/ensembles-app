/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Shell.Widgets.Display;

namespace Ensembles.Shell.Layouts.Display {
    public class DisplayWindow : WheelScrollableWidget {
        private Gtk.Button close_button;
        private Gtk.CenterBox header_bar;
        private Adw.WindowTitle window_title_box;
        private Gtk.Box header_container;

        private string _title;
        public string title {
            get {
                return _title;
            }
            set {
                _title = value;
                if (window_title_box != null) {
                    window_title_box.title = value;
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
                if (window_title_box != null) {
                    window_title_box.subtitle = value;
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
            get_style_context ().add_class ("display-window-background");
            orientation = Gtk.Orientation.VERTICAL;

            header_bar = new Gtk.CenterBox () {
                height_request = 48
            };
            append (header_bar);
            header_bar.get_style_context ().add_class ("display-window-header-bar");

            close_button = new Gtk.Button.from_icon_name ("application-exit-symbolic") {
                halign = Gtk.Align.START
            };
            close_button.clicked.connect (() => { close (); });
            header_bar.set_start_widget (close_button);

            window_title_box = new Adw.WindowTitle (title, subtitle);
            if (Application.kiosk_mode) {
                header_bar.set_center_widget (window_title_box);
            } else {
                var window_handle = new Gtk.WindowHandle () {
                    hexpand = true
                };
                header_bar.set_center_widget (window_handle);
                window_handle.set_child (window_title_box);
            }

            header_container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);
            header_bar.set_end_widget (header_container);
        }

        public void set_child (Gtk.Widget widget) {
            append (widget);
        }

        public void add_to_header (Gtk.Widget widget) {
            header_container.append (widget);
        }
    }
}
