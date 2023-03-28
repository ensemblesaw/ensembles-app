/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Shell.Widgets.Display;
using Ensembles.Models;

namespace Ensembles.Shell.Layouts.Display {
    public class DSPScreen : DisplayWindow {
        private Gtk.Button dsp_repository_button;
        private Gtk.Switch dsp_switch;
        public DSPScreen () {
            base (_("Main DSP Rack"), _("Add Effects to the Rack to apply them globally"));
        }

        construct {
            build_ui ();
        }

        private void build_ui () {
            dsp_switch = new Gtk.Switch () {
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.CENTER
            };
            add_to_header (dsp_switch);

            dsp_repository_button = new Gtk.Button.from_icon_name ("plugin-add-symbolic") {
                width_request = 36
            };
            add_to_header (dsp_repository_button);
        }
    }
}
