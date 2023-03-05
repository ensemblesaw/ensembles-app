/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.Synthesizer {
    public class Synthesizer : Object {
        private bool input_enabled = true;

        private Analysers.ChordAnalyser chord_analyser;
        private SynthSettingsPresets.StyleGainSettings style_gain_settings;
        private SynthSettingsPresets.ModulatorSettings modulator_settings;
        private unowned Fluid.Synth rendering_synth;

        private int soundfont_id;

        construct {
            chord_analyser = new Analysers.ChordAnalyser ();
            style_gain_settings = new SynthSettingsPresets.StyleGainSettings ();
            modulator_settings = new SynthSettingsPresets.ModulatorSettings ();
        }

        public Synthesizer (SynthProvider synth_provider, string soundfont) throws FluidError {
            rendering_synth = synth_provider.rendering_synth;

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
            } else {
                throw new FluidError.INVALID_SF (_("SoundFont from path: %s is either missing or invalid"), soundfont);
            }

            set_synth_defaults ();

            Application.event_bus.style_midi_event.connect (handle_midi_event_from_player);
            Application.event_bus.halt_notes.connect (halt_notes);
        }

        private void set_synth_defaults () {
            // CutOff for Realtime synth
            rendering_synth.cc (17, MIDI.Control.CUT_OFF, 40);
            rendering_synth.cc (18, MIDI.Control.CUT_OFF, 0);
            rendering_synth.cc (19, MIDI.Control.CUT_OFF, 0);

            // Reverb and Chorus for R1 voice
            rendering_synth.cc (17, MIDI.Control.REVERB, 100);
            rendering_synth.cc (17, MIDI.Control.CHORUS, 100);

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

        public void send_notes_realtime (int channel, int key, int velocity, bool on) {
            if (on) {
                rendering_synth.noteon (channel, key, velocity);
            } else {
                rendering_synth.noteoff (channel, key);
            }
        }

        private int handle_midi_event_from_player (Fluid.MIDIEvent event) {
            int type = event.get_type();
            int chan = event.get_channel();
            int cont = event.get_control();
            int value= event.get_value ();

            if (type == MIDI.EventType.CONTROL) {
                if (cont == MIDI.Control.EXPLICIT_BANK_SELECT && (value == 1 || value == 8 || value == 16 || value == 126)) {
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
                        event.set_value (modulator_settings.get_mod_buffer_value ((uint8)cont, (uint8)chan));
                    }
                }
            }

            if (type == MIDI.EventType.NOTE_ON)
            {
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
    }
}
