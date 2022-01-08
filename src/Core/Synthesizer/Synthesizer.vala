/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core {
    public class Synthesizer : Object {
        private bool input_enabled = true;
        public int chord_main = 0;
        public int chord_type = 0;
        public signal void detected_chord (int chord_main, int type);
        public Synthesizer (string soundfont, string driver_name, double buffer_size) {
            synthesizer_init (soundfont, driver_name, buffer_size);
            synthesizer_set_fx_callback ((buffer_l_in, buffer_r_in, out buffer_out_l, out buffer_out_r) => {
                EffectRack.set_synth_callback (buffer_l_in, buffer_r_in, out buffer_out_l, out buffer_out_r);
            });

            synthesizer_set_event_callback ((channel, key, velocity, on, c_main, c_type) =>{
                //  print ("%d, %d, %d, %d, %d, %d\n", channel, key, velocity, on, c_main, c_type);
                Application.main_window.main_keyboard.set_note_on (key, (on == 144), true);
                if (Shell.RecorderScreen.sequencer != null &&
                    Shell.RecorderScreen.sequencer.current_state != MidiRecorder.RecorderState.PLAYING
                        && (channel == 17 || channel == 18 || channel == 19)) {
                    if (on != 0) {
                        var midi_event = new MidiEvent ();
                        midi_event.event_type = MidiEvent.EventType.NOTE;
                        midi_event.value1 = key;
                        midi_event.velocity = velocity;
                        midi_event.channel = (uint8)channel;
                        midi_event.value2 = on;
                        Shell.RecorderScreen.sequencer.record_event (midi_event);
                    }
                }
            });
        }

        public void set_chord (int c_main, int c_type) {
            detected_chord (c_main, c_type);
        }

        public void synthesizer_deinit () {
           synthesizer_destruct ();
        }

        public int set_driver_configuration (string driver_name, double buffer_size) {
            return synthesizer_set_driver_configuration (driver_name, buffer_size);
        }

        public void disable_input (bool disable) {
            input_enabled = !disable;
            if (disable) {
                halt_realtime (true);
            }
        }

        public void send_notes_realtime (int key, int on, int velocity, int? channel = 17) {
            if (input_enabled) {
                chord_main = synthesizer_send_notes (key, on, velocity, channel, out chord_type);
                if (chord_main > -6) {
                    if (Shell.RecorderScreen.sequencer != null &&
                        Shell.RecorderScreen.sequencer.current_state != MidiRecorder.RecorderState.PLAYING
                            && channel == 17) {
                        var midi_event = new MidiEvent ();
                        midi_event.event_type = MidiEvent.EventType.STYLECHORD;
                        midi_event.value1 = chord_main;
                        midi_event.value2 = chord_type;
                        Shell.RecorderScreen.sequencer.record_event (midi_event);
                    }
                    Application.arranger_core.synthesizer.set_chord (chord_main, chord_type);
                }
            }
        }

        public void halt_realtime (bool all) {
            synthesizer_halt_realtime (all ? 1 : 0);
        }

        public void sustain (bool on) {
            synthesizer_send_sustain (on ? 1 : 0);
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

        public void set_master_reverb_active (bool active) {
            synthesizer_set_master_reverb_active (active ? 1 : 0);
        }

        public void set_master_chorus_active (bool active) {
            synthesizer_set_master_chorus_active (active ? 1 : 0);
        }

        public void change_voice (Voice voice, uint8 channel) {
            synthesizer_change_voice (voice.bank, voice.preset, channel);
        }

        public void get_voice_program_by_channel (uint8 channel, out int bank, out int preset) {
            synthesizer_get_voice_by_channel (channel, out bank, out preset);
        }

        public static void set_modulator_value (int channel, int modulator, int value) {
            synthesizer_change_modulator (channel, modulator, value);
        }

        public static int get_modulator_value (int channel, int modulator) {
            return synthesizer_get_modulator_values (channel, modulator);
        }

        public static void lock_gain (int channel) {
            set_gain_value (channel, -1);
        }

        public static void lock_modulator (int modulator, int channel) {
            if (modulator == 10) {
                set_mod_buffer_value (10, channel, -65);
            } else {
                set_mod_buffer_value (modulator, channel, -1);
            }
        }

        public static bool get_modulator_lock (int modulator, int channel) {
            if (modulator == 10) {
                if (get_mod_buffer_value (modulator, channel) > -65) {
                    return true;
                }
                return false;
            }
            if (get_mod_buffer_value (modulator, channel) > -1) {
                return true;
            }
            return false;
        }

        public static int get_channel_velocity (int channel) {
            return synthesizer_get_velocity_levels (channel);
        }

        public static int get_transpose () {
            return synthesizer_transpose;
        }

        public static void set_transpose (int transpose) {
            synthesizer_transpose = transpose;
        }

        public static bool get_transpose_active () {
            return synthesizer_transpose_enable == 1;
        }

        public static void set_transpose_active (bool active) {
            if (active) {
                synthesizer_transpose_enable = 1;
            } else {
                synthesizer_transpose_enable = 0;
            }
        }

        public static int get_octave () {
            return synthesizer_octave;
        }

        public static void set_octave (int octave) {
            synthesizer_octave = octave;
        }

        public static bool get_octave_shifted () {
            return synthesizer_octave_shifted == 1;
        }

        public static void set_octave_shifted (bool active) {
            if (active) {
                synthesizer_octave_shifted = 1;
            } else {
                synthesizer_octave_shifted = 0;
            }
        }

        public static float get_fluidsynth_version () {
            return synthesizer_get_version ();
        }
    }
}

// synthesizer.c
extern void synthesizer_init (string loc, string dname, double buffer_size);
extern void synthesizer_destruct ();
extern int synthesizer_set_driver_configuration (string dname, double buffer_size);
extern int synthesizer_send_notes (int key, int on, int velocity, int channel, out int type);
extern void synthesizer_halt_notes ();
extern void synthesizer_halt_realtime (int b_all);
extern void synthesizer_send_sustain (int on);

extern void synthesizer_set_accomp_enable (int on);


extern void synthesizer_edit_master_reverb (int level);
extern void synthesizer_edit_master_chorus (int level);
extern void synthesizer_set_master_reverb_active (int active);
extern void synthesizer_set_master_chorus_active (int active);

extern void synthesizer_change_voice (int bank, int preset, int channel);
extern void synthesizer_get_voice_by_channel (int channel, out int bank, out int preset);

extern void synthesizer_change_modulator (int channel, int modulator, int value);
extern int synthesizer_get_modulator_values (int channel, int modulator);
extern void set_gain_value (int channel, int value);

extern int get_mod_buffer_value (int modulator, int channel);
extern void set_mod_buffer_value (int modulator, int channel, int value);
extern int synthesizer_get_velocity_levels (int channel);

extern float synthesizer_get_version ();


[CCode (cname = "synthesizer_fx_callback", has_target = false)]
extern delegate void synthesizer_fx_callback (float[] input_l, float[] input_r, out float[] output_l, out float[] output_r);
[CCode (has_target = false)]
extern void synthesizer_set_fx_callback (synthesizer_fx_callback function);

[CCode (cname = "synthesizer_note_event_callback", has_target = false)]
extern delegate void synthesizer_note_event_callback (int channel, int key, int velocity, int on, int chord_main, int chord_type);
[CCode (has_target = false)]
extern void synthesizer_set_event_callback (synthesizer_note_event_callback function);

extern int synthesizer_transpose;
extern int synthesizer_transpose_enable;
extern int synthesizer_octave;
extern int synthesizer_octave_shifted;
