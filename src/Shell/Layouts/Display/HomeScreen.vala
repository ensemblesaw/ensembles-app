/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Layouts.Display {
    public class HomeScreen : Gtk.Box {
        private Gtk.Button power_button;
        private Gtk.Button style_button;
        private Gtk.Button voice_l_button;
        private Gtk.Button voice_r1_button;
        private Gtk.Button voice_r2_button;

        private Gtk.Button dsp_button;
        private Gtk.Button recorder_button;

        private Gtk.Label selected_style_label;
        private Gtk.Label selected_voice_l_label;
        private Gtk.Label selected_voice_r1_label;
        private Gtk.Label selected_voice_r2_label;

        private Gtk.Label tempo_label;
        private Gtk.Label measure_label;
        private Gtk.Label beat_label;
        private Gtk.Label transpose_label;
        private Gtk.Label octave_shift_label;
        private Gtk.Label chord_label;
        private Gtk.Label chord_flat_label;
        private Gtk.Label chord_type_label;

        public signal void change_screen (string screen_name);

        public HomeScreen () {
            Object (
                orientation: Gtk.Orientation.VERTICAL,
                spacing: 0
            );
        }

        construct {
            build_ui ();
            build_events ();
        }

        private void build_ui () {
            add_css_class ("homescreen");

            // Top Panel ///////////////////////////////////////////////////////////////////////////////////////////////
            var top_panel = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                height_request = 48,
                hexpand = true
            };
            append (top_panel);
            top_panel.add_css_class ("homescreen-panel-top");

            if (Application.kiosk_mode) {
                power_button = new Gtk.Button.from_icon_name ("system-shutdown-symbolic") {
                    height_request = 48,
                    width_request = 32
                };
                power_button.add_css_class ("homescreen-panel-top-button");
                top_panel.append (power_button);
            }

            style_button = new Gtk.Button ();
            top_panel.append (style_button);
            style_button.add_css_class ("homescreen-panel-top-button");

            var style_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                height_request = 48,
                hexpand = true
            };
            style_button.set_child (style_button_box);

            var style_label = new Gtk.Label (_("Style")) {
                halign = Gtk.Align.CENTER
            };
            style_button_box.append (style_label);
            style_label.add_css_class ("homescreen-panel-top-button-header");

            selected_style_label = new Gtk.Label (_("Undefined")) {
                ellipsize = Pango.EllipsizeMode.MIDDLE,
                halign = Gtk.Align.CENTER
            };
            style_button_box.append (selected_style_label);
            selected_style_label.add_css_class ("homescreen-panel-top-button-subheader");

            voice_l_button = new Gtk.Button ();
            top_panel.append (voice_l_button);
            voice_l_button.add_css_class ("homescreen-panel-top-button");

            var voice_l_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                height_request = 48,
                hexpand = true
            };
            voice_l_button.set_child (voice_l_button_box);

            var voice_l_label = new Gtk.Label (_("Voice L")) {
                halign = Gtk.Align.CENTER
            };
            voice_l_button_box.append (voice_l_label);
            voice_l_label.add_css_class ("homescreen-panel-top-button-header");

            selected_voice_l_label = new Gtk.Label (_("Undefined")) {
                ellipsize = Pango.EllipsizeMode.MIDDLE,
                halign = Gtk.Align.CENTER
            };
            voice_l_button_box.append (selected_voice_l_label);
            selected_voice_l_label.add_css_class ("homescreen-panel-top-button-subheader");

            voice_r1_button = new Gtk.Button ();
            top_panel.append (voice_r1_button);
            voice_r1_button.add_css_class ("homescreen-panel-top-button");

            var voice_r1_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                height_request = 48,
                hexpand = true
            };
            voice_r1_button.set_child (voice_r1_button_box);

            var voice_r1_label = new Gtk.Label (_("Voice R1")) {
                halign = Gtk.Align.CENTER
            };
            voice_r1_button_box.append (voice_r1_label);
            voice_r1_label.add_css_class ("homescreen-panel-top-button-header");

            selected_voice_r1_label = new Gtk.Label (_("Undefined")) {
                ellipsize = Pango.EllipsizeMode.MIDDLE,
                halign = Gtk.Align.CENTER
            };
            voice_r1_button_box.append (selected_voice_r1_label);
            selected_voice_r1_label.add_css_class ("homescreen-panel-top-button-subheader");

            voice_r2_button = new Gtk.Button ();
            top_panel.append (voice_r2_button);
            voice_r2_button.add_css_class ("homescreen-panel-top-button");

            var voice_r2_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                height_request = 48,
                hexpand = true
            };
            voice_r2_button.set_child (voice_r2_button_box);

            var voice_r2_label = new Gtk.Label (_("Voice R2")) {
                halign = Gtk.Align.CENTER
            };
            voice_r2_button_box.append (voice_r2_label);
            voice_r2_label.add_css_class ("homescreen-panel-top-button-header");

            selected_voice_r2_label = new Gtk.Label (_("Undefined")) {
                ellipsize = Pango.EllipsizeMode.MIDDLE,
                halign = Gtk.Align.CENTER
            };
            voice_r2_button_box.append (selected_voice_r2_label);
            selected_voice_r2_label.add_css_class ("homescreen-panel-top-button-subheader");

            // Middle Panel ////////////////////////////////////////////////////////////////////////////////////////////
            var middle_panel = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                vexpand = true,
                hexpand = true
            };
            append (middle_panel);
            middle_panel.add_css_class ("homescreen-panel-middle");

            dsp_button = new Gtk.Button.with_label (_("Main DSP Rack")) {
                valign = Gtk.Align.END,
                hexpand = true
            };
            middle_panel.append (dsp_button);

            recorder_button = new Gtk.Button.with_label (_("Recorder")) {
                valign = Gtk.Align.END,
                hexpand = true
            };
            middle_panel.append (recorder_button);

            // Bottom Panel ////////////////////////////////////////////////////////////////////////////////////////////
            var bottom_panel = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                vexpand = true,
                hexpand = true
            };
            append (bottom_panel);
            bottom_panel.add_css_class ("homescreen-panel-bottom");
        }

        private void build_events () {
            style_button.clicked.connect (() => {
                change_screen ("style");
            });

            voice_l_button.clicked.connect (() => {
                change_screen ("voice-l");
            });

            voice_r1_button.clicked.connect (() => {
                change_screen ("voice-r1");
            });

            voice_r2_button.clicked.connect (() => {
                change_screen ("voice-r2");
            });

            dsp_button.clicked.connect (() => {
                change_screen ("dsp");
            });

            if (Application.kiosk_mode) {
                power_button.clicked.connect (() => {
                    var power_dialog = new Dialog.PowerDialog (Application.main_window);
                    power_dialog.present ();
                    power_dialog.show ();
                });
            }

            Application.event_bus.style_change.connect ((style) => {
                print ("%s\n", style.name);
                selected_style_label.set_text (style.name);
            });

            Application.event_bus.voice_chosen.connect ((position, name) => {
                switch (position) {
                    case VoiceHandPosition.LEFT:
                    selected_voice_l_label.set_text (name);
                    break;
                    case VoiceHandPosition.RIGHT:
                    selected_voice_r1_label.set_text (name);
                    break;
                    case VoiceHandPosition.RIGHT_LAYERED:
                    selected_voice_r2_label.set_text (name);
                    break;
                }
            });
        }
    }
}
