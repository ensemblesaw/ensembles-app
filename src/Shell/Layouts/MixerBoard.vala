/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Layouts {
    public class MixerBoard : Gtk.Grid {
        construct {
            get_style_context ().add_class ("panel");
        }
    }
}
