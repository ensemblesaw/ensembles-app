namespace Ensembles.Shell { 
    public class DeviceItem : Gtk.ListBoxRow {
        public Ensembles.Core.ControllerDevice device;
        Gtk.Label device_name;
        public Gtk.CheckButton radio;
        public DeviceItem(Ensembles.Core.ControllerDevice device) {
            this.device = device;
            device_name = new Gtk.Label (this.device.name);
            radio = new Gtk.CheckButton ();
            radio.margin_end = 8;
            radio.set_active (false);
            radio.set_sensitive (false);
    
            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            box.margin = 8;
            box.halign = Gtk.Align.START;
    
            box.pack_start (radio);
            box.pack_start (device_name);
            this.add (box);
        }
    }
}