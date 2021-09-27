namespace Ensembles.Core {
    public class SongPlayer : Object {
        public enum PlayerStatus {
            READY,
            PLAYING,
            STOPPING,
            DONE
        }
        public int current_file_tempo = 30;
        public signal void player_status_changed (float fraction, int tempo_bpm, PlayerStatus status);
        bool monitoring_player = false;
        string sf_loc;

        public SongPlayer (string sf_loc, string midi_file_path) {
            this.sf_loc = sf_loc;
            music_player_init (sf_loc);
            current_file_tempo = music_player_load_file (midi_file_path);
            player_status_changed (0.0f, current_file_tempo, get_status ());
            start_monitoring ();
        }

        public void start_monitoring () {
            monitoring_player = true;
            debug ("Starting monitor");
            new Thread<int> ("monitor_player", monitor_player);
        }
        public void songplayer_destroy () {
            monitoring_player = false;
            music_player_destruct ();
        }

        public void play () {
            music_player_play ();
        }

        public void pause () {
            music_player_pause ();
        }

        public void seek (float seek_fraction) {
            music_player_seek ((int) (seek_fraction * total_ticks));
        }

        public void seek_lock (bool lock) {
            if (lock) {
                monitoring_player = false;
            } else {
                start_monitoring ();
            }
        }

        public void rewind () {
            pause ();
            seek (0.0f);
            play ();
        }

        public void set_repeat (bool enable) {
            player_repeat = enable ? 1 : 0;
        }

        public PlayerStatus get_status () {
            switch (music_player_get_status ()) {
                case 0:
                return PlayerStatus.READY;
                case 1:
                return PlayerStatus.PLAYING;
                case 2:
                return PlayerStatus.STOPPING;
            }
            return PlayerStatus.DONE;
        }

        private int monitor_player () {
            while (monitoring_player) {
                Idle.add (() => {
                    if (total_ticks > 0 && monitoring_player) {
                        player_status_changed ((float) current_ticks / (float) total_ticks, current_file_tempo, get_status ());
                    } else {
                        player_status_changed (0.0f, current_file_tempo, get_status ());
                    }
                    return false;
                });
                Thread.yield ();
                Thread.usleep (10000);
            }
            return 0;
        }
    }
}

extern void music_player_init (string sf_loc);
extern void music_player_destruct ();
extern int music_player_load_file (string path);
extern void music_player_play ();
extern void music_player_pause ();
extern void music_player_seek (int seek_point);
extern int music_player_get_status ();

extern int note_watch_channel;
extern int total_ticks;
extern int current_ticks;
extern int player_repeat;
