namespace Ensembles.Shell {
    public class PcKeyboardHandler : Object {
        bool[] key_activated;
        public signal void note_activate (int key, int on);
        public PcKeyboardHandler () {
            key_activated = new bool [16];
        }
        public void handle_keypress_event (uint keyval) {
            switch (keyval) {
                case KeyboardConstants.KeyMap.A_LOWER:
                if (!key_activated[0]) {
                    note_activate (60, 144);
                    key_activated[0] = true;
                }
                break;
                case KeyboardConstants.KeyMap.W_LOWER:
                if (!key_activated[1]) {
                    note_activate (61, 144);
                    key_activated[1] = true;
                }
                break;
                case KeyboardConstants.KeyMap.S_LOWER:
                if (!key_activated[2]) {
                    note_activate (62, 144);
                    key_activated[2] = true;
                }
                break;
                case KeyboardConstants.KeyMap.E_LOWER:
                if (!key_activated[3]) {
                    note_activate (63, 144);
                    key_activated[3] = true;
                }
                break;
                case KeyboardConstants.KeyMap.D_LOWER:
                if (!key_activated[4]) {
                    note_activate (64, 144);
                    key_activated[4] = true;
                }
                break;
                case KeyboardConstants.KeyMap.F_LOWER:
                if (!key_activated[5]) {
                    note_activate (65, 144);
                    key_activated[5] = true;
                }
                break;
                case KeyboardConstants.KeyMap.T_LOWER:
                if (!key_activated[6]) {
                    note_activate (66, 144);
                    key_activated[6] = true;
                }
                break;
                case KeyboardConstants.KeyMap.G_LOWER:
                if (!key_activated[7]) {
                    note_activate (67, 144);
                    key_activated[7] = true;
                }
                break;
                case KeyboardConstants.KeyMap.Y_LOWER:
                if (!key_activated[8]) {
                    note_activate (68, 144);
                    key_activated[8] = true;
                }
                break;
                case KeyboardConstants.KeyMap.H_LOWER:
                if (!key_activated[9]) {
                    note_activate (69, 144);
                    key_activated[9] = true;
                }
                break;
                case KeyboardConstants.KeyMap.U_LOWER:
                if (!key_activated[10]) {
                    note_activate (70, 144);
                    key_activated[10] = true;
                }
                break;
                case KeyboardConstants.KeyMap.J_LOWER:
                if (!key_activated[11]) {
                    note_activate (71, 144);
                    key_activated[11] = true;
                }
                break;
                case KeyboardConstants.KeyMap.K_LOWER:
                if (!key_activated[12]) {
                    note_activate (72, 144);
                    key_activated[12] = true;
                }
                break;
                case KeyboardConstants.KeyMap.O_LOWER:
                if (!key_activated[13]) {
                    note_activate (73, 144);
                    key_activated[13] = true;
                }
                break;
                case KeyboardConstants.KeyMap.L_LOWER:
                if (!key_activated[14]) {
                    note_activate (74, 144);
                    key_activated[14] = true;
                }
                break;
                case KeyboardConstants.KeyMap.P_LOWER:
                if (!key_activated[15]) {
                    note_activate (75, 144);
                    key_activated[15] = true;
                }
                break;
            }
        }

        public void handle_keyrelease_event (uint keyval) {
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
                note_activate (72, 128);
                key_activated[12] = false;
                break;
                case KeyboardConstants.KeyMap.O_LOWER:
                note_activate (73, 128);
                key_activated[13] = false;
                break;
                case KeyboardConstants.KeyMap.L_LOWER:
                note_activate (74, 128);
                key_activated[14] = false;
                break;
                case KeyboardConstants.KeyMap.P_LOWER:
                note_activate (75, 128);
                key_activated[15] = false;
                break;
            }
        }
    }
}
