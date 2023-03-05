/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Models;

namespace Ensembles.Core.MIDIPlayers {
    public class StyleEngine : Object {
        // Style data
        private unowned Style style;

        // Fluid Player for style
        private Fluid.Player style_player;

        // Utility synth for playing style file
        private unowned Fluid.Synth utility_synth;

        // Player state
        private bool looping = false;
        private uint32 absolute_beat_number = 0;
        private uint32 absolute_measure_number = 0;
        private StylePartType current_part;
        private StylePartType next_part;
        private StylePartType current_variation;

        // Per channel note-on tracking flags
        private int[] channel_note_on = {
            -1, -1, -1, -1,
            -1, -1, -1, -1,
            -1, -1, -1, -1,
            -1, -1, -1, -1
        };

        // Chord data
        private Chord chord;
        private bool alt_channels_active = false;
        private HashTable<StylePartType, StylePartBounds?> part_bounds_map;

        // Change queues
        private bool queue_fill = false;
        private bool queue_chord_change = false;
        private bool queue_variation_change = false;

        // Thresholds
        private uint8 time_resolution_limit = 0;
        private uint measure_length;

        public signal void part_changed (StylePartType part_type);
        public signal void beat (bool measure, uint8 time_signature_n, uint8 time_signature_d);

        construct {
            part_bounds_map = new HashTable<StylePartType, StylePartBounds?> (direct_hash, direct_equal);
        }

        public StyleEngine (Synthesizer.SynthProvider synth_provider, Models.Style? style,
            uint8? custom_tempo = 0, StylePartType? custom_part = StylePartType.VARIATION_A) {
            this.style = style;
            utility_synth = synth_provider.utility_synth;

            style_player = new Fluid.Player (utility_synth);
            style_player.set_tick_callback ( (style_engine_ref, ticks) => {
                return ((StyleEngine?)style_engine_ref).parse_ticks (ticks);
            }, this);
            style_player.set_playback_callback ((style_engine_ref, event) =>{
                return ((StyleEngine?)style_engine_ref).parse_midi_events (event);
            }, this);

            style_player.add (style.enstl_path);

            style.update_part_hash_table (part_bounds_map);

            var actual_tempo = style_player.get_midi_tempo ();
            if (custom_tempo >= 40) {
                style_player.set_tempo (Fluid.TempoType.EXTERNAL_BPM, (double)custom_tempo);
                actual_tempo = custom_tempo;
            }

            if (actual_tempo < 130)
            {
                time_resolution_limit = 1;
            }
            else if (actual_tempo < 182)
            {
                time_resolution_limit = 2;
            }
            else
            {
                time_resolution_limit = 3;
            }

            if (custom_part != null) {
                current_part = custom_part;

                current_variation = StylePartType.VARIATION_A;
            }

            halt_continuous_notes ();
            measure_length = style.time_resolution * style.time_signature_n;
        }

        private void halt_continuous_notes () {
            for (uint channel = 0; channel < 16; channel++) {
                if (channel < 9 || channel > 10) {
                    channel_note_on[channel] = -1;
                }
            }

            Application.event_bus.halt_notes (true);
        }

        private int parse_ticks (int ticks) {
            // If there is a chord change
            if (queue_chord_change) {
                queue_chord_change = false;
                Application.event_bus.halt_notes (true);
                for (uint8 channel = 0; channel < 16; channel++) {
                    if ((channel < 9 || channel > 10) && channel_note_on[channel] >= 0) {
                        resend_key (channel_note_on[channel], channel);
                    }
                }
            }

            var current_part_bounds = part_bounds_map.get (current_part);
            uint current_measure_start = (uint)Math.floor ((double)ticks / (double)measure_length) * measure_length;
            uint current_measure_end = (uint)Math.ceil ((double)(ticks - 1) / (double)measure_length) * measure_length;

            // Fills don't wait for measure
            if (queue_fill) {
                queue_fill = false;
                if (Ensembles.settings.autofill) {
                    switch (current_part) {
                        case StylePartType.VARIATION_A:
                            switch (next_part) {
                                case StylePartType.VARIATION_A:
                                    current_part = StylePartType.FILL_A;
                                    break;
                                case StylePartType.VARIATION_B:
                                    current_part = StylePartType.FILL_A;
                                    break;
                                case StylePartType.VARIATION_C:
                                    current_part = StylePartType.FILL_B;
                                    break;
                                case StylePartType.VARIATION_D:
                                    current_part = StylePartType.FILL_C;
                                    break;
                            }
                            break;
                        case StylePartType.VARIATION_B:
                            switch (next_part) {
                                case StylePartType.VARIATION_A:
                                    current_part = StylePartType.FILL_A;
                                    break;
                                case StylePartType.VARIATION_B:
                                    current_part = StylePartType.FILL_B;
                                    break;
                                case StylePartType.VARIATION_C:
                                    current_part = StylePartType.FILL_B;
                                    break;
                                case StylePartType.VARIATION_D:
                                    current_part = StylePartType.FILL_C;
                                    break;
                            }
                            break;
                        case StylePartType.VARIATION_C:
                            switch (next_part) {
                                case StylePartType.VARIATION_A:
                                    current_part = StylePartType.FILL_A;
                                    break;
                                case StylePartType.VARIATION_B:
                                    current_part = StylePartType.FILL_B;
                                    break;
                                case StylePartType.VARIATION_C:
                                    current_part = StylePartType.FILL_C;
                                    break;
                                case StylePartType.VARIATION_D:
                                    current_part = StylePartType.FILL_C;
                                    break;
                            }
                            break;
                        case StylePartType.VARIATION_D:
                            switch (next_part) {
                                case StylePartType.VARIATION_A:
                                    current_part = StylePartType.FILL_A;
                                    break;
                                case StylePartType.VARIATION_B:
                                    current_part = StylePartType.FILL_B;
                                    break;
                                case StylePartType.VARIATION_C:
                                    current_part = StylePartType.FILL_C;
                                    break;
                                case StylePartType.VARIATION_D:
                                    current_part = StylePartType.FILL_D;
                                    break;
                            }
                            break;
                    }
                } else {
                    switch (current_part) {
                        case StylePartType.VARIATION_A:
                        current_part = StylePartType.FILL_A;
                        break;
                        case StylePartType.VARIATION_B:
                        current_part = StylePartType.FILL_B;
                        break;
                        case StylePartType.VARIATION_C:
                        current_part = StylePartType.FILL_C;
                        break;
                        case StylePartType.VARIATION_D:
                        current_part = StylePartType.FILL_D;
                        break;
                    }
                }

                var fill_part_bounds = part_bounds_map.get (current_part);
                var fill_start = fill_part_bounds.start + (ticks - current_measure_start);
                if (Ensembles.settings.autofill && next_part < current_variation) {
                    halt_continuous_notes ();
                }
                return style_player.seek ((int)fill_start);
            }

            bool measure;
            if (is_beat (ticks, out measure)) {
                beat (measure, style.time_signature_n, style.time_signature_d);
                //  print ("%d %u  %u  %u  %u\n", ticks, current_part_bounds.start,
                //  current_part_bounds.end, current_measure_start, current_measure_end);
                //  print ("%d, %u, %d\n", ticks, current_measure_end, current_part);

                if (ticks >= current_measure_end) {
                    switch (current_part) {
                        // If we are currently in a variation
                        case StylePartType.VARIATION_A:
                        case StylePartType.VARIATION_B:
                        case StylePartType.VARIATION_C:
                        case StylePartType.VARIATION_D:
                            // If the next part is the same,
                            // wait for current measure to end
                            current_variation = current_part;
                            if (current_part == next_part) {
                                if (ticks >= current_part_bounds.end) {
                                    halt_continuous_notes ();
                                    return style_player.seek (part_bounds_map.get (next_part).start - 1);
                                }
                            } else {
                                current_part = next_part;
                                halt_continuous_notes ();
                                return style_player.seek (part_bounds_map.get (next_part).start - 1);
                            }
                            break;
                        case StylePartType.INTRO_1:
                        case StylePartType.INTRO_2:
                        case StylePartType.INTRO_3:
                            if (current_part == next_part) {
                                next_part = current_variation;
                            }
                            if (ticks >= current_part_bounds.end) {
                                current_part = next_part;
                                halt_continuous_notes ();
                                return style_player.seek (part_bounds_map.get (next_part).start);
                            }
                            break;
                        case StylePartType.ENDING_1:
                        case StylePartType.ENDING_2:
                        case StylePartType.ENDING_3:
                            if (ticks >= current_part_bounds.end) {
                                if (current_part == next_part) {
                                    current_part = current_variation;
                                    next_part = current_variation;
                                    stop ();
                                } else {
                                    current_part = next_part;
                                    halt_continuous_notes ();
                                    return style_player.seek (part_bounds_map.get (next_part).start);
                                }
                            }
                            break;
                        case StylePartType.FILL_A:
                        case StylePartType.FILL_B:
                        case StylePartType.FILL_C:
                        case StylePartType.FILL_D:
                            current_variation = current_part;
                            current_part = next_part;
                            halt_continuous_notes ();
                            return style_player.seek (part_bounds_map.get (next_part).start - 2);
                    }
                }
            }

            return Fluid.OK;
        }

        private bool is_beat (int ticks, out bool measure) {
            var q = ticks / style.time_resolution;
            if (q != absolute_beat_number) {
                absolute_beat_number = q;

                var mq = ticks / (style.time_resolution * style.time_signature_n);
                if (mq != absolute_measure_number) {
                    absolute_measure_number = mq;
                    measure = true;
                } else {
                    measure = false;
                }
                return true;
            }

            measure = false;

            return false;
        }

        private int parse_midi_events (Fluid.MIDIEvent? event) {
            int type = event.get_type ();
            int channel = event.get_channel ();
            int control = event.get_control ();
            int key = event.get_key ();
            int value = event.get_value ();
            int velocity = event.get_velocity ();

            // Bypass voice halt signal
            if (control == 120) {
                return Fluid.OK;
            }
            // Check if alt_channel signal is active
            else if (channel == 11 && control == 82) {
                alt_channels_active = value > 63;
            }

            // If alt channels is enabled, that means it will disable half of
            // the channels based on the scale type
            if (type == MIDI.EventType.NOTE_ON && alt_channels_active) {
                if (style.scale_type != chord.type) {
                    if (channel == 0 ||
                        channel == 2 ||
                        channel == 3 ||
                        channel == 4 ||
                        channel == 6 ||
                        channel == 7) {
                        return Fluid.OK;
                    }
                }
            } else {
                if (channel == 11 ||
                    channel == 12 ||
                    channel == 13 ||
                    channel == 14 ||
                    channel == 15) {
                    return Fluid.OK;
                }
            }

            var new_event = new Fluid.MIDIEvent ();
            new_event.set_type (type);
            new_event.set_channel (channel);
            new_event.set_pitch (event.get_pitch ());
            new_event.set_program (event.get_program ());
            new_event.set_value (value);
            new_event.set_velocity (velocity);
            new_event.set_control (control);

            // Track which notes are on so that they can be continued after
            // chord change
            if (channel < 9 || channel > 10) {
                if (type == MIDI.EventType.NOTE_ON) {
                    // The shift allows storing two intergers in one.
                    // This way we can store both key and velocity in one int.
                    // It is reteived in `resend_key ()` function
                    channel_note_on[channel] = key | (velocity << 16);
                } else if (type == MIDI.EventType.NOTE_OFF) {
                    channel_note_on[channel] = -1;
                }
            }

            // Modify tonal channels with chord
            if (channel != 9 && channel != 10 &&
               (type == MIDI.EventType.NOTE_ON || type == MIDI.EventType.NOTE_OFF))
            {
                new_event.set_key (StyleMIDIModifers.modify_key_by_chord (key, chord,
                    style.scale_type, alt_channels_active));
            }
            else
            {
                new_event.set_key (key);
            }

            // Send data to synth
            Application.event_bus.style_midi_event (new_event);

            return Fluid.OK;
        }

        private void resend_key (int value, int channel) {
            var new_event = new Fluid.MIDIEvent ();
            new_event.set_channel (channel);
            new_event.set_type (MIDI.EventType.NOTE_ON);
            // Decode key and velocty from the integer value
            new_event.set_key (StyleMIDIModifers.modify_key_by_chord (value & 0xFFFF,
                chord, style.scale_type, alt_channels_active));
            new_event.set_velocity ((value >> 16) & 0xFFFF);

            Application.event_bus.style_midi_event (new_event);
        }


        public void play () {
            if (style_player.get_status () != Fluid.PlayerStatus.PLAYING) {
                next_part = current_part;
                style_player.seek (part_bounds_map.get (current_part).start);
                style_player.play ();
            }
        }

        public void stop () {
            if (style_player.get_status () == Fluid.PlayerStatus.PLAYING) {
                style_player.stop ();
                halt_continuous_notes ();
            }
        }

        public void toggle_play () {
            if (style_player.get_status () != Fluid.PlayerStatus.PLAYING) {
                play ();
            } else {
                stop ();
            }
        }

        public void set_next_part (StylePartType _part) {
            if (style_player.get_status () == Fluid.PlayerStatus.PLAYING) {
                if (next_part != StylePartType.INTRO_1 &&
                    next_part != StylePartType.INTRO_2 &&
                    next_part != StylePartType.INTRO_3 &&
                    next_part != StylePartType.ENDING_1 &&
                    next_part != StylePartType.ENDING_2 &&
                    next_part != StylePartType.ENDING_3) {
                    if (next_part == _part || Ensembles.settings.autofill) {
                        queue_fill = true;
                    }
                }
                next_part = _part;
            } else {
                current_part = _part;
            }
        }
    }
}
