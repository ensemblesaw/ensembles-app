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
        private Gtk.Label dsp_status;
        private Gtk.Button recorder_button;
        private Gtk.Label recorder_status;

        private Gtk.Label selected_style_label;
        private Gtk.Label selected_voice_l_label;
        private Gtk.Label selected_voice_r1_label;
        private Gtk.Label selected_voice_r2_label;

        private Gtk.Label tempo_label;
        private Gtk.Label measure_label;
        private Gtk.Label beat_label;
        private Gtk.Label transpose_label;
        private Gtk.Label octave_label;
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

            var links_section = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                height_request = 200
            };
            links_section.add_css_class ("homescreen-links-section");
            append(links_section);

            // Top Links ///////////////////////////////////////////////////////////////////////////////////////////////

            var top_link_panel = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                height_request = 56,
                hexpand = true
            };
            top_link_panel.add_css_class ("homescreen-link-panel-top");
            links_section.append (top_link_panel);

            if (Application.kiosk_mode) {
                power_button = new Gtk.Button.from_icon_name ("system-shutdown-symbolic") {
                    height_request = 48,
                    width_request = 32
                };
                power_button.add_css_class ("homescreen-link-panel-top-button");
                top_link_panel.append (power_button);
            }

            style_button = new Gtk.Button ();
            top_link_panel.append (style_button);
            style_button.add_css_class ("homescreen-link-panel-top-button");

            var style_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                height_request = 48,
                hexpand = true
            };
            style_button.set_child (style_button_box);

            var style_label = new Gtk.Label (_("Style")) {
                halign = Gtk.Align.CENTER
            };
            style_button_box.append (style_label);
            style_label.add_css_class ("homescreen-link-panel-top-button-header");

            selected_style_label = new Gtk.Label (_("Undefined")) {
                ellipsize = Pango.EllipsizeMode.MIDDLE,
                halign = Gtk.Align.CENTER
            };
            style_button_box.append (selected_style_label);
            selected_style_label.add_css_class ("homescreen-link-panel-top-button-subheader");

            voice_l_button = new Gtk.Button ();
            top_link_panel.append (voice_l_button);
            voice_l_button.add_css_class ("homescreen-link-panel-top-button");

            var voice_l_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                height_request = 48,
                hexpand = true
            };
            voice_l_button.set_child (voice_l_button_box);

            var voice_l_label = new Gtk.Label (_("Voice L")) {
                halign = Gtk.Align.CENTER
            };
            voice_l_button_box.append (voice_l_label);
            voice_l_label.add_css_class ("homescreen-link-panel-top-button-header");

            selected_voice_l_label = new Gtk.Label (_("Undefined")) {
                ellipsize = Pango.EllipsizeMode.MIDDLE,
                halign = Gtk.Align.CENTER
            };
            voice_l_button_box.append (selected_voice_l_label);
            selected_voice_l_label.add_css_class ("homescreen-link-panel-top-button-subheader");

            voice_r1_button = new Gtk.Button ();
            top_link_panel.append (voice_r1_button);
            voice_r1_button.add_css_class ("homescreen-link-panel-top-button");

            var voice_r1_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                height_request = 48,
                hexpand = true
            };
            voice_r1_button.set_child (voice_r1_button_box);

            var voice_r1_label = new Gtk.Label (_("Voice R1")) {
                halign = Gtk.Align.CENTER
            };
            voice_r1_button_box.append (voice_r1_label);
            voice_r1_label.add_css_class ("homescreen-link-panel-top-button-header");

            selected_voice_r1_label = new Gtk.Label (_("Undefined")) {
                ellipsize = Pango.EllipsizeMode.MIDDLE,
                halign = Gtk.Align.CENTER
            };
            voice_r1_button_box.append (selected_voice_r1_label);
            selected_voice_r1_label.add_css_class ("homescreen-link-panel-top-button-subheader");

            voice_r2_button = new Gtk.Button ();
            top_link_panel.append (voice_r2_button);
            voice_r2_button.add_css_class ("homescreen-link-panel-top-button");

            var voice_r2_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                height_request = 48,
                hexpand = true
            };
            voice_r2_button.set_child (voice_r2_button_box);

            var voice_r2_label = new Gtk.Label (_("Voice R2")) {
                halign = Gtk.Align.CENTER
            };
            voice_r2_button_box.append (voice_r2_label);
            voice_r2_label.add_css_class ("homescreen-link-panel-top-button-header");

            selected_voice_r2_label = new Gtk.Label (_("Undefined")) {
                ellipsize = Pango.EllipsizeMode.MIDDLE,
                halign = Gtk.Align.CENTER
            };
            voice_r2_button_box.append (selected_voice_r2_label);
            selected_voice_r2_label.add_css_class ("homescreen-link-panel-top-button-subheader");

            // Bottom Links ////////////////////////////////////////////////////////////////////////////////////////////
            var bottom_links_panel = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                vexpand = true,
                hexpand = true,
                valign = Gtk.Align.END
            };
            links_section.append (bottom_links_panel);
            bottom_links_panel.add_css_class ("homescreen-link-panel-bottom");

            dsp_button = new Gtk.Button () {
                valign = Gtk.Align.END,
                halign = Gtk.Align.START
            };
            dsp_button.add_css_class ("homescreen-link-panel-bottom-button");
            bottom_links_panel.append (dsp_button);

            var dsp_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            dsp_button.set_child (dsp_box);

            dsp_box.append (new Gtk.Separator (Gtk.Orientation.VERTICAL));
            dsp_box.append (new Gtk.Label (_("Main Effect Rack - ")));

            dsp_status = new Gtk.Label (_("0 Effects in Use"));
            dsp_status.add_css_class ("homescreen-link-panel-bottom-button-status");
            dsp_box.append (dsp_status);

            recorder_button = new Gtk.Button () {
                valign = Gtk.Align.END,
                halign = Gtk.Align.START
            };
            recorder_button.add_css_class ("homescreen-link-panel-bottom-button");
            bottom_links_panel.append (recorder_button);

            var recorder_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            recorder_button.set_child (recorder_box);

            recorder_box.append (new Gtk.Separator (Gtk.Orientation.VERTICAL));
            recorder_box.append (new Gtk.Label (_("Recorder - ")));

            recorder_status = new Gtk.Label (_("No Project Open"));
            recorder_status.add_css_class ("homescreen-link-panel-bottom-button-status");
            recorder_box.append (recorder_status);

            // Bottom Panel ////////////////////////////////////////////////////////////////////////////////////////////
            var status_panel = new Gtk.Grid () {
                vexpand = true,
                hexpand = true,
                column_homogeneous = true,
                height_request = 175
            };
            append (status_panel);
            status_panel.add_css_class ("homescreen-panel-status");

            var tempo_header = new Gtk.Label(_("Tempo"));
            tempo_header.add_css_class ("homescreen-panel-status-header");
            status_panel.attach (tempo_header, 0, 0);

            var measure_header = new Gtk.Label(_("Measure"));
            measure_header.add_css_class ("homescreen-panel-status-header");
            status_panel.attach (measure_header, 1, 0);

            var beat_header = new Gtk.Label(_("Time Signature"));
            beat_header.add_css_class ("homescreen-panel-status-header");
            status_panel.attach (beat_header, 2, 0);

            var transpose_header = new Gtk.Label(_("Transpose"));
            transpose_header.add_css_class ("homescreen-panel-status-header");
            status_panel.attach (transpose_header, 3, 0);

            var octave_header = new Gtk.Label(_("Octave"));
            octave_header.add_css_class ("homescreen-panel-status-header");
            status_panel.attach (octave_header, 4, 0);

            var chord_header = new Gtk.Label(_("Chord"));
            chord_header.add_css_class ("homescreen-panel-status-header");
            status_panel.attach (chord_header, 5, 0);

            var tempo_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 1) {
                halign = Gtk.Align.CENTER
            };
            status_panel.attach (tempo_box, 0, 1);

            tempo_label = new Gtk.Label ("120");
            tempo_label.add_css_class ("homescreen-panel-status-label");
            tempo_box.append (tempo_label);

            var tempo_unit_label = new Gtk.Label ("BPM") {
                margin_bottom = 8
            };
            tempo_unit_label.add_css_class ("homescreen-panel-status-label-small");
            tempo_box.append (tempo_unit_label);

            measure_label = new Gtk.Label("0");
            measure_label.add_css_class ("homescreen-panel-status-label");
            status_panel.attach (measure_label, 1, 1);

            beat_label = new Gtk.Label("4 / 4");
            beat_label.add_css_class ("homescreen-panel-status-label");
            status_panel.attach (beat_label, 2, 1);

            transpose_label = new Gtk.Label("0");
            transpose_label.add_css_class ("homescreen-panel-status-label");
            status_panel.attach (transpose_label, 3, 1);

            octave_label = new Gtk.Label("0");
            octave_label.add_css_class ("homescreen-panel-status-label");
            status_panel.attach (octave_label, 4, 1);

            var chord_grid = new Gtk.Grid () {
                halign = Gtk.Align.CENTER
            };
            status_panel.attach (chord_grid, 5, 1);

            chord_label = new Gtk.Label(_("C"));
            chord_label.add_css_class ("homescreen-panel-status-label");
            chord_grid.attach (chord_label, 0, 0, 1, 2);

            chord_flat_label = new Gtk.Label ("#");
            chord_flat_label.add_css_class ("homescreen-panel-status-label-small");
            chord_grid.attach (chord_flat_label, 1, 0);

            chord_type_label = new Gtk.Label ("m");
            chord_type_label.add_css_class ("homescreen-panel-status-label-small");
            chord_grid.attach (chord_type_label, 1, 1);
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
