namespace Ensembles.Shell {
    public class EffectRackScreen : WheelScrollableWidget {
        Gtk.Button close_button;
        Gtk.ListBox main_list;

        EffectItem[] effect_rows;

        int _selected_index;

        public signal void close_menu ();
        public EffectRackScreen () {
            this.get_style_context ().add_class ("menu-background");

            close_button = new Gtk.Button.from_icon_name ("application-exit-symbolic", Gtk.IconSize.BUTTON);
            close_button.margin_end = 4;
            close_button.halign = Gtk.Align.END;


            var headerbar = new Hdy.HeaderBar ();
            headerbar.set_title (_("Effect Rack"));
            headerbar.set_subtitle (_("Effects that are applied to the audio output"));
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
                _selected_index = index;
                scroll_wheel_location = index;
                open_ui (index);
            });
        }

        public void populate_effect_menu () {
            PlugIns.PlugIn[] plugins = Core.EffectRack.get_plugins ();
            print("Populating %d\n", plugins.length);
            effect_rows = new EffectItem [plugins.length];
            string temp_category = "";
            for (int i = 0; i < plugins.length; i++) {
                bool show_category = false;
                if (temp_category != plugins[i].class) {
                    temp_category = plugins[i].class;
                    show_category = true;
                }
                var row = new EffectItem (plugins[i], show_category);
                effect_rows[i] = row;
                main_list.insert (row, -1);
            }
            min_value = 0;
            max_value = effect_rows.length - 1;
            main_list.show_all ();
        }

        //  public void scroll_to_selected_row () {
        //      style_rows[_selected_index].grab_focus ();
        //      if (main_list != null) {
        //          var adj = main_list.get_adjustment ();
        //          if (adj != null) {
        //              int height, _htemp;
        //              style_rows[_selected_index].get_preferred_height (out _htemp, out height);
        //              Timeout.add (200, () => {
        //                  adj.set_value (_selected_index * height);
        //                  return false;
        //              });
        //          }
        //      }
        //  }

        public void scroll_wheel_activate () {
            close_menu ();
        }

        void open_ui (uint32 index) {
            Core.EffectRack.show_plugin_ui (index);
        }
    }
}
