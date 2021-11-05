namespace Ensembles.Shell {
    public class LFOEditScreen : Gtk.Grid {
        public signal void close_screen ();
        Gtk.Label header;
        Gtk.SpinButton lfo_spin_button;
        Gtk.Label lfo_type;

        Gtk.Image lfo_graph;
        string[] lfo_names = {
            _("Disabled"),
            _("Sqr 2x (Inverse Phase)"),
            _("Square 4x"),
            _("Sqr 8x (Inverse Phase)"),
            _("Sine (Inverse Phase)"),
            _("Sin 2x (Inverse Phase)"),
            _("Sine 4x"),
            _("Sin 4x (Inverse Phase)"),
            _("Saw 2x"),
            _("Saw 4x"),
            _("Saw 4x (Inverse Phase)"),
            _("Triangular"),
            _("Triangular 2x"),
            _("Dance 1"),
            _("Dance 2"),
            _("Sine 4x (Damping)")
        };
        public LFOEditScreen () {
            set_size_request (424, 236);
            row_spacing = 8;
            get_style_context ().add_class ("channel-modulator-screen");

            var close_button = new Gtk.Button.from_icon_name ("window-close-symbolic", Gtk.IconSize.BUTTON);
            close_button.get_style_context ().add_class ("channel-modulator-close-button");
            close_button.clicked.connect (() => {
                close_screen ();
            });
            attach (close_button, 0, 0, 1, 1);

            header = new Gtk.Label (_("Select Master Knob LFO"));
            header.get_style_context ().add_class ("channel-modulator-header");
            header.halign = Gtk.Align.START;
            header.hexpand = true;
            attach (header, 1, 0, 1, 1);

            var mod_grid = new Gtk.Grid ();
            mod_grid.column_homogeneous = true;
            mod_grid.column_spacing = 6;
            mod_grid.get_style_context ().add_class ("channel-modulator-grid");

            lfo_type = new Gtk.Label (_("Disabled"));
            lfo_spin_button = new Gtk.SpinButton.with_range (0, 15, 1);
            lfo_type.vexpand = true;
            lfo_spin_button.vexpand = true;
            mod_grid.attach (lfo_spin_button, 0, 0, 1, 1);
            mod_grid.attach (lfo_type, 1, 0, 1, 1);

            lfo_graph = new Gtk.Image.from_resource ("/com/github/subhadeepjasu/ensembles/images/lfo_graphics/LFO_4_4_0");

            mod_grid.attach (lfo_graph, 0, 1, 2, 1);
            attach (mod_grid, 0, 1, 2, 1);
            show_all ();

            make_events ();
        }
        public void make_events () {
            lfo_spin_button.value_changed.connect (() => {
                int index = (int)(lfo_spin_button.value);
                lfo_graph.set_from_resource ("/com/github/subhadeepjasu/ensembles/images/lfo_graphics/LFO_4_4_" +
                                             index.to_string ());
                lfo_type.set_text (lfo_names[index]);
                Ensembles.Core.CentralBus.set_lfo_type (index);
            });
        }
    }
}
