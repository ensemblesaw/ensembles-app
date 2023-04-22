/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Shell.Layouts.Display;

namespace Ensembles.Shell.Layouts {
    public class InfoDisplay : Gtk.Box {
        private Gtk.Overlay main_overlay;
        private Gtk.Box splash_screen;
        private Gtk.Label splash_screen_label;
        private Gtk.Stack main_stack;

        private bool _fill_screen;
        public bool fill_screen {
            get {
                return _fill_screen;
            }
            set {
                _fill_screen = value;
                if (value) {
                    remove_css_class ("panel");
                    main_overlay.add_css_class ("fill");
                } else {
                    add_css_class ("panel");
                    main_overlay.remove_css_class ("fill");
                }
            }
        }

        // Screens
        private HomeScreen home_screen;
        private StyleScreen style_screen;
        private VoiceScreen voice_l_screen;
        private VoiceScreen voice_r1_screen;
        private VoiceScreen voice_r2_screen;
        private DSPScreen dsp_screen;
        private PluginScreen plugin_screen;

        construct {
            build_ui ();
            build_events ();
        }

        public InfoDisplay () {
            Object (
                hexpand: true,
                vexpand: true,
                width_request: 480,
                height_request: 360
            );
        }

        private void build_ui () {
            add_css_class ("panel");

            main_overlay = new Gtk.Overlay () {
                hexpand = true,
                vexpand = true,
                overflow = Gtk.Overflow.HIDDEN
            };
            main_overlay.add_css_class ("display");
            append (main_overlay);

            splash_screen = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            splash_screen.add_css_class ("splash-screen-background");
            main_overlay.add_overlay (splash_screen);

            var splash_banner = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true,
                vexpand = true
            };
            splash_banner.add_css_class ("ensembles-logo-splash");
            splash_screen.append (splash_banner);

            splash_screen_label = new Gtk.Label (_("Initializing…")) {
                xalign = 0,
                margin_start = 8,
                margin_bottom = 8,
                margin_end = 8,
                margin_top = 8,
                opacity = 0.5
            };
            splash_screen_label.add_css_class ("splash-screen-label");
            splash_screen.append (splash_screen_label);

            main_stack = new Gtk.Stack () {
                transition_type = Gtk.StackTransitionType.OVER_UP_DOWN
            };
            main_stack.add_css_class ("display-stack");
            main_stack.add_css_class ("fade-black");
            main_overlay.set_child (main_stack);

            home_screen = new HomeScreen ();
            main_stack.add_named (home_screen, "home");

            style_screen = new StyleScreen ();
            main_stack.add_named (style_screen, "style");

            voice_l_screen = new VoiceScreen (Ensembles.VoiceHandPosition.LEFT);
            main_stack.add_named (voice_l_screen, "voice-l");

            voice_r1_screen = new VoiceScreen (Ensembles.VoiceHandPosition.RIGHT);
            main_stack.add_named (voice_r1_screen, "voice-r1");

            voice_r2_screen = new VoiceScreen (Ensembles.VoiceHandPosition.RIGHT_LAYERED);
            main_stack.add_named (voice_r2_screen, "voice-r2");
        }

        private void build_events () {
            Application.event_bus.arranger_ready.connect (() => {
                splash_screen.add_css_class ("fade-black");

                Timeout.add (1000, () => {
                    main_overlay.remove_overlay (splash_screen);
                    if (splash_screen != null) {
                        splash_screen.unref ();
                    }

                    Timeout.add (200, () => {
                        main_stack.remove_css_class ("fade-black");
                        return false;
                    });

                    Timeout.add (400, () => {
                        dsp_screen = new DSPScreen (Application.arranger_workstation.get_main_dsp_rack ());
                        dsp_screen.close.connect (navigate_to_home);
                        main_stack.add_named (dsp_screen, "dsp");
                        return false;
                    });
                    return false;
                });

            });

            home_screen.change_screen.connect ((screen_name) => {
                main_stack.set_visible_child_name (screen_name);
            });

            Application.event_bus.send_initial_status.connect (update_status);

            style_screen.close.connect (navigate_to_home);
            voice_l_screen.close.connect (navigate_to_home);
            voice_r1_screen.close.connect (navigate_to_home);
            voice_r2_screen.close.connect (navigate_to_home);

            Application.event_bus.show_plugin_ui.connect (show_plugin_screen);
        }

        public void navigate_to_home () {
            main_stack.set_visible_child_name ("home");
        }

        public void show_plugin_screen (Core.Plugins.AudioPlugins.AudioPlugin plugin) {
            if (plugin_screen != null) {
                main_stack.remove (plugin_screen);
                plugin_screen = null;
            }

            plugin_screen = new PluginScreen (plugin) {
                history = main_stack.get_visible_child_name ()
            };
            plugin_screen.close.connect (() => {
                main_stack.set_visible_child_name (plugin_screen.history);
            });
            main_stack.add_named (plugin_screen, "plugin");
            main_stack.set_visible_child_name ("plugin");
        }

        public void update_status (string status) {
            Idle.add (() => {
                splash_screen_label.set_text (status);
                return false;
            });
        }
    }
}
