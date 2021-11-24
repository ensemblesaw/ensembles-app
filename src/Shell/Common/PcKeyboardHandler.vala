/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class PcKeyboardHandler : Object {
        bool[] key_activated;
        public signal void note_activate (int key, int on);

        public signal void style_start_stop ();
        public signal void style_var_a ();
        public signal void style_var_b ();
        public signal void style_var_c ();
        public signal void style_var_d ();
        public signal void style_break ();
        public signal void style_intro_a ();
        public signal void style_intro_b ();
        public signal void style_ending_a ();
        public signal void style_ending_b ();

        public signal void registration_recall (uint index);
        public signal void registration_bank_change (bool up);

        public signal void numpad_entry (uint number);

        public PcKeyboardHandler () {
            key_activated = new bool [60];
            KeyboardConstants.load_mapping (Ensembles.Application.settings);
        }
        public bool handle_keypress_event (uint keyval) {
            if ((keyval > 64 && keyval < 91) ||
                (keyval > 96 && keyval < 123) ||
                keyval == 44 ||
                keyval == 46 ||
                keyval == 47 ||
                keyval == 91 ||
                keyval == 93 ||
                keyval == 123 ||
                keyval == 125 ||
                keyval == 60 ||
                keyval == 62 ||
                keyval == 63 ||
                keyval == 59 ||
                keyval == 39 ||
                keyval == 34 ||
                keyval == 58) {

                var note = KeyboardConstants.get_note_from_keycode (keyval);
                if (note >= 0) {
                    if (!key_activated[note]) {
                        note_activate (note + 36, 144);
                        key_activated[note] = true;
                    }
                }
            } else {
                switch (keyval) {
                    // Style controls
                    case KeyboardConstants.KeyMap.RETURN_NUMPAD:
                    case KeyboardConstants.KeyMap.NUMPAD_HOME:
                    case KeyboardConstants.KeyMap.NUMPAD_END:
                    case KeyboardConstants.KeyMap.PAGE_UP:
                    case KeyboardConstants.KeyMap.PAGE_DOWN:
                    case KeyboardConstants.KeyMap.NUMPAD_RADIX:
                    case KeyboardConstants.KeyMap.SLASH_NUMPAD:
                    case KeyboardConstants.KeyMap.STAR_NUMPAD:
                    case KeyboardConstants.KeyMap.MINUS_NUMPAD:
                    case KeyboardConstants.KeyMap.PLUS_NUMPAD:
                    return true;
                    // Registration Memory
                    case KeyboardConstants.KeyMap.MINUS_KEYPAD:
                    case KeyboardConstants.KeyMap.PLUS_KEYPAD:
                    return false;
                }
            }
            return false;
        }

        public void handle_keyrelease_event (uint keyval) {
            if (keyval == KeyboardConstants.KeyMap.SHIFT || keyval == KeyboardConstants.KeyMap.SHIFTALT) {
                for (int i = 0; i < 60; i++) {
                    if (key_activated[i]) {
                        note_activate (i + 36, 128);
                        key_activated[i] = false;
                    }
                }
            } else if ((keyval > 64 && keyval < 91) ||
                (keyval > 96 && keyval < 123) ||
                keyval == 44 ||
                keyval == 46 ||
                keyval == 47 ||
                keyval == 91 ||
                keyval == 93 ||
                keyval == 123 ||
                keyval == 125 ||
                keyval == 60 ||
                keyval == 62 ||
                keyval == 63 ||
                keyval == 59 ||
                keyval == 39 ||
                keyval == 34 ||
                keyval == 58) {

                var note = KeyboardConstants.get_note_from_keycode (keyval);
                if (note >= 0) {
                    note_activate (note + 36, 128);
                    key_activated[note] = false;
                }
            } else {
                switch (keyval) {
                    // Style controls
                    case KeyboardConstants.KeyMap.RETURN_NUMPAD:
                    style_start_stop ();
                    break;
                    case KeyboardConstants.KeyMap.NUMPAD_HOME:
                    style_intro_b ();
                    break;
                    case KeyboardConstants.KeyMap.NUMPAD_END:
                    style_ending_b ();
                    break;
                    case KeyboardConstants.KeyMap.PAGE_UP:
                    style_intro_a ();
                    break;
                    case KeyboardConstants.KeyMap.PAGE_DOWN:
                    style_ending_a ();
                    break;
                    case KeyboardConstants.KeyMap.NUMPAD_RADIX:
                    style_break ();
                    break;
                    case KeyboardConstants.KeyMap.SLASH_NUMPAD:
                    style_var_a ();
                    break;
                    case KeyboardConstants.KeyMap.STAR_NUMPAD:
                    style_var_b ();
                    break;
                    case KeyboardConstants.KeyMap.MINUS_NUMPAD:
                    style_var_c ();
                    break;
                    case KeyboardConstants.KeyMap.PLUS_NUMPAD:
                    style_var_d ();
                    break;
                    // Registration Memory
                    case KeyboardConstants.KeyMap.MINUS_KEYPAD:
                    registration_bank_change (false);
                    break;
                    case KeyboardConstants.KeyMap.PLUS_KEYPAD:
                    case KeyboardConstants.KeyMap.EQUAL_TO:
                    registration_bank_change (true);
                    break;
                }

                if (KeyboardConstants.key_is_number_numpad (keyval)) {
                    numpad_entry (keyval - KeyboardConstants.KeyMap.NUMPAD_0);
                }

                if (KeyboardConstants.key_is_number_keypad (keyval)) {
                    registration_recall (keyval - KeyboardConstants.KeyMap.KEYPAD_0 - 1);
                }
            }
        }
    }
}
