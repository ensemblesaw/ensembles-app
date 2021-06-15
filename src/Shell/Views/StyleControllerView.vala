namespace Ensembles.Shell {
    public class StyleControllerView : Gtk.Grid {
        Gtk.Button intro_button_a;
        Gtk.Button intro_button_b;
        Gtk.Button var_fill_button_a;
        Gtk.Button var_fill_button_b;
        Gtk.Button var_fill_button_c;
        Gtk.Button var_fill_button_d;
        Gtk.Button break_button;
        Gtk.Button ending_button_a;
        Gtk.Button ending_button_b;
        Gtk.Button sync_start_button;
        Gtk.Button sync_stop_button;
        Gtk.Button start_button;

        public signal void start_stop ();

        public signal void switch_var_a ();
        public signal void switch_var_b ();
        public signal void switch_var_c ();
        public signal void switch_var_d ();

        public signal void queue_intro_a ();
        public signal void queue_intro_b ();

        public signal void queue_ending_a ();
        public signal void queue_ending_b ();

        public signal void break_play ();

        public signal void sync_stop ();
        public signal void sync_start ();

        public StyleControllerView () {
            var intro_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            intro_button_a = new Gtk.Button.with_label ("1");
            intro_button_b = new Gtk.Button.with_label ("2");
            intro_box.add(intro_button_a);
            intro_box.add(intro_button_b);
            intro_box.set_layout (Gtk.ButtonBoxStyle.EXPAND);
            intro_button_a.set_sensitive (false);
            intro_button_b.set_sensitive (false);
            intro_button_a.clicked.connect (() => {
                queue_intro_a ();
                intro_button_a.get_style_context ().add_class ("queue-measure");
                intro_button_b.get_style_context ().remove_class ("queue-measure");
                ending_button_a.get_style_context ().remove_class ("queue-measure");
                ending_button_b.get_style_context ().remove_class ("queue-measure");
            });
            intro_button_b.clicked.connect (() => {
                queue_intro_b ();
                intro_button_a.get_style_context ().remove_class ("queue-measure");
                intro_button_b.get_style_context ().add_class ("queue-measure");
                ending_button_a.get_style_context ().remove_class ("queue-measure");
                ending_button_b.get_style_context ().remove_class ("queue-measure");
            });

            var var_fill_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            var_fill_button_a = new Gtk.Button.with_label ("A");
            var_fill_button_b = new Gtk.Button.with_label ("B");
            var_fill_button_c = new Gtk.Button.with_label ("C");
            var_fill_button_d = new Gtk.Button.with_label ("D");
            var_fill_box.add(var_fill_button_a);
            var_fill_box.add(var_fill_button_b);
            var_fill_box.add(var_fill_button_c);
            var_fill_box.add(var_fill_button_d);
            var_fill_box.set_layout (Gtk.ButtonBoxStyle.EXPAND);
            var_fill_button_a.set_sensitive (false);
            var_fill_button_b.set_sensitive (false);
            var_fill_button_c.set_sensitive (false);
            var_fill_button_d.set_sensitive (false);
            var_fill_button_a.clicked.connect (() => {
                switch_var_a ();
                var_fill_button_a.get_style_context ().add_class ("queue-measure");
                var_fill_button_b.get_style_context ().remove_class ("queue-measure");
                var_fill_button_c.get_style_context ().remove_class ("queue-measure");
                var_fill_button_d.get_style_context ().remove_class ("queue-measure");
            });

            var_fill_button_b.clicked.connect (() => {
                switch_var_b ();
                var_fill_button_a.get_style_context ().remove_class ("queue-measure");
                var_fill_button_b.get_style_context ().add_class ("queue-measure");
                var_fill_button_c.get_style_context ().remove_class ("queue-measure");
                var_fill_button_d.get_style_context ().remove_class ("queue-measure");
            });

            var_fill_button_c.clicked.connect (() => {
                switch_var_c ();
                var_fill_button_a.get_style_context ().remove_class ("queue-measure");
                var_fill_button_b.get_style_context ().remove_class ("queue-measure");
                var_fill_button_c.get_style_context ().add_class ("queue-measure");
                var_fill_button_d.get_style_context ().remove_class ("queue-measure");
            });

            var_fill_button_d.clicked.connect (() => {
                switch_var_d ();
                var_fill_button_a.get_style_context ().remove_class ("queue-measure");
                var_fill_button_b.get_style_context ().remove_class ("queue-measure");
                var_fill_button_c.get_style_context ().remove_class ("queue-measure");
                var_fill_button_d.get_style_context ().add_class ("queue-measure");
            });

            break_button = new Gtk.Button.with_label ("Break");
            break_button.set_sensitive (false);
            break_button.clicked.connect (() => {
                break_play ();
            });

            var ending_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            ending_button_a = new Gtk.Button.with_label ("1");
            ending_button_b = new Gtk.Button.with_label ("2");
            ending_button_a.set_sensitive (false);
            ending_button_b.set_sensitive (false);
            ending_box.add(ending_button_a);
            ending_box.add(ending_button_b);
            ending_box.set_layout (Gtk.ButtonBoxStyle.EXPAND);
            ending_button_a.clicked.connect (() => {
                queue_ending_a ();
                ending_button_a.get_style_context ().add_class ("queue-measure");
                ending_button_b.get_style_context ().remove_class ("queue-measure");
                intro_button_a.get_style_context ().remove_class ("queue-measure");
                intro_button_b.get_style_context ().remove_class ("queue-measure");
            });
            ending_button_b.clicked.connect (() => {
                queue_ending_b ();
                ending_button_a.get_style_context ().remove_class ("queue-measure");
                ending_button_b.get_style_context ().add_class ("queue-measure");
                intro_button_a.get_style_context ().remove_class ("queue-measure");
                intro_button_b.get_style_context ().remove_class ("queue-measure");
            });

            var sync_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            sync_start_button = new Gtk.Button.with_label ("Sync Start");
            sync_stop_button = new Gtk.Button.with_label ("Sync Stop");
            sync_start_button.set_sensitive (false);
            sync_stop_button.set_sensitive (false);
            sync_box.add(sync_start_button);
            sync_box.add(sync_stop_button);
            sync_box.set_layout (Gtk.ButtonBoxStyle.EXPAND);
            sync_start_button.clicked.connect (() => {
                sync_start_button.get_style_context ().add_class ("queue-measure");
                sync_start ();
            });
            sync_stop_button.clicked.connect (() => {
                sync_stop_button.get_style_context ().add_class ("queue-measure");
                sync_stop ();
            });

            start_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic");
            start_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            start_button.get_style_context ().remove_class ("image-button");
            start_button.width_request = 64;
            start_button.set_sensitive (false);
            start_button.clicked.connect (() => {
                start_stop ();
            });

            var intro_label = new Gtk.Label ("       INTRO       ");
            intro_label.set_opacity (0.3);
            var var_label = new Gtk.Label ("       VARIATION / FILL-IN       ");
            var_label.set_opacity (0.3);
            var ending_label = new Gtk.Label ("     ENDING     ");
            ending_label.set_opacity (0.3);

            this.attach (intro_box, 0, 0, 1, 1);
            this.attach (var_fill_box, 1, 0, 1, 1);
            this.attach (break_button, 2, 0, 1, 1);
            this.attach (ending_box, 3, 0, 1, 1);
            this.attach (sync_box, 4, 0, 1, 1);
            this.attach (start_button, 5, 0, 1, 1);
            
            this.attach (intro_label, 0, 1, 1, 1);
            this.attach (var_label, 1, 1, 1, 1);
            this.attach (ending_label, 3, 1, 1, 1);
            this.column_spacing = 4;
            this.margin = 8;
        }
        public void ready () {
            intro_button_a.set_sensitive (true);
            intro_button_b.set_sensitive (true);
            var_fill_button_a.set_sensitive (true);
            var_fill_button_b.set_sensitive (true);
            var_fill_button_c.set_sensitive (true);
            var_fill_button_d.set_sensitive (true);
            ending_button_a.set_sensitive (true);
            ending_button_b.set_sensitive (true);
            sync_start_button.set_sensitive (true);
            sync_stop_button.set_sensitive (true);
            start_button.set_sensitive (true);
            break_button.set_sensitive (true);
        }
        public void sync () {
            intro_button_a.get_style_context ().remove_class ("queue-measure");
            intro_button_b.get_style_context ().remove_class ("queue-measure");
            var_fill_button_a.get_style_context ().remove_class ("queue-measure");
            var_fill_button_b.get_style_context ().remove_class ("queue-measure");
            var_fill_button_c.get_style_context ().remove_class ("queue-measure");
            var_fill_button_d.get_style_context ().remove_class ("queue-measure");
            ending_button_a.get_style_context ().remove_class ("queue-measure");
            ending_button_b.get_style_context ().remove_class ("queue-measure");
            sync_start_button.get_style_context ().remove_class ("queue-measure");
            sync_stop_button.get_style_context ().remove_class ("queue-measure");
        }
        public void set_style_section (int section) {
            sync ();
            switch (section) {
                case 0:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case 1:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case 2:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case 3:
                var_fill_button_a.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case 5:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case 7:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case 9:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case 11:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
                case 13:
                var_fill_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_c.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                var_fill_button_d.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                intro_button_b.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_a.get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                ending_button_b.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                break;
            }
        }
    }
}