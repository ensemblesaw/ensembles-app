/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Shell.Widgets.Display;

namespace Ensembles.Shell.Layouts.Display {
    public class StyleScreen : DisplayWindow {
        private Gtk.ListBox main_list_box;
        public StyleScreen () {
            base (_("Style"), _("Pick a Rhythm to accompany you"));
        }

        construct {
            build_ui ();
        }

        private void build_ui () {
            var scrollable = new Gtk.ScrolledWindow () {
                hexpand = true,
                vexpand = true,
                margin_start = 8,
                margin_end = 8,
                margin_top = 8,
                margin_bottom = 8
            };
            append (scrollable);

            main_list_box = new Gtk.ListBox ();
            main_list_box.get_style_context ().add_class ("menu-box");
            scrollable.set_child (main_list_box);

        }
    }
}
