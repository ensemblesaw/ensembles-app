namespace Ensembles.Core { 
    public class StylePlayer : Object {
        public StylePlayer (string? style_file = null) {
            style_player_init ();
            if (style_file != null) {
                style_player_add_style_file (style_file, 0);
            }
        }
        ~StylePlayer () {
            style_player_destruct ();
        }

        public void add_style_file (string style_file) {
            print ("loading style %s\n", style_file);
            style_player_add_style_file (style_file, 0);
        }

        public void reload_style () {
            style_player_reload_style ();
        }

        public void play_style () {
            style_player_play ();
        }

        public void switch_var_a() {
            style_player_play_loop (3, 4);
        }

        public void switch_var_b() {
            style_player_play_loop (5, 6);
        }

        public void switch_var_c() {
            style_player_play_loop (7, 8);
        }

        public void switch_var_d() {
            style_player_play_loop (9, 10);
        }

        public void queue_intro_a () {
            style_player_queue_intro (1, 2);
        }

        public void queue_intro_b () {
            style_player_queue_intro (2, 3);
        }

        public void queue_ending_a () {
            style_player_queue_ending (11, 12);
        }

        public void queue_ending_b () {
            style_player_queue_ending (13, 14);
        }

        public void break_play () {
            style_player_break ();
        }

        public void sync_start () {
            style_player_sync_start ();
        }
        public void sync_stop () {
            style_player_sync_stop ();
        }

        public void change_chords (int chord_main, int chord_type) {
            style_player_change_chord (chord_main, chord_type);
        }
    }
}

extern void style_player_init ();
extern void style_player_add_style_file (string mid_file, int reload);
extern void style_player_reload_style ();
extern void style_player_destruct ();
extern void style_player_play ();
extern void style_player_play_loop (int start, int end);
extern void style_player_queue_intro (int start, int end);
extern void style_player_queue_ending (int start, int end);
extern void style_player_break ();
extern void style_player_sync_start ();
extern void style_player_sync_stop ();

extern void style_player_change_chord (int cd_main, int cd_type);