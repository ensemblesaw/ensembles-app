namespace Ensembles.Shell { 
    public class EqualizerBar : Gtk.Bin {
        //  DrawingArea drawing_area;
        private int _velocity;
        public int velocity {
            get {
                return _velocity;
            }
            set {
                _velocity = 127 - value;
                queue_draw ();
            }
        } 
        public EqualizerBar () {
            set_size_request (18, 40);
            velocity = 0;
        }

        public override bool draw (Cairo.Context cr) {
            cr.move_to (0, 0);
            cr.set_source_rgba (0.6, 0.6, 0.6, 0.2);
            for (int i = 0; i < 7; i++) {
                cr.rectangle (0, i*5, 18, 4);
            }
            cr.fill ();
            cr.set_source_rgba (0.42, 0.56, 0.015, 1);
            for (int i = 6; i >= 0; i--) {
                cr.rectangle (0, i*5, 18, 4);
                if (i * 16 < _velocity) {
                    break;
                }
                cr.fill ();
            }

            return base.draw (cr);
        }
    }
}