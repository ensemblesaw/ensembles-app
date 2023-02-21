/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Layouts {
    public class SynthControlPanel : Gtk.Grid {
        construct {
            get_style_context ().add_class ("panel");
        }

        public SynthControlPanel () {
            Object (
                hexpand: true,
                vexpand: true
            );
        }
    }
}