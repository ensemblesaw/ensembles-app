namespace Ensembles.PlugIns {
    public class PlugInAtom : Gtk.Grid {
        LV2.Atom.Atom* atom_value;
        Gtk.Label label;
        public PlugInAtom (AtomPort port, LV2.Atom.Atom* value) {
            atom_value = value;
            label = new Gtk.Label (port.name);
            label.width_chars = 15;
            label.margin = 8;
            label.xalign = 0;
            label.get_style_context ().add_class ("h3");
            attach (label, 0, 0);

            this.show_all ();
            this.width_request = 400;
            this.row_spacing = 4;
            this.get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
        }
    }
}
