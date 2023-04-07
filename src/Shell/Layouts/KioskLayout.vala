/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

 namespace Ensembles.Shell.Layouts {
    public class KioskLayout : Gtk.Grid {
        private unowned InfoDisplay info_display;
        private unowned MixerBoard mixer_board;

        construct {
            add_css_class ("panel");
        }

        public KioskLayout (InfoDisplay info_display, MixerBoard mixer_board) {
            Object (
                hexpand: true,
                vexpand: true
            );

            this.info_display = info_display;
            this.mixer_board = mixer_board;

            build_ui ();
        }

        private void build_ui () {
            attach (info_display, 0, 0);
            attach (mixer_board, 0, 1);
        }
    }
}
