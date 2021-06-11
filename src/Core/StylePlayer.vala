namespace Ensembles.Core { 
    public class StylePlayer : Object {
        public StylePlayer (string mid_file) {
            style_player_init (mid_file);
        }
        ~StylePlayer () {
            style_player_destruct ();
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
            style_player_queue_ending (12, 13);
        }

        public void break_play () {
            style_player_break ();
        }

        public void sync_stop () {
            style_player_sync_stop ();
        }
    }
}

extern void style_player_init (string mid_file);
extern void style_player_destruct ();
extern void style_player_play ();
extern void style_player_play_loop (int start, int end);
extern void style_player_queue_intro (int start, int end);
extern void style_player_queue_ending (int start, int end);
extern void style_player_break ();
extern void style_player_sync_stop ();