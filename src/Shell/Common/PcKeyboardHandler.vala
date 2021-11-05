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
            key_activated = new bool [40];
        }
        public bool handle_keypress_event (uint keyval) {
            switch (keyval) {
                case KeyboardConstants.KeyMap.A_LOWER:
                if (!key_activated[0]) {
                    note_activate (60, 144);
                    key_activated[0] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.W_LOWER:
                if (!key_activated[1]) {
                    note_activate (61, 144);
                    key_activated[1] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.S_LOWER:
                if (!key_activated[2]) {
                    note_activate (62, 144);
                    key_activated[2] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.E_LOWER:
                if (!key_activated[3]) {
                    note_activate (63, 144);
                    key_activated[3] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.D_LOWER:
                if (!key_activated[4]) {
                    note_activate (64, 144);
                    key_activated[4] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.F_LOWER:
                if (!key_activated[5]) {
                    note_activate (65, 144);
                    key_activated[5] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.T_LOWER:
                if (!key_activated[6]) {
                    note_activate (66, 144);
                    key_activated[6] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.G_LOWER:
                if (!key_activated[7]) {
                    note_activate (67, 144);
                    key_activated[7] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.Y_LOWER:
                if (!key_activated[8]) {
                    note_activate (68, 144);
                    key_activated[8] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.H_LOWER:
                if (!key_activated[9]) {
                    note_activate (69, 144);
                    key_activated[9] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.U_LOWER:
                if (!key_activated[10]) {
                    note_activate (70, 144);
                    key_activated[10] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.J_LOWER:
                if (!key_activated[11]) {
                    note_activate (71, 144);
                    key_activated[11] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.K_LOWER:
                case KeyboardConstants.KeyMap.A_UPPER:
                if (!key_activated[12]) {
                    note_activate (72, 144);
                    key_activated[12] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.O_LOWER:
                case KeyboardConstants.KeyMap.W_UPPER:
                if (!key_activated[13]) {
                    note_activate (73, 144);
                    key_activated[13] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.L_LOWER:
                case KeyboardConstants.KeyMap.S_UPPER:
                if (!key_activated[14]) {
                    note_activate (74, 144);
                    key_activated[14] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.P_LOWER:
                case KeyboardConstants.KeyMap.E_UPPER:
                if (!key_activated[15]) {
                    note_activate (75, 144);
                    key_activated[15] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.D_UPPER:
                if (!key_activated[16]) {
                    note_activate (76, 144);
                    key_activated[16] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.F_UPPER:
                if (!key_activated[17]) {
                    note_activate (77, 144);
                    key_activated[17] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.T_UPPER:
                if (!key_activated[18]) {
                    note_activate (78, 144);
                    key_activated[18] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.G_UPPER:
                if (!key_activated[19]) {
                    note_activate (79, 144);
                    key_activated[19] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.Y_UPPER:
                if (!key_activated[20]) {
                    note_activate (80, 144);
                    key_activated[20] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.H_UPPER:
                if (!key_activated[21]) {
                    note_activate (81, 144);
                    key_activated[21] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.U_UPPER:
                if (!key_activated[22]) {
                    note_activate (82, 144);
                    key_activated[22] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.J_UPPER:
                if (!key_activated[23]) {
                    note_activate (83, 144);
                    key_activated[23] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.K_UPPER:
                if (!key_activated[24]) {
                    note_activate (84, 144);
                    key_activated[24] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.O_UPPER:
                if (!key_activated[25]) {
                    note_activate (85, 144);
                    key_activated[25] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.L_UPPER:
                if (!key_activated[26]) {
                    note_activate (86, 144);
                    key_activated[26] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.P_UPPER:
                if (!key_activated[27]) {
                    note_activate (87, 144);
                    key_activated[27] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.Z_LOWER:
                if (!key_activated[28]) {
                    note_activate (36, 144);
                    key_activated[28] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.X_LOWER:
                if (!key_activated[29]) {
                    note_activate (37, 144);
                    key_activated[29] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.C_LOWER:
                if (!key_activated[30]) {
                    note_activate (38, 144);
                    key_activated[30] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.V_LOWER:
                if (!key_activated[31]) {
                    note_activate (39, 144);
                    key_activated[31] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.B_LOWER:
                if (!key_activated[32]) {
                    note_activate (40, 144);
                    key_activated[32] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.N_LOWER:
                if (!key_activated[33]) {
                    note_activate (41, 144);
                    key_activated[33] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.M_LOWER:
                if (!key_activated[34]) {
                    note_activate (42, 144);
                    key_activated[34] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.KEYPAD_RADIX:
                if (!key_activated[35]) {
                    note_activate (44, 144);
                    key_activated[35] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.KEYPAD_COMMA:
                if (!key_activated[36]) {
                    note_activate (43, 144);
                    key_activated[36] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.SLASH_KEYPAD:
                if (!key_activated[37]) {
                    note_activate (45, 144);
                    key_activated[37] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.SQ_BRACKETS_L:
                if (!key_activated[38]) {
                    note_activate (46, 144);
                    key_activated[38] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.SQ_BRACKETS_R:
                if (!key_activated[39]) {
                    note_activate (47, 144);
                    key_activated[39] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.Z_UPPER:
                if (!key_activated[28]) {
                    note_activate (36, 144);
                    key_activated[28] = true;
                }
                if (!key_activated[31]) {
                    note_activate (39, 144);
                    key_activated[31] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.X_UPPER:
                if (!key_activated[29]) {
                    note_activate (37, 144);
                    key_activated[29] = true;
                }
                if (!key_activated[32]) {
                    note_activate (40, 144);
                    key_activated[32] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.C_UPPER:
                if (!key_activated[30]) {
                    note_activate (38, 144);
                    key_activated[30] = true;
                }
                if (!key_activated[33]) {
                    note_activate (41, 144);
                    key_activated[33] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.V_UPPER:
                if (!key_activated[31]) {
                    note_activate (39, 144);
                    key_activated[31] = true;
                }
                if (!key_activated[34]) {
                    note_activate (42, 144);
                    key_activated[34] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.B_UPPER:
                if (!key_activated[32]) {
                    note_activate (40, 144);
                    key_activated[32] = true;
                }
                if (!key_activated[35]) {
                    note_activate (43, 144);
                    key_activated[35] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.N_UPPER:
                if (!key_activated[33]) {
                    note_activate (41, 144);
                    key_activated[33] = true;
                }
                if (!key_activated[36]) {
                    note_activate (44, 144);
                    key_activated[36] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.M_UPPER:
                if (!key_activated[34]) {
                    note_activate (42, 144);
                    key_activated[34] = true;
                }
                if (!key_activated[37]) {
                    note_activate (45, 144);
                    key_activated[37] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.LT:
                if (!key_activated[35]) {
                    note_activate (43, 144);
                    key_activated[35] = true;
                }
                if (!key_activated[38]) {
                    note_activate (46, 144);
                    key_activated[38] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.GT:
                if (!key_activated[36]) {
                    note_activate (44, 144);
                    key_activated[36] = true;
                }
                if (!key_activated[39]) {
                    note_activate (47, 144);
                    key_activated[39] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.QUESTION:
                if (!key_activated[37]) {
                    note_activate (45, 144);
                    key_activated[38] = true;
                }
                if (!key_activated[40]) {
                    note_activate (48, 144);
                    key_activated[41] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.FL_BRACKETS_L:
                if (!key_activated[38]) {
                    note_activate (46, 144);
                    key_activated[38] = true;
                }
                if (!key_activated[41]) {
                    note_activate (49, 144);
                    key_activated[41] = true;
                }
                return false;
                case KeyboardConstants.KeyMap.FL_BRACKETS_R:
                if (!key_activated[39]) {
                    note_activate (47, 144);
                    key_activated[39] = true;
                }
                if (!key_activated[42]) {
                    note_activate (50, 144);
                    key_activated[42] = true;
                }
                return false;
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
            return false;
        }

        public void handle_keyrelease_event (uint keyval) {
            print ("%u\n", keyval);
            switch (keyval) {
                case KeyboardConstants.KeyMap.A_LOWER:
                note_activate (60, 128);
                key_activated[0] = false;
                break;
                case KeyboardConstants.KeyMap.W_LOWER:
                note_activate (61, 128);
                key_activated[1] = false;
                break;
                case KeyboardConstants.KeyMap.S_LOWER:
                note_activate (62, 128);
                key_activated[2] = false;
                break;
                case KeyboardConstants.KeyMap.E_LOWER:
                note_activate (63, 128);
                key_activated[3] = false;
                break;
                case KeyboardConstants.KeyMap.D_LOWER:
                note_activate (64, 128);
                key_activated[4] = false;
                break;
                case KeyboardConstants.KeyMap.F_LOWER:
                note_activate (65, 128);
                key_activated[5] = false;
                break;
                case KeyboardConstants.KeyMap.T_LOWER:
                note_activate (66, 128);
                key_activated[6] = false;
                break;
                case KeyboardConstants.KeyMap.G_LOWER:
                note_activate (67, 128);
                key_activated[7] = false;
                break;
                case KeyboardConstants.KeyMap.Y_LOWER:
                note_activate (68, 128);
                key_activated[8] = false;
                break;
                case KeyboardConstants.KeyMap.H_LOWER:
                note_activate (69, 128);
                key_activated[9] = false;
                break;
                case KeyboardConstants.KeyMap.U_LOWER:
                note_activate (70, 128);
                key_activated[10] = false;
                break;
                case KeyboardConstants.KeyMap.J_LOWER:
                note_activate (71, 128);
                key_activated[11] = false;
                break;
                case KeyboardConstants.KeyMap.K_LOWER:
                case KeyboardConstants.KeyMap.A_UPPER:
                note_activate (72, 128);
                key_activated[12] = false;
                break;
                case KeyboardConstants.KeyMap.O_LOWER:
                case KeyboardConstants.KeyMap.W_UPPER:
                note_activate (73, 128);
                key_activated[13] = false;
                break;
                case KeyboardConstants.KeyMap.L_LOWER:
                case KeyboardConstants.KeyMap.S_UPPER:
                note_activate (74, 128);
                key_activated[14] = false;
                break;
                case KeyboardConstants.KeyMap.P_LOWER:
                case KeyboardConstants.KeyMap.E_UPPER:
                note_activate (75, 128);
                key_activated[15] = false;
                break;
                case KeyboardConstants.KeyMap.D_UPPER:
                note_activate (76, 128);
                key_activated[16] = false;
                break;
                case KeyboardConstants.KeyMap.F_UPPER:
                note_activate (77, 128);
                key_activated[17] = false;
                break;
                case KeyboardConstants.KeyMap.T_UPPER:
                note_activate (78, 128);
                key_activated[18] = false;
                break;
                case KeyboardConstants.KeyMap.G_UPPER:
                note_activate (79, 128);
                key_activated[19] = false;
                break;
                case KeyboardConstants.KeyMap.Y_UPPER:
                note_activate (80, 128);
                key_activated[20] = false;
                break;
                case KeyboardConstants.KeyMap.H_UPPER:
                note_activate (81, 128);
                key_activated[21] = false;
                break;
                case KeyboardConstants.KeyMap.U_UPPER:
                note_activate (82, 128);
                key_activated[22] = false;
                break;
                case KeyboardConstants.KeyMap.J_UPPER:
                note_activate (83, 128);
                key_activated[23] = false;
                break;
                case KeyboardConstants.KeyMap.K_UPPER:
                note_activate (84, 128);
                key_activated[24] = false;
                break;
                case KeyboardConstants.KeyMap.O_UPPER:
                note_activate (85, 128);
                key_activated[25] = false;
                break;
                case KeyboardConstants.KeyMap.L_UPPER:
                note_activate (86, 128);
                key_activated[26] = false;
                break;
                case KeyboardConstants.KeyMap.P_UPPER:
                note_activate (87, 128);
                key_activated[27] = false;
                break;
                case KeyboardConstants.KeyMap.Z_LOWER:
                note_activate (36, 128);
                key_activated[28] = false;
                break;
                case KeyboardConstants.KeyMap.X_LOWER:
                note_activate (37, 128);
                key_activated[29] = false;
                break;
                case KeyboardConstants.KeyMap.C_LOWER:
                note_activate (38, 128);
                key_activated[30] = false;
                break;
                case KeyboardConstants.KeyMap.V_LOWER:
                note_activate (39, 128);
                key_activated[31] = false;
                break;
                case KeyboardConstants.KeyMap.B_LOWER:
                note_activate (40, 128);
                key_activated[32] = false;
                break;
                case KeyboardConstants.KeyMap.N_LOWER:
                note_activate (41, 128);
                key_activated[33] = false;
                break;
                case KeyboardConstants.KeyMap.M_LOWER:
                note_activate (42, 128);
                key_activated[34] = false;
                break;
                case KeyboardConstants.KeyMap.KEYPAD_RADIX:
                note_activate (44, 128);
                key_activated[35] = false;
                break;
                case KeyboardConstants.KeyMap.KEYPAD_COMMA:
                note_activate (43, 128);
                key_activated[36] = false;
                break;
                case KeyboardConstants.KeyMap.SLASH_KEYPAD:
                note_activate (45, 128);
                key_activated[37] = false;
                break;
                case KeyboardConstants.KeyMap.SQ_BRACKETS_L:
                note_activate (46, 128);
                key_activated[38] = false;
                break;
                case KeyboardConstants.KeyMap.SQ_BRACKETS_R:
                note_activate (47, 128);
                key_activated[39] = false;
                break;
                case KeyboardConstants.KeyMap.Z_UPPER:
                note_activate (36, 128);
                key_activated[28] = false;
                note_activate (39, 128);
                key_activated[31] = false;
                break;
                case KeyboardConstants.KeyMap.X_UPPER:
                note_activate (37, 128);
                key_activated[29] = false;
                note_activate (40, 128);
                key_activated[32] = false;
                break;
                case KeyboardConstants.KeyMap.C_UPPER:
                note_activate (38, 128);
                key_activated[30] = false;
                note_activate (41, 128);
                key_activated[33] = false;
                break;
                case KeyboardConstants.KeyMap.V_UPPER:
                note_activate (39, 128);
                key_activated[31] = false;
                note_activate (42, 128);
                key_activated[34] = false;
                break;
                case KeyboardConstants.KeyMap.B_UPPER:
                note_activate (40, 128);
                key_activated[32] = false;
                note_activate (43, 128);
                key_activated[35] = false;
                break;
                case KeyboardConstants.KeyMap.N_UPPER:
                note_activate (41, 128);
                key_activated[33] = false;
                note_activate (44, 128);
                key_activated[36] = false;
                break;
                case KeyboardConstants.KeyMap.M_UPPER:
                note_activate (42, 128);
                key_activated[34] = false;
                note_activate (45, 128);
                key_activated[37] = false;
                break;
                case KeyboardConstants.KeyMap.LT:
                note_activate (43, 128);
                key_activated[35] = false;
                note_activate (46, 128);
                key_activated[38] = false;
                break;
                case KeyboardConstants.KeyMap.GT:
                note_activate (44, 128);
                key_activated[36] = false;
                note_activate (47, 128);
                key_activated[39] = false;
                break;
                case KeyboardConstants.KeyMap.QUESTION:
                note_activate (45, 128);
                key_activated[38] = false;
                note_activate (48, 128);
                key_activated[41] = false;
                break;
                case KeyboardConstants.KeyMap.FL_BRACKETS_L:
                note_activate (46, 128);
                key_activated[38] = false;
                note_activate (49, 128);
                key_activated[41] = false;
                break;
                case KeyboardConstants.KeyMap.FL_BRACKETS_R:
                note_activate (47, 128);
                key_activated[39] = false;
                note_activate (50, 128);
                key_activated[42] = false;
                break;

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
