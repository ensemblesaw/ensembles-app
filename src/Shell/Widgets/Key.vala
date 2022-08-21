/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class Key : Gtk.Button {
        bool _black_key;
        int _index;
        Gtk.Button split_button;

        public enum NoteType {
            NORMAL,
            CHORD,
            AUTOMATION
        }

        public Key (int index, bool black_key) {
            margin_top = 14;
            _black_key = black_key;
            _index = index;
            get_style_context ().add_class ("common-key");
            if (black_key) {
                get_style_context ().add_class ("black-key");
                hexpand = true;
                height_request = 84;
                vexpand = true;
            } else {
                get_style_context ().add_class ("white-key");
                height_request = 146;
                hexpand = true;
                vexpand = true;
            }

            split_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.BUTTON) {
                valign = Gtk.Align.START
            };
            this.add (split_button);
            update_split ();

            split_button.clicked.connect (() => {
                Ensembles.Core.CentralBus.set_split_key (_index);
            });
        }

        public void note_on (NoteType note_type) {
            string style_class = "-key-";
            if (_black_key) {
                style_class = "black" + style_class;
            } else {
                style_class = "white" + style_class;
            }

            switch (note_type) {
                case NoteType.NORMAL:
                    get_style_context ().add_class (style_class + "active");
                    break;
                case NoteType.AUTOMATION:
                    get_style_context ().add_class (style_class + "auto");
                    break;
                case NoteType.CHORD:
                    get_style_context ().add_class (style_class + "chord");
                    break;
            }
        }

        public void update_split () {
            get_style_context ().remove_class ("common-key-split");

            if (_index == Ensembles.Core.CentralBus.get_split_key ()) {
                get_style_context ().add_class ("common-key-split");
            }
        }
    }
}
