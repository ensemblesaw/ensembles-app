/*-
 * Copyright (c) 2021-2022 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
 */

namespace Ensembles.Core {
    public class Synthesizer : Object {
        public Synthesizer (string soundfont) {
            synthesizer_init (soundfont);
            set_fx_callback ((buffer_l_in, buffer_r_in, out buffer_out_l, out buffer_out_r) => {
                EffectRack.set_synth_callback (buffer_l_in, buffer_r_in, out buffer_out_l, out buffer_out_r);
            });
        }

        public void synthesizer_deinit () {
           synthesizer_destruct ();
        }

        public signal void detected_chord (int chord_main, int type);

        public void send_notes_realtime (int key, int on, int velocity, int? channel = -1, bool? record = true) {
            int chord_type = 0;
            int chord_feedback = synthesizer_send_notes (key, on, velocity, channel, out chord_type);
            if (chord_feedback > -6) {
                //debug("chord: %d %d\n", chord_feedback, chord_type);
                detected_chord (chord_feedback, chord_type);
            }

            // Send to Sequencer for recording
            if (record == true && Shell.RecorderScreen.sequencer != null && Shell.RecorderScreen.sequencer.current_state != MidiRecorder.RecorderState.PLAYING) {
                var event = new MidiEvent ();
                event.channel = 0;
                event.event_type = MidiEvent.EventType.NOTE;
                event.value1 = key;
                event.value2 = on;
                event.velocity = velocity;

                Shell.RecorderScreen.sequencer.record_event (event);
            }
        }

        public void halt_realtime () {
            synthesizer_halt_realtime ();
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

        public void change_voice (Voice voice, int channel, bool? record = true) {
            synthesizer_change_voice (voice.bank, voice.preset, channel);

            if (channel != 1 && channel != 2) {
                Shell.EnsemblesApp.settings.set_int ("voice-r1-bank", voice.bank);
                Shell.EnsemblesApp.settings.set_int ("voice-r1-preset", voice.preset);
            } else if (channel == 1) {
                Shell.EnsemblesApp.settings.set_int ("voice-r2-bank", voice.bank);
                Shell.EnsemblesApp.settings.set_int ("voice-r2-preset", voice.preset);
            } else {
                Shell.EnsemblesApp.settings.set_int ("voice-l-bank", voice.bank);
                Shell.EnsemblesApp.settings.set_int ("voice-l-preset", voice.preset);
            }

            // Send to Sequencer for recording
            if (record == true && Shell.RecorderScreen.sequencer != null && Shell.RecorderScreen.sequencer.current_state != MidiRecorder.RecorderState.PLAYING) {
                var event = new MidiEvent ();
                event.channel = channel;
                event.event_type = MidiEvent.EventType.VOICECHANGE;
                event.value1 = voice.bank;
                event.value2 = voice.index;

                Shell.RecorderScreen.sequencer.record_event (event);
            }
        }

        public static void set_modulator_value (int synth_index, int channel, int modulator, int value) {
            synthesizer_change_modulator (synth_index, channel, modulator, value);
        }

        public static int get_modulator_value (int synth_index, int channel, int modulator) {
            return synthesizer_get_modulator_values (synth_index, channel, modulator);
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

        public static int get_channel_velocity (int synth_index, int channel) {
            return synthesizer_get_velocity_levels (synth_index, channel);
        }

        public static void set_transpose (int transpose) {
            synthesizer_transpose = transpose;
        }

        public static void set_transpose_active (bool active) {
            if (active) {
                synthesizer_transpose_enable = 1;
            } else {
                synthesizer_transpose_enable = 0;
            }
        }

        public static void set_octave (int octave) {
            synthesizer_octave = octave;
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

extern void synthesizer_init (string loc);
extern void synthesizer_destruct ();
extern int synthesizer_send_notes (int key, int on, int velocity, int channel, out int type);
extern void synthesizer_halt_notes ();
extern void synthesizer_halt_realtime ();

extern void synthesizer_set_accomp_enable (int on);


extern void synthesizer_edit_master_reverb (int level);
extern void synthesizer_edit_master_chorus (int level);
extern void synthesizer_set_master_reverb_active (int active);
extern void synthesizer_set_master_chorus_active (int active);

extern void synthesizer_change_voice (int bank, int preset, int channel);

extern void synthesizer_change_modulator (int synth_index, int channel, int modulator, int value);
extern int synthesizer_get_modulator_values (int synth_index, int channel, int modulator);
extern void set_gain_value (int channel, int value);

extern int get_mod_buffer_value (int modulator, int channel);
extern void set_mod_buffer_value (int modulator, int channel, int value);
extern int synthesizer_get_velocity_levels (int synth_index, int channel);

extern float synthesizer_get_version ();


[CCode (cname = "synthesizer_fx_callback", has_target = false)]
extern delegate void synthesizer_fx_callback (float[] input_l, float[] input_r, out float[] output_l, out float[] output_r);
[CCode (has_target = false)]
extern void set_fx_callback (synthesizer_fx_callback function);

extern int synthesizer_transpose;
extern int synthesizer_transpose_enable;
extern int synthesizer_octave;
extern int synthesizer_octave_shifted;
