/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Layouts {
    public class DesktopLayout : Gtk.Grid {
        private unowned Layouts.AssignablesBoard assignables_board;
        private unowned Layouts.InfoDisplay info_display;
        private unowned Layouts.SynthControlPanel synth_control_panel;
        private unowned Layouts.VoiceNavPanel voice_nav_panel;
        private unowned Layouts.MixerBoard mixer_board;
        private unowned Layouts.SamplerPadsPanel sampler_pads_panel;
        private unowned Layouts.StyleControlPanel style_control_panel;
        private unowned Layouts.RegistryPanel registry_panel;
        private unowned Layouts.Keyboard keyboard;

        private Gtk.CenterBox top_row;
        private Gtk.CenterBox middle_row;
        private Gtk.Grid bottom_row;

        construct {
            build_ui ();
        }

        public DesktopLayout (Layouts.AssignablesBoard assignables_board,
            Layouts.InfoDisplay info_display,
            Layouts.SynthControlPanel synth_control_panel,
            Layouts.VoiceNavPanel voice_nav_panel,
            Layouts.MixerBoard mixer_board,
            Layouts.SamplerPadsPanel sampler_pads_panel,
            Layouts.StyleControlPanel style_control_panel,
            Layouts.RegistryPanel registry_panel,
            Layouts.Keyboard keyboard) {
            Object (
                width_request: 812,
                height_request: 428,
                hexpand: true,
                vexpand: true
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
            top_row = new Gtk.CenterBox () {
                hexpand = true,
                vexpand = true
            };
            attach (top_row, 0, 0);

            middle_row = new Gtk.CenterBox () {
                hexpand = true,
                vexpand = true
            };
            attach (middle_row, 0, 1);


            var bottom_row_revealer = new Gtk.Revealer () {
                reveal_child = true,
                hexpand = true
            };
            attach (bottom_row_revealer, 0, 2);

            bottom_row = new Gtk.Grid () {
                hexpand = true
            };
            bottom_row_revealer.set_child (bottom_row);
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

            top_row.set_start_widget (assignables_board);
            top_row.set_center_widget (info_display);
            top_row.set_end_widget (synth_control_panel);

            middle_row.set_start_widget (voice_nav_panel);
            middle_row.set_center_widget (mixer_board);
            middle_row.set_end_widget (sampler_pads_panel);

            bottom_row.attach (style_control_panel, 0, 0);
            bottom_row.attach (registry_panel, 1, 0);
            bottom_row.attach (keyboard, 0, 2, 2, 1);
        }
    }
}
