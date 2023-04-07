/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Layouts {
    public class PluginView : Gtk.Box {
        public weak Display.DisplayWindow plugin_ui { get; set; }

        public void reparent () {
            plugin_ui.unparent ();
            append (plugin_ui);
        }
    }
}
