/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    /* A widget that is used for visualising musical keyboard
     * input and also packs a joystick as part of it's layout
     */
    public class KeyBed : Gtk.Grid {
        OctaveKeyboard[] octaves;
        Gtk.Box key_grid;
        Gtk.Switch hold_switch;
        Gtk.Switch zoom_switch;
        public JoyStick joy_stick;
        Core.Synthesizer _synth;
        Gtk.Button sustain_button;
        Gtk.Button stop_button;

        Gtk.ScrolledWindow keyboard_scroller;
        public KeyBed () {
            get_style_context ().add_class ("keyboard-background");
            key_grid = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

            octaves = new OctaveKeyboard[5];
            for (int i = 0; i < 5; i++) {
                octaves[i] = new OctaveKeyboard (i + 3);
                octaves[i].margin_top = 18;
                key_grid.pack_start (octaves[i]);
            }

            keyboard_scroller = new Gtk.ScrolledWindow (null, null) {
                kinetic_scrolling = false,
                overlay_scrolling = false
            };
            keyboard_scroller.set_placement (Gtk.CornerType.BOTTOM_LEFT);
            keyboard_scroller.add (key_grid);

            var keyboard_overlay = new Gtk.Overlay () {
                height_request = 170,
                hexpand = true
            };
            keyboard_overlay.add_overlay (keyboard_scroller);

            zoom_switch = new Gtk.Switch () {
                valign = Gtk.Align.CENTER,
                margin_start = 8,
                margin_end = 8
            };
            zoom_switch.notify["active"].connect (() => {
                toggle_zoom (zoom_switch.active);
            });
            hold_switch = new Gtk.Switch () {
                valign = Gtk.Align.CENTER,
                margin_start = 8,
                margin_end = 14
            };

            sustain_button = new Gtk.Button.with_label (_("SUST"));
            sustain_button.button_press_event.connect (() => {
                Application.arranger_core.synthesizer.sustain (true);
                return false;
            });
            sustain_button.button_release_event.connect (() => {
                Application.arranger_core.synthesizer.sustain (false);
                return false;
            });
            stop_button = new Gtk.Button.with_label (_("STOP"));
            stop_button.clicked.connect (() => {
                Application.arranger_core.synthesizer.halt_realtime (false);
            });

            var switch_bar = new Gtk.Grid () {
                hexpand = true,
                vexpand = true,
                halign = Gtk.Align.END,
                valign = Gtk.Align.CENTER
            };
            switch_bar.attach (new Gtk.Label (_("H O L D")), 0, 0);
            switch_bar.attach (hold_switch, 1, 0);
            switch_bar.attach (new Gtk.Label (_("Z O O M")), 2, 0);
            switch_bar.attach (zoom_switch, 3, 0);
            switch_bar.attach (sustain_button, 4, 0);
            switch_bar.attach (stop_button, 5, 0);

            var keyboard_top_bar = new Gtk.Grid () {
                valign = Gtk.Align.START,
                height_request = 32
            };
            keyboard_top_bar.get_style_context ().add_class ("keyboard-top-bar");
            keyboard_top_bar.add (switch_bar);


            keyboard_overlay.add_overlay (keyboard_top_bar);
            keyboard_overlay.set_overlay_pass_through (keyboard_top_bar, true);

            joy_stick = new JoyStick ();
            add (joy_stick);
            add (keyboard_overlay);
            show_all ();
        }

        public void connect_synthesizer (Ensembles.Core.Synthesizer synth) {
            _synth = synth;
            octaves[0].note_activate.connect ((index, is_pressed) => {
                _synth.send_notes_realtime (index + 36, is_pressed, 100);
            });
            octaves[1].note_activate.connect ((index, is_pressed) => {
                _synth.send_notes_realtime (index + 48, is_pressed, 100);
            });
            octaves[2].note_activate.connect ((index, is_pressed) => {
                _synth.send_notes_realtime (index + 60, is_pressed, 100);
            });
            octaves[3].note_activate.connect ((index, is_pressed) => {
                _synth.send_notes_realtime (index + 72, is_pressed, 100);
            });
            octaves[4].note_activate.connect ((index, is_pressed) => {
                _synth.send_notes_realtime (index + 84, is_pressed, 100);
            });
        }

        public void toggle_zoom (bool active) {
            if (active) {
                key_grid.width_request = 3200;
                for (int i = 0; i < 5; i++) {
                    octaves[i].margin_top = 0;
                }

            } else {
                key_grid.width_request = -1;
                for (int i = 0; i < 5; i++) {
                    octaves[i].margin_top = 18;
                }
            }
        }

        public void set_note_on (int key, bool on, Key.NoteType note_type) {
            if (key > 35 && key < 96) {
                octaves[(int)(key / 12) - 3].set_note_on (key % 12, on, note_type);
            }
        }

        public void update_split () {
            for (int i = 0; i < 5; i++) {
                octaves[i].update_split ();
            }
        }

        public void halt_all () {
            for (int i = 0; i < 5; i++) {
                for (int j = 0; j < 11; j++) {
                    octaves[i].set_note_on (j, false, Key.NoteType.AUTOMATION);
                    octaves[i].set_note_on (j, false, Key.NoteType.NORMAL);
                    octaves[i].set_note_on (j, false, Key.NoteType.CHORD);
                }
            }
        }
    }
}
