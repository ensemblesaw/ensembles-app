namespace Ensembles.Shell { 
    public class OctaveKeyboard : Gtk.Grid {
        Key[] keys;
        public OctaveKeyboard() {
            keys = new Key[12];
            for (int i = 0; i < 12; i++) {
                keys[i] = new Key (((i == 1) || (i == 3) || (i == 6) || (i == 8) || (i == 10)) ? true : false);
            }

            var white_grid = new Gtk.Grid ();
            white_grid.attach (keys[0], 0, 0, 1, 1);
            white_grid.attach (keys[2], 1, 0, 1, 1);
            white_grid.attach (keys[4], 2, 0, 1, 1);
            white_grid.attach (keys[5], 3, 0, 1, 1);
            white_grid.attach (keys[7], 4, 0, 1, 1);
            white_grid.attach (keys[9], 5, 0, 1, 1);
            white_grid.attach (keys[11],6, 0, 1, 1);

            var black_grid = new Gtk.Grid ();
            black_grid.attach (keys[1], 0, 0, 1, 1);
            black_grid.attach (keys[3], 1, 0, 1, 1);
            black_grid.attach (keys[6], 2, 0, 1, 1);
            black_grid.attach (keys[8], 3, 0, 1, 1);
            black_grid.attach (keys[10],4, 0, 1, 1);
            keys[1].margin_start = 18;
            keys[1].margin_end = 5;
            keys[3].margin_start = 6;
            keys[3].margin_end = 14;
            keys[6].margin_start = 23;
            keys[6].margin_end = 10;
            keys[8].margin_end = 10;
            keys[10].margin_end = 18;
            black_grid.valign = Gtk.Align.START;

            var octave_overlay = new Gtk.Overlay ();
            octave_overlay.height_request = 168;
            octave_overlay.hexpand = true;
            octave_overlay.add_overlay (white_grid);
            octave_overlay.add_overlay (black_grid);

            attach (octave_overlay, 0, 0, 1, 1);
        }

        public void set_note_on (int key, bool on) {
            if (on) {
                keys[key].note_on ();
            } else {
                keys[key].note_off ();
            }
        }
    }
}