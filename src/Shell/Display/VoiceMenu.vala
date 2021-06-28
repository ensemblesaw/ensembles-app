namespace Ensembles.Shell { 
    public class VoiceMenu : WheelScrollableWidget {
        int channel;
        Gtk.Button close_button;
        Gtk.ListBox main_list;
        VoiceItem[] voice_rows;

        public signal void close_menu ();
        public VoiceMenu(int channel) {
            this.channel = channel;
            this.get_style_context ().add_class ("menu-background");

            close_button = new Gtk.Button.from_icon_name ("application-exit-symbolic", Gtk.IconSize.BUTTON);
            close_button.margin_right = 4;
            close_button.halign = Gtk.Align.END;


            var headerbar = new Hdy.HeaderBar ();
            headerbar.set_title ("Voice - " + ((channel == 0) ? "Right 1 (Main)" : (channel == 1) ? "Right 2 (Layered)" : "Left (Split)"));
            headerbar.set_subtitle ("Pick a Voice to play" + ((channel == 0) ? "" : (channel == 1) ? " on another layer" : " on left hand side of split"));
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
            });
        }

        public void populate_voice_menu (Ensembles.Core.Voice[] voices) {
            voice_rows = new VoiceItem [voices.length];
            string temp_category = "";
            for (int i = 0; i < voices.length; i++) {
                bool show_category = false;
                if (temp_category != voices[i].category) {
                    temp_category = voices[i].category;
                    show_category = true;
                }
                var row = new VoiceItem (voices[i], show_category);
                voice_rows[i] = row;
                main_list.insert (row, -1);
            }
            switch (channel) {
                case 0:
                main_list.select_row (voice_rows[0]);
                break;
                case 1:
                main_list.select_row (voice_rows[49]);
                break;
                case 2:
                main_list.select_row (voice_rows[33]);
                break;
            }
            main_list.show_all ();
        }
    }
}