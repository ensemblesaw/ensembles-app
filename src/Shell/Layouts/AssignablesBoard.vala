/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Layouts {
    public class AssignablesBoard : Gtk.Grid {
        construct {
            add_css_class ("panel");
        }

        public AssignablesBoard () {
            Object (
                hexpand: true,
                vexpand: true
            );
        }
    }
}
