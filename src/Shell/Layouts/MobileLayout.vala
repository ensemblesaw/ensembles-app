/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
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
        private weak Layouts.KeyboardPanel keyboard;

        private Gtk.Grid infoview;
        private Gtk.Grid keyboardview;
        private Gtk.Box style_registry_box;
        private Gtk.Box style_controller_socket;
        private Gtk.Box registry_socket;
        private Gtk.Button start_button;

        private Gtk.ScrolledWindow scrolled_window;
        private Adw.Flap flap;
        private Gtk.Stack main_stack;

        private Gtk.ListBox menu_box;

        construct {
            build_ui ();
            build_events ();
        }

        public MobileLayout (Layouts.AssignablesBoard? assignables_board,
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
            flap = new Adw.Flap ();
            attach (flap, 0, 0);

            // Make menu
            menu_box = new Gtk.ListBox () {
                width_request = 200
            };
            flap.set_flap (menu_box);
            menu_box.add_css_class ("adw-listbox");

            var info_entry = new Adw.ActionRow () {
                title = "Info Display",
                subtitle = "View interactive infomation display",
                name = "info"
            };
            menu_box.append (info_entry);

            var keyboard_entry = new Adw.ActionRow () {
                title = "Keyboard",
                subtitle = "Show the keys, style control buttons and registry buttons",
                name = "keyboard"
            };
            menu_box.append (keyboard_entry);

            main_stack = new Gtk.Stack () {
                width_request = 800,
                transition_type = Gtk.StackTransitionType.SLIDE_UP_DOWN,
                transition_duration = 300
            };
            flap.set_content (main_stack);

            // Make Content
            infoview = new Gtk.Grid ();
            main_stack.add_named (infoview, "info-view");

            keyboardview = new Gtk.Grid ();
            main_stack.add_named (keyboardview, "keyboard-view");

            scrolled_window = new Gtk.ScrolledWindow () {
                height_request = 62,
                vscrollbar_policy = Gtk.PolicyType.NEVER
            };
            keyboardview.attach (scrolled_window, 0, 0);
            style_registry_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            scrolled_window.set_child (style_registry_box);

            style_controller_socket = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            style_registry_box.append (style_controller_socket);

            var start_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
            start_button_box.add_css_class ("panel");
            style_registry_box.append (start_button_box);

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

            registry_socket = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            style_registry_box.append (registry_socket);
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
            info_display.fill_screen = true;

            style_controller_socket.append (style_control_panel);
            registry_socket.append (registry_panel);
            keyboardview.attach (keyboard, 0, 1);
        }

        private void build_events () {
            menu_box.row_selected.connect ((row) => {
                main_stack.set_visible_child_name (row.name + "-view");
            });

            Application.event_bus.show_menu.connect ((show) => {
                flap.set_reveal_flap (show);
                return !show;
            });

            flap.notify.connect ((param) => {
                if (param.name == "reveal-flap") {
                    Application.event_bus.menu_shown (flap.reveal_flap);
                    Idle.add (() => {
                        if (flap.reveal_flap && flap.folded) {
                            main_stack.add_css_class ("dimmed");
                        } else {
                            main_stack.remove_css_class ("dimmed");
                        }
                        return false;
                    });
                }
            });
        }
    }
}
