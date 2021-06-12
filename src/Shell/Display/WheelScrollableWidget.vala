namespace Ensembles.Shell { 
    public class WheelScrollableWidget : Gtk.Grid { 
        public int scroll_wheel_location;
        public WheelScrollableWidget () {
            width_request = 424;
            height_request = 213;
        }
        public void scroll_wheel_scroll (int scroll_location) {
            scroll_wheel_location = scroll_location;
        }
    }
}