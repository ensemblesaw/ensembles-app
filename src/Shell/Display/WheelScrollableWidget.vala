namespace Ensembles.Shell { 
    public class WheelScrollableWidget : Gtk.Grid { 
        public int scroll_wheel_location;
        public WheelScrollableWidget () {
            width_request = 424;
            height_request = 213;
        }
        public void scroll_wheel_scroll (bool direction, int amount) {
            if (direction) {
                scroll_wheel_location += amount;
            } else {
                scroll_wheel_location -= amount;
            }
        }
    }
}