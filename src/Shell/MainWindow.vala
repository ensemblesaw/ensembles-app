/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

 namespace Ensembles.Shell {
    public class MainWindow : Gtk.ApplicationWindow {
        // Event Handling
        private Gtk.EventControllerKey event_controller_key;

        // Headerbar
        private Gtk.HeaderBar headerbar;

        // Responsive UI
        private Adw.Squeezer squeezer;

        // Various major layouts
        private Layouts.DesktopLayout desktop_layout;
        private Layouts.MobileLayout mobile_layout;
        private Layouts.KioskLayout kiosk_layout;

        // Sub-layouts
        private Layouts.AssignablesBoard assignables_board;
        private Layouts.InfoDisplay info_display;
        private Layouts.SynthControlPanel synth_control_panel;
        private Layouts.VoiceNavPanel voice_nav_panel;
        private Layouts.MixerBoard mixer_board;
        private Layouts.SamplerPadsPanel sampler_pads_panel;
        private Layouts.StyleControlPanel style_control_panel;
        private Layouts.RegistryPanel registry_panel;
        private Layouts.Keyboard keyboard;

        public MainWindow (Ensembles.Application? ensembles_app) {
            Object (
                application: ensembles_app,
                icon_name: Constants.APP_ID,
                title: "Ensembles"
            );
        }

        construct {
            build_ui ();
            build_events ();
        }

        private void build_ui () {
            // Make headerbar
            if (Application.kiosk_mode) {
                decorated = false;
                fullscreened = true;

                info_display = new Layouts.InfoDisplay ();
                mixer_board = new Layouts.MixerBoard ();

                kiosk_layout = new Layouts.KioskLayout (info_display, mixer_board);
                set_child (kiosk_layout);
                return;
            }

            headerbar = new Gtk.HeaderBar () {
                show_title_buttons = true,
            };

            set_titlebar (headerbar);

            squeezer = new Adw.Squeezer () {
                orientation = Gtk.Orientation.VERTICAL,
                transition_type = Adw.SqueezerTransitionType.CROSSFADE,
                transition_duration = 400
            };
            set_child (squeezer);

            assignables_board = new Layouts.AssignablesBoard ();
            info_display = new Layouts.InfoDisplay ();
            synth_control_panel = new Layouts.SynthControlPanel ();
            voice_nav_panel = new Layouts.VoiceNavPanel ();
            mixer_board = new Layouts.MixerBoard ();
            sampler_pads_panel = new Layouts.SamplerPadsPanel ();
            style_control_panel = new Layouts.StyleControlPanel ();
            registry_panel = new Layouts.RegistryPanel ();
            keyboard = new Layouts.Keyboard ();

            desktop_layout = new Layouts.DesktopLayout (assignables_board,
                                                        info_display,
                                                        synth_control_panel,
                                                        voice_nav_panel,
                                                        mixer_board,
                                                        sampler_pads_panel,
                                                        style_control_panel,
                                                        registry_panel,
                                                        keyboard);
            squeezer.add (desktop_layout);


            mobile_layout = new Layouts.MobileLayout (assignables_board,
                                                      info_display,
                                                      synth_control_panel,
                                                      voice_nav_panel,
                                                      mixer_board,
                                                      sampler_pads_panel,
                                                      style_control_panel,
                                                      registry_panel,
                                                      keyboard);
            squeezer.add (mobile_layout);
        }

        public void show_ui () {
            present ();
            show ();
        }

        private void build_events () {
            event_controller_key = new Gtk.EventControllerKey ();
            ((Gtk.Widget)this).add_controller (event_controller_key);

            event_controller_key.key_pressed.connect ((keyval, keycode, state) => {
                Console.log ("key: %u".printf (keyval));

                return false;
            });

            Ensembles.Application.event_bus.arranger_ready.connect (() => {
                Console.log ("Arranger Workstation Initialized!", Console.LogLevel.SUCCESS);
            });
        }

        protected override void size_allocate (int width, int height, int baseline) {
            if (!Application.kiosk_mode) {
                if (squeezer.get_visible_child () == desktop_layout) {
                    desktop_layout.reparent ();
                } else {
                    mobile_layout.reparent ();
                }
            }

            base.size_allocate (width, height, baseline);
        }
    }
 }
