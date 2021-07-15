/*-
 * Copyright (c) 2021-2022 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License 
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
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
            piano_button = new Gtk.Button.with_label ("Piano");
            chromatic_perc = new Gtk.Button.with_label ("Crm Perc");
            organ_button = new Gtk.Button.with_label ("Organ");
            guitar_button = new Gtk.Button.with_label ("Guitar");
            bass_button = new Gtk.Button.with_label ("Bass");
            strings_button = new Gtk.Button.with_label ("Strings");
            brass_button = new Gtk.Button.with_label ("Brass");
            reed_pipe_button = new Gtk.Button.with_label ("Reed/Pipe");
            synth_lead_button = new Gtk.Button.with_label ("Synth Lead");
            synth_pad_button = new Gtk.Button.with_label ("Synth Pad");
            drums_set_button = new Gtk.Button.with_label ("Drum Kit");
            extras_button = new Gtk.Button.with_label ("Extra");

            var header = new Gtk.Label (" VOICE TYPES");
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
