/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class Key : Gtk.Button {
        bool _black_key;
        int _index;
        Gtk.Button split_button;

        public Key (int index, bool black_key) {
            margin_top = 23;
            _black_key = black_key;
            _index = index;
            get_style_context ().add_class ("common-key");
            split_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.BUTTON);
            this.add (split_button);
            update_split ();

            split_button.clicked.connect (() => {
                Ensembles.Core.CentralBus.set_split_key (_index);
            });
        }

        public void note_on (bool auto) {
            if (_black_key) {
                if ((_index <= Ensembles.Core.CentralBus.get_split_key ()) &&
                   (Ensembles.Core.CentralBus.get_accomp_on () || Ensembles.Core.CentralBus.get_split_on ())) {
                    get_style_context ().add_class ("black-key-split-active");
                } else if (auto) {
                    get_style_context ().add_class ("black-key-active-auto");
                } else {
                    get_style_context ().add_class ("black-key-active");
                }
            } else {
                if ((_index <= Ensembles.Core.CentralBus.get_split_key ()) &&
                   (Ensembles.Core.CentralBus.get_accomp_on () || Ensembles.Core.CentralBus.get_split_on ())) {
                    get_style_context ().add_class ("white-key-split-active");
                } else if (auto) {
                    get_style_context ().add_class ("white-key-active-auto");
                } else {
                    get_style_context ().add_class ("white-key-active");
                }
            }
        }

        public void note_off (bool auto) {
            if (_black_key) {
                get_style_context ().remove_class ("black-key-active");
                get_style_context ().remove_class ("black-key-split-active");
                if (auto) {
                    get_style_context ().remove_class ("black-key-active-auto");
                }
            } else {
                get_style_context ().remove_class ("white-key-active");
                get_style_context ().remove_class ("white-key-split-active");
                if (auto) {
                    get_style_context ().remove_class ("white-key-active-auto");
                }
            }
        }

        public void update_split () {
            get_style_context ().remove_class ("common-key-split");
            get_style_context ().remove_class ("black-key-split");
            get_style_context ().remove_class ("white-key-split");
            if (_black_key) {
                hexpand = true;
                height_request = 84;
                vexpand = true;
                get_style_context ().add_class ("black-key-normal");
                if ((_index <= Ensembles.Core.CentralBus.get_split_key ()) &&
                   (Ensembles.Core.CentralBus.get_accomp_on () || Ensembles.Core.CentralBus.get_split_on ()))
                    get_style_context ().add_class ("black-key-split");
            } else {
                height_request = 146;
                hexpand = true;
                vexpand = true;
                get_style_context ().add_class ("white-key-normal");
                if ((_index <= Ensembles.Core.CentralBus.get_split_key ()) &&
                   (Ensembles.Core.CentralBus.get_accomp_on () || Ensembles.Core.CentralBus.get_split_on ()))
                    get_style_context ().add_class ("white-key-split");
            }
            if (_index == Ensembles.Core.CentralBus.get_split_key ()) {
                get_style_context ().add_class ("common-key-split");
            }
        }
    }
}
