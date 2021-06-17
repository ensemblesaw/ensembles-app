namespace Ensembles.Shell { 
    public class SongControllerView : Gtk.Grid {
        Gtk.Button prev_button;
        Gtk.Button play_button;
        Gtk.Button next_button;

        public SongControllerView () {
            prev_button = new Gtk.Button.from_icon_name ("media-skip-backward-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            play_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            next_button = new Gtk.Button.from_icon_name ("media-skip-forward-symbolic", Gtk.IconSize.LARGE_TOOLBAR);

            attach (prev_button, 0, 0, 1, 1);
            attach (play_button, 1, 0, 1, 1);
            attach (next_button, 2, 0, 1, 1);

            margin_end = 8;

            this.show_all ();
        }
    }
}