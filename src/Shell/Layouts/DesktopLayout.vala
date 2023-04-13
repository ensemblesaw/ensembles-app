/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Layouts {
    public class DesktopLayout : Gtk.Grid {
        private weak Layouts.AssignablesBoard assignables_board;
        private weak Layouts.InfoDisplay info_display;
        private weak Layouts.SynthControlPanel synth_control_panel;
        private weak Layouts.VoiceNavPanel voice_nav_panel;
        private weak Layouts.MixerBoard mixer_board;
        private weak Layouts.SamplerPadsPanel sampler_pads_panel;
        private weak Layouts.StyleControlPanel style_control_panel;
        private weak Layouts.RegistryPanel registry_panel;
        private weak Layouts.KeyboardPanel keyboard;
        private Gtk.Button start_button;

        private Gtk.CenterBox top_row;
        private Gtk.CenterBox middle_row;
        private Gtk.Grid bottom_row;
        private Gtk.CenterBox bottom_row_box;
        private Gtk.Revealer bottom_row_revealer;

        construct {
            build_ui ();
        }

        public DesktopLayout (Layouts.AssignablesBoard? assignables_board,
            Layouts.InfoDisplay? info_display,
            Layouts.SynthControlPanel? synth_control_panel,
            Layouts.VoiceNavPanel? voice_nav_panel,
            Layouts.MixerBoard? mixer_board,
            Layouts.SamplerPadsPanel? sampler_pads_panel,
            Layouts.StyleControlPanel? style_control_panel,
            Layouts.RegistryPanel? registry_panel,
            Layouts.KeyboardPanel? keyboard) {
            Object (
                width_request: 812,
                height_request: 600,
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


            bottom_row_revealer = new Gtk.Revealer () {
                reveal_child = true,
                hexpand = true
            };
            attach (bottom_row_revealer, 0, 2);

            bottom_row = new Gtk.Grid () {
                hexpand = true
            };
            bottom_row_revealer.set_child (bottom_row);

            bottom_row_box = new Gtk.CenterBox ();
            bottom_row.attach (bottom_row_box, 0, 0);

            var start_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
            start_button_box.add_css_class ("panel");
            bottom_row_box.set_center_widget (start_button_box);

            start_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic") {
                width_request = 64,
                height_request = 32
            };
            start_button.add_css_class (Granite.STYLE_CLASS_DESTRUCTIVE_ACTION);
            start_button.remove_css_class ("image-button");
            start_button.clicked.connect (() => {
                Application.event_bus.style_play_toggle ();
            });

            start_button_box.append (start_button);
            start_button_box.append (new Gtk.Label (_("START/STOP")) { opacity = 0.5 });
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
            info_display.fill_screen = false;
            top_row.set_end_widget (synth_control_panel);

            middle_row.set_start_widget (voice_nav_panel);
            middle_row.set_center_widget (mixer_board);
            middle_row.set_end_widget (sampler_pads_panel);

            bottom_row_box.set_start_widget (style_control_panel);
            bottom_row_box.set_end_widget (registry_panel);
            bottom_row.attach (keyboard, 0, 1);
        }
    }
}
