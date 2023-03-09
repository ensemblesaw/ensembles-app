/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Layouts {
    public class MobileLayout : Gtk.Grid {
        private weak Layouts.AssignablesBoard assignables_board;
        private weak Layouts.InfoDisplay info_display;
        private weak Layouts.SynthControlPanel synth_control_panel;
        private weak Layouts.VoiceNavPanel voice_nav_panel;
        private weak Layouts.MixerBoard mixer_board;
        private weak Layouts.SamplerPadsPanel sampler_pads_panel;
        private weak Layouts.StyleControlPanel style_control_panel;
        private weak Layouts.RegistryPanel registry_panel;
        private weak Layouts.Keyboard keyboard;

        private Gtk.Grid infoview;
        private Gtk.Grid keyboardview;
        private Gtk.Box style_registry_box;

        private Adw.TabBar tab_bar;
        private Adw.TabView tab_view;

        private Adw.TabPage infopage;
        private Adw.TabPage keyboardpage;

        private Gtk.ScrolledWindow scrolled_window;

        construct {
            build_ui ();
        }

        public MobileLayout (Layouts.AssignablesBoard? assignables_board,
            Layouts.InfoDisplay? info_display,
            Layouts.SynthControlPanel? synth_control_panel,
            Layouts.VoiceNavPanel? voice_nav_panel,
            Layouts.MixerBoard? mixer_board,
            Layouts.SamplerPadsPanel? sampler_pads_panel,
            Layouts.StyleControlPanel? style_control_panel,
            Layouts.RegistryPanel? registry_panel,
            Layouts.Keyboard? keyboard) {
            Object (
                width_request: 812,
                height_request: 375
            );
            this.assignables_board = assignables_board;
            this.info_display = info_display;
            this.synth_control_panel = synth_control_panel;
            this.voice_nav_panel = voice_nav_panel;
            this.mixer_board = mixer_board;
            this.sampler_pads_panel = sampler_pads_panel;
            this.style_control_panel = style_control_panel;
            this.registry_panel = registry_panel;
            this.keyboard = keyboard;
        }

        private void build_ui () {
            tab_view = new Adw.TabView ();
            attach (tab_view, 0, 1);

            tab_bar = new Adw.TabBar () {
                view = tab_view,
                autohide = false
            };
            attach (tab_bar, 0, 0);

            infoview = new Gtk.Grid ();
            infopage = tab_view.append (infoview);
            infopage.title = _("Info Display");

            keyboardview = new Gtk.Grid ();
            keyboardpage = tab_view.append (keyboardview);
            keyboardpage.title = _("Keyboard");

            scrolled_window = new Gtk.ScrolledWindow () {
                height_request = 62,
                vscrollbar_policy = Gtk.PolicyType.NEVER
            };
            keyboardview.attach (scrolled_window, 0, 0);
            style_registry_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            scrolled_window.set_child (style_registry_box);
        }

        public void reparent () {
            assignables_board.unparent ();
            info_display.unparent ();
            synth_control_panel.unparent ();
            voice_nav_panel.unparent ();
            mixer_board.unparent ();
            sampler_pads_panel.unparent ();
            style_control_panel.unparent ();
            registry_panel.unparent ();
            keyboard.unparent ();

            infoview.attach (info_display, 0, 0);

            style_registry_box.append (style_control_panel);
            style_registry_box.append (registry_panel);
            keyboardview.attach (keyboard, 0, 1);
        }
    }
}
