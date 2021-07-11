namespace Ensembles.Core {
    public class MetronomeLFOPlayer {
        string _lfo_directory_location;
        int _time_signature_n;
        int _time_signature_d;
        string _lfo_file_location;
        int _tempo = 120;
        public bool looping;
        public MetronomeLFOPlayer (string lfo_directory_location) {
            _lfo_directory_location = lfo_directory_location;
            metronome_lfo_player_init ();
        }
        ~MetronomeLFOPlayer () {
            metronome_lfo_player_destruct ();
        }

        public void play_measure (int time_signature_n, int time_signature_d) {
            if (_time_signature_n != time_signature_n || _time_signature_d != time_signature_d) {
                _time_signature_n = time_signature_n;
                _time_signature_d = time_signature_d;
                _lfo_file_location = _lfo_directory_location + "/" + 
                                     time_signature_n.to_string () + "_" + 
                                     time_signature_d.to_string () + ".mtlfo";
                metronome_lfo_player_change_base (_lfo_file_location, _tempo, 1920);
            } else {
                metronome_lfo_player_play ();
            }
        }

        public void set_tempo (int tempo) {
            _tempo = tempo;
            metronome_lfo_player_set_tempo (_tempo);
        }

        public void play_loop (int time_signature_n, int time_signature_d) {
            if (!CentralBus.get_style_looping_on ()) {
                looping = true;
                play_measure (time_signature_n, time_signature_d);
                Timeout.add (240000/_tempo, () => {
                    metronome_lfo_player_play ();
                    return looping;
                });
            }
        }

        public void stop_loop () {
            looping = false;
        }
    }
}

extern void metronome_lfo_player_init ();
extern void metronome_lfo_player_destruct ();
extern void metronome_lfo_player_change_base (string mid_file, int tempo, int eol);
extern void metronome_lfo_player_play ();
extern void metronome_lfo_player_set_tempo (int tempo);