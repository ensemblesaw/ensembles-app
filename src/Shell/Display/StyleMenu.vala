namespace Ensembles.Shell { 
    public class StyleMenu : WheelScrollableWidget {
        Gtk.Button close_button;
        Gtk.ListBox main_list;
        string[] style_path;
        string[] style_genre;
        string[] style_name;
        int[]    style_tempo;
        Gtk.ListBoxRow[] rows;

        public signal void close_menu ();
        public signal void change_style (string path, string name, int tempo);
        public StyleMenu() {
            this.get_style_context ().add_class ("menu-background");

            close_button = new Gtk.Button.from_icon_name ("application-exit-symbolic", Gtk.IconSize.BUTTON);
            close_button.margin_end = 4;
            close_button.halign = Gtk.Align.END;


            var headerbar = new Hdy.HeaderBar ();
            headerbar.set_title ("Style");
            headerbar.set_subtitle ("Pick a Rhythm to accompany you");
            headerbar.get_style_context ().add_class ("menu-header");
            headerbar.pack_start (close_button);
            main_list = new Gtk.ListBox ();
            main_list.get_style_context ().add_class ("menu-box");

            var scrollable = new Gtk.ScrolledWindow (null, null);
            scrollable.hexpand = true;
            scrollable.vexpand = true;
            scrollable.margin = 8;
            scrollable.add (main_list);

            this.attach (headerbar, 0, 0, 1, 1);
            this.attach (scrollable, 0, 1, 1, 1);


            close_button.clicked.connect (() => {
                close_menu ();
            });

            main_list.set_selection_mode (Gtk.SelectionMode.BROWSE);
            main_list.row_activated.connect ((row) => {
                int index = row.get_index ();

                change_style (style_path[index], style_name [index], style_tempo[index]);
            });
        }

        public void populate_style_menu (string[] paths, string[] names, string[] genre, int[] tempo) {
            style_path = paths;
            style_name = names;
            style_genre = genre;
            style_tempo = tempo;
            rows = new Gtk.ListBoxRow [style_path.length];

            string temp_genre = "";
            for (int i = 0; i < style_path.length; i++) {
                var style_label = new Gtk.Label (style_name[i]);
                style_label.get_style_context ().add_class ("menu-item-label");
                style_label.halign = Gtk.Align.START;
                style_label.hexpand = true;
                var tempo_label = new Gtk.Label ("♩ = " + style_tempo[i].to_string ());
                tempo_label.get_style_context ().add_class ("menu-item-description");
                tempo_label.halign = Gtk.Align.END;
                var genre_label = new Gtk.Label ("");
                var style_grid = new Gtk.Grid ();
                if (temp_genre != style_genre[i]) {
                    temp_genre = style_genre[i];
                    genre_label.set_text (temp_genre);
                    genre_label.get_style_context ().add_class ("menu-item-annotation");
                }
                style_grid.attach (style_label, 0, 0, 1, 2);
                style_grid.attach (genre_label, 1, 0, 1, 1);
                style_grid.attach (tempo_label, 1, 1, 1, 1);
                var row = new Gtk.ListBoxRow ();
                row.add (style_grid);
                rows[i] = row;
                main_list.insert (row, -1);
            }
            main_list.select_row (rows[0]);
            main_list.show_all ();
            Ensembles.Core.CentralBus.set_styles_ready (true);
        }
    }
}