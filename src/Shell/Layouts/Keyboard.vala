/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Layouts {
    public class Keyboard : Gtk.Grid {
        construct {
            add_css_class ("panel");
        }

        public Keyboard () {
            Object (
                hexpand: true
            );
        }
    }
}
