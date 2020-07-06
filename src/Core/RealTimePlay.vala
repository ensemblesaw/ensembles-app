namespace Ensembles.Core { 
    public class RealTimePlay {
        public RealTimePlay (string sound_font_location) {
            realtime_play_init (sound_font_location);
        }
        
        public void note_on () {
            realtime_play_key ();
        }
    }
}

extern void realtime_play_init (string loc);
extern void realtime_play_key ();