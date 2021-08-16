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

            NAV_LEFT     = 65361,
            NAV_RIGHT    = 65363,
            NAV_UP       = 65362,
            NAV_DOWN     = 65364,

            RETURN       = 65293,
            RETURN_NUMPAD= 65421,
            ESCAPE       = 65307,
            SPACE_BAR    = 32,

            CTRL         = 65507
        }
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
    }
}
