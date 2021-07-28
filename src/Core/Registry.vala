namespace Ensembles.Core {
    public class Registry : Object {
        public int voice_r1;
        public int voice_r2;
        public int voice_l;
        public int style;
        public int tempo;
        public int transpose;
        public bool transpose_on;
        public int octave;
        public bool octave_shift_on;
        public int reverb_level;
        public bool reverb_on;
        public int chorus_level;
        public bool chorus_on;
        public bool accomp_on;
        public bool layer_on;
        public bool split_on;
        public int harmonizer_type;
        public bool harmonizer_on;
        public int arpeggiator_type;
        public bool arpeggiator_on;

        public Registry (int voice_r1,
                         int voice_r2,
                         int voice_l,
                         int style,
                         int tempo,
                         int transpose,
                         bool transpose_on,
                         int octave,
                         bool octave_shift_on,
                         int reverb_level,
                         bool reverb_on,
                         int chorus_level,
                         bool chorus_on,
                         bool accomp_on,
                         bool layer_on,
                         bool split_on,
                         int harmonizer_type,
                         bool harmonizer_on,
                         int arpeggiator_type,
                         bool arpeggiator_on) {
            this.voice_r1 = voice_r1;
            this.voice_r2 = voice_r2;
            this.voice_l = voice_l;
            this.style = style;
            this.tempo = tempo;
            this.transpose = transpose;
            this.transpose_on = transpose_on;
            this.octave = octave;
            this.octave_shift_on = octave_shift_on;
            this.reverb_level = reverb_level;
            this.reverb_on = reverb_on;
            this.chorus_level = chorus_level;
            this.chorus_on = chorus_on;
            this.accomp_on = accomp_on;
            this.layer_on = layer_on;
            this.split_on = split_on;
            this.harmonizer_on = harmonizer_on;
            this.harmonizer_type = harmonizer_type;
            this.arpeggiator_on = arpeggiator_on;
            this.arpeggiator_type = arpeggiator_type;
        }
    }
}
