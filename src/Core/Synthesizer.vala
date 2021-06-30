namespace Ensembles.Core { 
    public class Synthesizer : Object {
        public Synthesizer (string soundfont) {
            synthesizer_init (soundfont);
        }

        ~Synthesizer () {
            synthesizer_destruct ();
        }

        public signal void detected_chord (int chord_main, int type);

        public void send_notes_realtime (int key, int on, int velocity) {
            int chord_type = 0;
            int chord_feedback = synthesizer_send_notes (key, on, velocity, out chord_type);
            if (chord_feedback > -6) {
                //print("chord: %d %d\n", chord_feedback, chord_type);
                detected_chord (chord_feedback, chord_type);
            }
        }

        public void set_accompaniment_on (bool active) {
            synthesizer_set_accomp_enable (active ? 1 : 0);
            if (!active) synthesizer_halt_notes ();
        }

        public void set_master_reverb_level (int level) {
            synthesizer_edit_master_reverb (level);
        }

        public void set_master_chorus_level (int level) {
            synthesizer_edit_master_chorus (level);
        }

        public void change_voice (Voice voice, int channel) {
            synthesizer_change_voice (voice.bank, voice.preset, channel);
        }

        public void set_modulator_value (int synth_index, int channel, int modulator, int value) {
            synthesizer_change_modulator (synth_index, channel, modulator, value);
        }

        public static int get_modulator_value (int synth_index, int channel, int modulator) {
            return synthesizer_get_modulator_values (synth_index, channel, modulator);
        }

        public static void lock_gain (int channel) {
            set_gain_value (channel, -1);
        }
    }
}

extern void synthesizer_init (string loc);
extern void synthesizer_destruct ();
extern int  synthesizer_send_notes (int key, int on, int velocity, out int type);
extern void synthesizer_halt_notes ();

extern void synthesizer_set_accomp_enable (int on);


extern void synthesizer_edit_master_reverb (int level);
extern void synthesizer_edit_master_chorus (int level);

extern void synthesizer_change_voice (int bank, int preset, int channel);

extern void synthesizer_change_modulator (int synth_index, int channel, int modulator, int value);
extern int  synthesizer_get_modulator_values (int synth_index, int channel, int modulator);
extern void set_gain_value (int channel, int value);