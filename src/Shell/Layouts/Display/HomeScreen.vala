/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell.Layouts.Display {
    public class HomeScreen : Gtk.Box {
        Gtk.Button style_button;
        Gtk.Button voice_l_button;
        Gtk.Button voice_r1_button;
        Gtk.Button voice_r2_button;

        Gtk.Button dsp_button;
        Gtk.Button recorder_button;

        Gtk.Label selected_style_label;
        Gtk.Label selected_voice_l_label;
        Gtk.Label selected_voice_r1_label;
        Gtk.Label selected_voice_r2_label;

        Gtk.Label tempo_label;
        Gtk.Label measure_label;
        Gtk.Label beat_label;
        Gtk.Label transpose_label;
        Gtk.Label octave_shift_label;
        Gtk.Label chord_label;
        Gtk.Label chord_flat_label;
        Gtk.Label chord_type_label;

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
            get_style_context ().add_class ("homescreen");

            // Top Panel ///////////////////////////////////////////////////////////////////////////////////////////////
            var top_panel = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                height_request = 48,
                hexpand = true
            };
            append (top_panel);
            top_panel.get_style_context ().add_class ("homescreen-panel-top");

            style_button = new Gtk.Button ();
            top_panel.append (style_button);
            style_button.get_style_context ().add_class ("homescreen-panel-top-button");

            var style_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                height_request = 48,
                hexpand = true
            };
            style_button.set_child (style_button_box);

            var style_label = new Gtk.Label (_("Style")) {
                halign = Gtk.Align.CENTER
            };
            style_button_box.append (style_label);
            style_label.get_style_context ().add_class ("homescreen-panel-top-button-header");

            selected_style_label = new Gtk.Label (_("Undefined")) {
                ellipsize = Pango.EllipsizeMode.MIDDLE,
                halign = Gtk.Align.CENTER
            };
            style_button_box.append (selected_style_label);
            selected_style_label.get_style_context ().add_class ("homescreen-panel-top-button-subheader");

            voice_l_button = new Gtk.Button ();
            top_panel.append (voice_l_button);
            voice_l_button.get_style_context ().add_class ("homescreen-panel-top-button");

            var voice_l_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                height_request = 48,
                hexpand = true
            };
            voice_l_button.set_child (voice_l_button_box);

            var voice_l_label = new Gtk.Label (_("Voice L")) {
                halign = Gtk.Align.CENTER
            };
            voice_l_button_box.append (voice_l_label);
            voice_l_label.get_style_context ().add_class ("homescreen-panel-top-button-header");

            selected_voice_l_label = new Gtk.Label (_("Undefined")) {
                ellipsize = Pango.EllipsizeMode.MIDDLE,
                halign = Gtk.Align.CENTER
            };
            voice_l_button_box.append (selected_voice_l_label);
            selected_voice_l_label.get_style_context ().add_class ("homescreen-panel-top-button-subheader");

            voice_r1_button = new Gtk.Button ();
            top_panel.append (voice_r1_button);
            voice_r1_button.get_style_context ().add_class ("homescreen-panel-top-button");

            var voice_r1_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                height_request = 48,
                hexpand = true
            };
            voice_r1_button.set_child (voice_r1_button_box);

            var voice_r1_label = new Gtk.Label (_("Voice R1")) {
                halign = Gtk.Align.CENTER
            };
            voice_r1_button_box.append (voice_r1_label);
            voice_r1_label.get_style_context ().add_class ("homescreen-panel-top-button-header");

            selected_voice_r1_label = new Gtk.Label (_("Undefined")) {
                ellipsize = Pango.EllipsizeMode.MIDDLE,
                halign = Gtk.Align.CENTER
            };
            voice_r1_button_box.append (selected_voice_r1_label);
            selected_voice_r1_label.get_style_context ().add_class ("homescreen-panel-top-button-subheader");

            voice_r2_button = new Gtk.Button ();
            top_panel.append (voice_r2_button);
            voice_r2_button.get_style_context ().add_class ("homescreen-panel-top-button");

            var voice_r2_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                height_request = 48,
                hexpand = true
            };
            voice_r2_button.set_child (voice_r2_button_box);

            var voice_r2_label = new Gtk.Label (_("Voice R2")) {
                halign = Gtk.Align.CENTER
            };
            voice_r2_button_box.append (voice_r2_label);
            voice_r2_label.get_style_context ().add_class ("homescreen-panel-top-button-header");

            selected_voice_r2_label = new Gtk.Label (_("Undefined")) {
                ellipsize = Pango.EllipsizeMode.MIDDLE,
                halign = Gtk.Align.CENTER
            };
            voice_r2_button_box.append (selected_voice_r2_label);
            selected_voice_r2_label.get_style_context ().add_class ("homescreen-panel-top-button-subheader");

            // Middle Panel ////////////////////////////////////////////////////////////////////////////////////////////
            var middle_panel = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                vexpand = true,
                hexpand = true
            };
            append (middle_panel);
            middle_panel.get_style_context ().add_class ("homescreen-panel-middle");

            dsp_button = new Gtk.Button.with_label (_("DSP")) {
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
            bottom_panel.get_style_context ().add_class ("homescreen-panel-bottom");
        }

        private void build_events () {
            style_button.clicked.connect (() => {
                change_screen ("style");
            });

            dsp_button.clicked.connect (() => {
                change_screen ("dsp");
            });
        }
    }
}
