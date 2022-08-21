/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
// vala-lint=skip-file

 namespace Ensembles.Shell {
    public errordomain EnumError {
        UNKNOWN_VALUE
    }

    public class KeyboardConstants {
        public enum KeyMap {
            NUMPAD_0     = 65456,
            NUMPAD_1     = 65457,
            NUMPAD_2     = 65458,
            NUMPAD_3     = 65459,
            NUMPAD_4     = 65460,
            NUMPAD_5     = 65461,
            NUMPAD_6     = 65462,
            NUMPAD_7     = 65463,
            NUMPAD_8     = 65464,
            NUMPAD_9     = 65465,
            NUMPAD_RADIX = 65454,
            KEYPAD_0     = 48,
            KEYPAD_1     = 49,
            KEYPAD_2     = 50,
            KEYPAD_3     = 51,
            KEYPAD_4     = 52,
            KEYPAD_5     = 53,
            KEYPAD_6     = 54,
            KEYPAD_7     = 55,
            KEYPAD_8     = 56,
            KEYPAD_9     = 57,
            KEYPAD_RADIX = 46,
            KEYPAD_COMMA = 44,
            SEMICOLON    = 59,
            SINGLEQUOTE  = 39,
            COLON        = 58,
            DOUBLEQUOTE  = 34,
            F1           = 65470,
            F2           = 65471,
            F3           = 65472,
            F4           = 65473,
            F5           = 65474,
            F6           = 65475,
            F7           = 65476,
            F8           = 65477,
            F9           = 65478,
            F10          = 65479,
            F11          = 65480,
            F12          = 65481,
            BACKSPACE    = 65288,
            DELETE       = 65535,
            TAB          = 65289,
            SHIFT_TAB    = 65056,
            PAGE_UP      = 65365,
            PAGE_DOWN    = 65366,
            NUMPAD_HOME  = 65360,
            NUMPAD_END   = 65367,

            A_LOWER      = 97,
            B_LOWER      = 98,
            C_LOWER      = 99,
            D_LOWER      = 100,
            E_LOWER      = 101,
            F_LOWER      = 102,
            G_LOWER      = 103,
            H_LOWER      = 104,
            I_LOWER      = 105,
            J_LOWER      = 106,
            K_LOWER      = 107,
            L_LOWER      = 108,
            M_LOWER      = 109,
            N_LOWER      = 110,
            O_LOWER      = 111,
            P_LOWER      = 112,
            Q_LOWER      = 113,
            R_LOWER      = 114,
            S_LOWER      = 115,
            T_LOWER      = 116,
            U_LOWER      = 117,
            V_LOWER      = 118,
            W_LOWER      = 119,
            X_LOWER      = 120,
            Y_LOWER      = 121,
            Z_LOWER      = 122,
            A_UPPER      = 65,
            B_UPPER      = 66,
            C_UPPER      = 67,
            D_UPPER      = 68,
            E_UPPER      = 69,
            F_UPPER      = 70,
            G_UPPER      = 71,
            H_UPPER      = 72,
            I_UPPER      = 73,
            J_UPPER      = 74,
            K_UPPER      = 75,
            L_UPPER      = 76,
            M_UPPER      = 77,
            N_UPPER      = 78,
            O_UPPER      = 79,
            P_UPPER      = 80,
            Q_UPPER      = 81,
            R_UPPER      = 82,
            S_UPPER      = 83,
            T_UPPER      = 84,
            U_UPPER      = 85,
            V_UPPER      = 86,
            W_UPPER      = 87,
            X_UPPER      = 88,
            Y_UPPER      = 89,
            Z_UPPER      = 90,
            PLUS_NUMPAD  = 65451,
            MINUS_NUMPAD = 65453,
            SLASH_NUMPAD = 65455,
            STAR_NUMPAD  = 65450,
            PLUS_KEYPAD  = 43,
            MINUS_KEYPAD = 45,
            SLASH_KEYPAD = 47,
            STAR_KEYPAD  = 42,
            PARENTHESIS_L= 40,
            PARENTHESIS_R= 41,
            SQ_BRACKETS_L= 91,
            SQ_BRACKETS_R= 93,
            FL_BRACKETS_L= 123,
            FL_BRACKETS_R= 125,
            EQUAL_TO     = 61,
            PERCENTAGE   = 37,
            EXP_CAP      = 94,
            EXCLAMATION  = 33,
            LT           = 60,
            GT           = 62,
            QUESTION     = 63,

            NAV_LEFT     = 65361,
            NAV_RIGHT    = 65363,
            NAV_UP       = 65362,
            NAV_DOWN     = 65364,

            RETURN       = 65293,
            RETURN_NUMPAD= 65421,
            ESCAPE       = 65307,
            SPACE_BAR    = 32,

            CTRL         = 65507,
            SHIFT        = 65505,
            SHIFTALT     = 65506,

            NONE         = 0;

            public static KeyMap parse (string value) throws EnumError {
                EnumValue? a;
                a = ((EnumClass)typeof (KeyMap).class_ref ()).get_value_by_name (value);
                if (a == null) {
                    throw new EnumError.UNKNOWN_VALUE (@"String $(value) is not a valid value for $(typeof(KeyMap).name())");
                }

                return (KeyMap)a.value;
            }
        }

        public static KeyMap[] key_bindings;

        public static bool key_is_number_numpad (uint key) {
            if ((key >= KeyMap.NUMPAD_0) && (key <= KeyMap.NUMPAD_9))
                return true;
            return false;
        }

        public static bool key_is_number_keypad (uint key) {
            if ((key >= KeyMap.KEYPAD_0) && (key <= KeyMap.KEYPAD_9))
                return true;
            return false;
        }

        public static string keycode_to_string (KeyboardConstants.KeyMap key) {
            string all_labels = _("abcdefghijklmnopqrstuvwxyz,./[]ABCDEFGHIJKLMNOPQRSTUVWXYZ<>{}");
            string label = "";
            uint index = key;
            if (index > 64 && index < 91) {
                label = all_labels.get_char (index - 34).to_string ();
            } else if (index > 96 && index < 123) {
                label = all_labels.get_char (index - 97).to_string ();
            } else if (index == 44) {
                label = _("Comma");
            } else if (index == 46) {
                label = _("Radix");
            } else if (index == 47) {
                label = "/";
            } else if (index == 91) {
                label = "[";
            } else if (index == 93) {
                label = "]";
            } else if (index == 123) {
                label = "{";
            } else if (index == 125) {
                label = "}";
            } else if (index == 60) {
                label = "<";
            } else if (index == 62) {
                label = ">";
            } else if (index == 63) {
                label = "?";
            } else if (index == 59) {
                label = ";";
            } else if (index == 39) {
                label = "\'";
            } else if (index == 34) {
                label ="\"";
            } else if (index == 58) {
                label = ":";
            } else {
                label = _("Empty");
            }
            return label;
        }

        public static int get_note_from_keycode (uint key) {
            for (int i = 0; i < 60; i++) {
                if (key_bindings[i] == key) {
                    return i;
                }
            }

            return -1;
        }

        public static void save_mapping (Settings settings, GLib.File? csv_file = null) {
            string[] array = new string[60];
            string[,] csv_data = new string[1, 60];

            for (int i = 0; i < 60; i++) {
                array[i] = key_bindings[i].to_string ();
                csv_data[0, i] = array[i];
            }

            settings.set_strv ("pc-input-maps", array);

            if (csv_file != null) {
                Utils.save_csv (csv_file, csv_data);
            }
        }

        public static void load_mapping (Settings settings, GLib.File? csv_file = null) {
            key_bindings = new KeyMap[60];
            var binds = new string[60];
            if (csv_file != null) {
                string[,] csv_data;
                Utils.read_csv (csv_file, out csv_data);
                for (int i = 0; i < 60; i++) {
                    binds[i] = csv_data[0, i];
                }

                settings.set_strv ("pc-input-maps", binds);
            } else {
                binds = settings.get_strv ("pc-input-maps");
            }

            if (binds.length == 60) {
                try {
                    for (int i = 0; i < 60; i++) {
                        key_bindings[i] = KeyMap.parse (binds[i]);
                    }
                } catch (Error e) {
                    print ("Failed To get bindings: %s\n", e.message);
                    for (int i = 0; i < 60; i++){
                        key_bindings[i] = KeyMap.NONE;
                    }
                }
            } else {
                for (int i = 0; i < 60; i++){
                    key_bindings[i] = KeyMap.NONE;
                }
            }
        }
    }
}
