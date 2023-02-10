/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright © 2019 Alain M. (https://github.com/alainm23/planner)<alainmh23@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Dialogs.Preferences {
    public class Item : Gtk.Box {
        private Gtk.GestureClick gesture_click;
        public Gtk.Image icon_image;
        private Gtk.Label title_label;

        public string _title;
        public string title {
            get {
                return _title;
            }

            set {
                _title = value;
                title_label.label = _title;
            }
        }

        public string _icon;
        public string icon {
            get {
                return _icon;
            }

            set {
                _icon = value;
                icon_image.gicon = new ThemedIcon (_icon);
            }
        }

        public bool last { get; construct; }

        public signal void activated ();

        public Item (string icon, string title, bool last=false) {
            Object (
                icon: icon,
                title: title,
                last: last,
                orientation: Gtk.Orientation.HORIZONTAL,
                spacing: 0
            );
        }

        construct {
            gesture_click = new Gtk.GestureClick ();
            icon_image = new Gtk.Image ();
            icon_image.pixel_size = 18;

            title_label = new Gtk.Label (null);
            title_label.get_style_context ().add_class ("h3");
            title_label.ellipsize = Pango.EllipsizeMode.END;
            title_label.halign = Gtk.Align.START;
            title_label.valign = Gtk.Align.CENTER;

            var button_icon = new Gtk.Image ();
            button_icon.gicon = new ThemedIcon ("pan-end-symbolic");
            button_icon.valign = Gtk.Align.CENTER;
            button_icon.pixel_size = 16;

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
                hexpand = true,
                margin_start = 6,
                margin_end = 12,
                margin_top = 6,
                margin_bottom = 6
            };
            box.append (icon_image);
            box.append (title_label);
            box.append (button_icon);

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            separator.margin_start = 32;
            separator.margin_bottom = 3;

            if (last) {
                separator.visible = false;
            }

            append (box);
            append (separator);

            gesture_click.pressed.connect (() => {
                activated ();
            });
        }
    }
}
