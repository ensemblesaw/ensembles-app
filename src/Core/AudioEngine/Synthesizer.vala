/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.AudioEngine {
    /**
     * ## Synthesizer
     *
     * The FluidSynth SoundFont™ Synthesizer forms the base audio engine for the
     * app.
     *
     * All midi events either from the midi players or from the plugins will be
     * to and from here.
     *
     * All sound from the plugins and samplers are also channel through this
     * synthesizer.
     */
    public class Synthesizer : Object {

        private bool _input_enabled = true;

        public bool input_enabled {
            get {
                return _input_enabled;
            }
            set {
                _input_enabled = value;
            }
        }

        public bool layer { get; set; }
        public bool split { get; set; }

        public static int64 processing_start_time;

        private static uint32 buffer_size;

        private Analysers.ChordAnalyser chord_analyser;
        private SynthSettingsPresets.StyleGainSettings style_gain_settings;
        private SynthSettingsPresets.ModulatorSettings modulator_settings;
        private unowned Fluid.Synth rendering_synth;

        public List<unowned Racks.Rack> racks;

        public static double sample_rate { get; private set; }

        private int soundfont_id;

        construct {
            chord_analyser = new Analysers.ChordAnalyser ();
            style_gain_settings = new SynthSettingsPresets.StyleGainSettings ();
            modulator_settings = new SynthSettingsPresets.ModulatorSettings ();
            racks = new List<unowned Racks.Rack> ();
        }

        public Synthesizer (SynthProvider synth_provider, string soundfont) throws FluidError {
            Console.log ("Initializing Synthesizer…");
            rendering_synth = synth_provider.rendering_synth;
            buffer_size = rendering_synth.get_internal_bufsize ();
            double sample_rate = 1;
            var s = rendering_synth.get_settings ();
            s.getnum ("synth.sample-rate", out sample_rate);
            Console.log ("Sample Rate: %0.1lf Hz".printf (sample_rate));
            Synthesizer.sample_rate = sample_rate;
            SynthProvider.synth_render_handler = process_audio;

            if (Fluid.is_soundfont (soundfont)) {
                soundfont_id = synth_provider.rendering_synth.sfload (soundfont, true);
                synth_provider.utility_synth.sfload (soundfont, true);

                // Initialize Voices
                rendering_synth.program_select (17, soundfont_id, 0, 0);
                rendering_synth.program_select (18, soundfont_id, 0, 49);
                rendering_synth.program_select (19, soundfont_id, 0, 33);

                // Initialize chord voices
                rendering_synth.program_select (20, soundfont_id, 0, 5);
                rendering_synth.program_select (21, soundfont_id, 0, 33);
                rendering_synth.program_select (22, soundfont_id, 0, 49);

                // Initialize metronome voice
                rendering_synth.program_select (16, soundfont_id, 128, 0);

                // Initialize intro chime voice
                rendering_synth.program_select (23, soundfont_id, 0, 96);
            } else {
                throw new FluidError.INVALID_SF (_("SoundFont from path: %s is either missing or invalid"), soundfont);
            }

            set_synth_defaults ();

            build_events ();
        }

        private void build_events () {
            Application.event_bus.style_midi_event.connect (handle_midi_event_from_player);
            Application.event_bus.synth_send_event.connect (handle_midi_event);
            Application.event_bus.synth_halt_notes.connect (halt_notes);
            Application.event_bus.synth_sounds_off.connect (stop_all_sounds);
            Application.event_bus.arranger_ready.connect (play_intro_sound);
            Application.event_bus.voice_chosen.connect ((hand_position, name, bank, preset) => {
                uint8 channel = 17;
                switch (hand_position) {
                    case VoiceHandPosition.LEFT:
                        channel = 19;
                        break;
                    case VoiceHandPosition.RIGHT_LAYERED:
                        channel = 18;
                        break;
                    default:
                        break;
                }

                rendering_synth.program_select (channel, soundfont_id, bank, preset);
            });
        }

        private void set_synth_defaults () {
            // CutOff for Realtime synth
            rendering_synth.cc (17, MIDI.Control.CUT_OFF, 40);
            rendering_synth.cc (18, MIDI.Control.CUT_OFF, 0);
            rendering_synth.cc (19, MIDI.Control.CUT_OFF, 0);

            // Reverb and Chorus for R1 voice
            rendering_synth.cc (17, MIDI.Control.REVERB, 100);
            rendering_synth.cc (17, MIDI.Control.CHORUS, 100);

            // Reverb and Chorus for intro tone
            rendering_synth.cc (23, MIDI.Control.REVERB, 127);
            rendering_synth.cc (23, MIDI.Control.CHORUS, 100);
            rendering_synth.cc (23, MIDI.Control.CUT_OFF, 40);
            rendering_synth.cc (23, MIDI.Control.RESONANCE, 80);

            // Reverb and Chorus for Metronome
            rendering_synth.cc (16, MIDI.Control.REVERB, 0);
            rendering_synth.cc (16, MIDI.Control.CHORUS, 0);

            // Default gain for Realtime synth
            rendering_synth.cc (17, MIDI.Control.GAIN, 100);
            rendering_synth.cc (18, MIDI.Control.GAIN, 90);
            rendering_synth.cc (19, MIDI.Control.GAIN, 80);


            // Default pitch of all synths
            for (int i = 17; i < 64; i++) {
                rendering_synth.cc (i, MIDI.Control.EXPLICIT_PITCH, 64);
            }

            // Default cut-off and resonance for recorder
            for (int i = 24; i < 64; i++) {
                rendering_synth.cc (i, MIDI.Control.CUT_OFF, 40);
                rendering_synth.cc (i, MIDI.Control.RESONANCE, 10);
            }

            // Default pitch for styles
            for (int i = 0; i < 16; i++) {
                rendering_synth.cc (i, MIDI.Control.EXPLICIT_PITCH, 64);
            }

            set_master_reverb_active (true);
            edit_master_reverb (8);

            set_master_chorus_active (true);
            edit_master_chorus (2);
        }

        private void play_intro_sound () {
            Timeout.add (200, () => {
                rendering_synth.noteon (23, 65, 110);
                return false;
            });

            Timeout.add (300, () => {
                rendering_synth.noteon (23, 60, 90);
                return false;
            });

            Timeout.add (400, () => {
                rendering_synth.noteon (23, 72, 127);
                return false;
            });

            Timeout.add (500, () => {
                rendering_synth.noteoff (23, 65);
                rendering_synth.noteoff (23, 60);
                rendering_synth.noteoff (23, 72);
                return false;
            });
        }

        private void process_audio (
            int len,
            float* input_l,
            float* input_r,
            float** output_l,
            float** output_r
        ) {
            foreach (var rack in racks) {
                rack.process_audio (
                    len, input_l, input_r, output_l, output_r
                );

                // Copy back to input for next rack
                for (int i = 0; i < len; i++) {
                    input_l[i] = * (* output_l + i);
                    input_r[i] = * (* output_r + i);
                }
            }
        }

        public void add_rack (Racks.Rack rack) {
            racks.append (rack);
        }

        public static uint32 get_buffer_size () {
            return buffer_size;
        }

        public static int64 get_process_start_time () {
            return processing_start_time;
        }

        private void edit_master_reverb (int level) {
            if (rendering_synth != null) {
                rendering_synth.set_reverb_group_roomsize (-1, SynthSettingsPresets.ReverbPresets.ROOM_SIZE[level]);
                rendering_synth.set_reverb_group_damp (-1, 0.1);
                rendering_synth.set_reverb_group_width (-1, SynthSettingsPresets.ReverbPresets.WIDTH[level]);
                rendering_synth.set_reverb_group_level (-1, SynthSettingsPresets.ReverbPresets.LEVEL[level]);
            }
        }

        private void set_master_reverb_active (bool active) {
            if (rendering_synth != null) {
                rendering_synth.reverb_on (-1, active);
            }
        }

        private void edit_master_chorus (int level) {
            if (rendering_synth != null) {
                rendering_synth.set_chorus_group_depth (-1, SynthSettingsPresets.ChorusPresets.DEPTH[level]);
                rendering_synth.set_chorus_group_level (-1, SynthSettingsPresets.ChorusPresets.LEVEL[level]);
                rendering_synth.set_chorus_group_nr (-1, SynthSettingsPresets.ChorusPresets.NR[level]);
            }
        }

        private void set_master_chorus_active (bool active) {
            if (rendering_synth != null) {
                rendering_synth.chorus_on (-1, active);
            }
        }

        private int handle_midi_event (Fluid.MIDIEvent event) {
            bool handled = false;
            foreach (var rack in racks) {
                var voice_rack = rack as Racks.VoiceRack;
                if (voice_rack != null) {
                    if (voice_rack.send_midi_event (event) == Fluid.OK) {
                        handled = true;
                    }
                }
            }

            var type = event.get_type ();
            var key = event.get_key ();

            switch (type) {
                case MIDI.EventType.NOTE_ON:
                Application.event_bus.synth_received_note ((uint8) key, true);
                break;
                case MIDI.EventType.NOTE_OFF:
                Application.event_bus.synth_received_note ((uint8) key, false);
                break;
                default:
                break;
            }

            if (handled) {
                return Fluid.OK;
            }

            return rendering_synth.handle_midi_event (event);
        }

        private int handle_midi_event_from_player (Fluid.MIDIEvent event) {
            int type = event.get_type ();
            int chan = event.get_channel ();
            int cont = event.get_control ();
            int value= event.get_value ();

            if (type == MIDI.EventType.CONTROL_CHANGE) {
                if (
                    cont == MIDI.Control.EXPLICIT_BANK_SELECT &&
                    (value == 1 || value == 8 || value == 16 || value == 126)
                ) {
                    int sf_id, program_id, bank_id;
                    rendering_synth.get_program (chan, out sf_id, out bank_id, out program_id);
                    rendering_synth.program_select (chan, soundfont_id, value, program_id);
                }

                if (cont == MIDI.Control.GAIN) {
                    if (style_gain_settings.gain[chan] >= 0) {
                        event.set_value (style_gain_settings.gain[chan]);
                    }
                }

                if (cont == MIDI.Control.PAN) {
                    if (modulator_settings.get_mod_buffer_value (MIDI.Control.PAN, (uint8)chan) >= -64) {
                        event.set_value (modulator_settings.get_mod_buffer_value (10, (uint8)chan));
                    }
                } else {
                    if (modulator_settings.get_mod_buffer_value ((uint8)cont, (uint8)chan) >= 0) {
                        event.set_value (
                            modulator_settings.get_mod_buffer_value ((uint8)cont, (uint8)chan)
                        );
                    }
                }
            }

            if (type == MIDI.EventType.NOTE_ON) {
                //  velocity_buffer[chan] = value;
            }

            return rendering_synth.handle_midi_event (event);
        }

        private void halt_notes (bool except_drums) {
            for (uint8 i = 0; i < 16; i++) {
                if (!except_drums || (i != 9 && i != 10)) {
                    rendering_synth.all_notes_off (i);
                }
            }
        }

        private void stop_all_sounds () {
            for (uint8 i = 0; i < 16; i++) {
                rendering_synth.all_sounds_off (i);
            }
        }
    }
}
