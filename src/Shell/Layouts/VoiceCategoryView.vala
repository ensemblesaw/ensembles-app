/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class VoiceCategoryView : Gtk.Grid {
        Gtk.Button piano_button;
        Gtk.Button chromatic_perc;
        Gtk.Button organ_button;
        Gtk.Button guitar_button;
        Gtk.Button bass_button;
        Gtk.Button strings_button;
        Gtk.Button brass_button;
        Gtk.Button reed_pipe_button;
        Gtk.Button synth_lead_button;
        Gtk.Button synth_pad_button;
        Gtk.Button drums_set_button;
        Gtk.Button extras_button;

        public signal void voice_quick_select (int index);
        public VoiceCategoryView () {
            row_homogeneous = true;
            piano_button = new Gtk.Button.with_label (_("Piano"));
            chromatic_perc = new Gtk.Button.with_label (_("Crm Perc"));
            organ_button = new Gtk.Button.with_label (_("Organ"));
            guitar_button = new Gtk.Button.with_label (_("Guitar"));
            bass_button = new Gtk.Button.with_label (_("Bass"));
            strings_button = new Gtk.Button.with_label (_("Strings"));
            brass_button = new Gtk.Button.with_label (_("Brass"));
            reed_pipe_button = new Gtk.Button.with_label (_("Reed/Pipe"));
            synth_lead_button = new Gtk.Button.with_label (_("Synth Lead"));
            synth_pad_button = new Gtk.Button.with_label (_("Synth Pad"));
            drums_set_button = new Gtk.Button.with_label (_("Drum Kit"));
            extras_button = new Gtk.Button.with_label (_("Extra"));

            var header = new Gtk.Label (" " + _("VOICE TYPES"));
            header.set_opacity (0.4);
            header.valign = Gtk.Align.CENTER;
            header.halign = Gtk.Align.START;

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            separator.valign = Gtk.Align.CENTER;

            attach (header, 0, 0, 1, 1);
            attach (separator, 1, 0, 3, 1);

            attach (piano_button, 0, 1, 1, 1);
            attach (chromatic_perc, 1, 1, 1, 1);
            attach (organ_button, 2, 1, 1, 1);
            attach (guitar_button, 3, 1, 1, 1);

            attach (bass_button, 0, 2, 1, 1);
            attach (strings_button, 1, 2, 1, 1);
            attach (brass_button, 2, 2, 1, 1);
            attach (reed_pipe_button, 3, 2, 1, 1);

            attach (synth_lead_button, 0, 3, 1, 1);
            attach (synth_pad_button, 1, 3, 1, 1);
            attach (drums_set_button, 2, 3, 1, 1);
            attach (extras_button, 3, 3, 1, 1);


            column_spacing = 2;
            row_spacing = 2;
            column_homogeneous = true;
            margin = 4;
            this.show_all ();



            piano_button.clicked.connect (() => {
                voice_quick_select (0);
            });
            chromatic_perc.clicked.connect (() => {
                voice_quick_select (1);
            });
            organ_button.clicked.connect (() => {
                voice_quick_select (2);
            });
            guitar_button.clicked.connect (() => {
                voice_quick_select (3);
            });
            bass_button.clicked.connect (() => {
                voice_quick_select (4);
            });
            strings_button.clicked.connect (() => {
                voice_quick_select (5);
            });
            brass_button.clicked.connect (() => {
                voice_quick_select (6);
            });
            reed_pipe_button.clicked.connect (() => {
                voice_quick_select (7);
            });
            synth_lead_button.clicked.connect (() => {
                voice_quick_select (8);
            });
            synth_pad_button.clicked.connect (() => {
                voice_quick_select (9);
            });
            drums_set_button.clicked.connect (() => {
                voice_quick_select (16);
            });
            extras_button.clicked.connect (() => {
                voice_quick_select (12);
            });
        }
    }
}
