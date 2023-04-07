/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Models;

namespace Ensembles.Core.MIDIPlayers {
    /**
     * ## Ensembles Style Engine
     *
     * A style engine object can be made to play a particular Ensembles style.
     * An Ensembles style is a special MIDI file with `.enstl` extension.
     * The style can take care of style playback using the appropriate chords
     * and changing the style part
     */
    public class StyleEngine : Object {
        // Style data
        private unowned Style style;

        // Fluid Player for style
        private Fluid.Player style_player;

        // Utility synth for playing style file
        private unowned Fluid.Synth utility_synth;

        // Player state
        private uint32 absolute_beat_number = 0;
        private uint32 absolute_measure_number = 0;
        private StylePartType _current_part;
        private StylePartType current_part {
            get {
                return _current_part;
            }
            set {
                _current_part = value;
                Application.event_bus.style_current_part_changed (value);
            }
        }
        private StylePartType _next_part;
        private StylePartType next_part {
            get {
                return _next_part;
            }
            set {
                _next_part = value;
                Application.event_bus.style_next_part_changed (value);
            }
        }
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
        private bool queue_break = false;
        private bool queue_chord_change = false;
        private bool force_change_part = false;
        private bool sync_start = false;
        private bool sync_stop = false;

        // Thresholds
        private uint8 time_resolution_limit = 0;
        private uint measure_length;

        construct {
            part_bounds_map = new HashTable<StylePartType, StylePartBounds?> (direct_hash, direct_equal);
        }

        /**
         * Creates a new instance of a style engine object using the given style.
         *
         * @param synth_provider A synth provider object
         * @param style The style to use for the style engine
         * @param current_tempo If this value is greater than 0 then the style
         * engine will be initialized with this value.
         */
        public StyleEngine (Synthesizer.SynthProvider synth_provider, Models.Style? style,
            uint8? custom_tempo = 0) {
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

            current_variation = StylePartType.VARIATION_A;
            next_part = StylePartType.VARIATION_A;
            current_part = StylePartType.VARIATION_A;

            halt_continuous_notes ();
            measure_length = style.time_resolution * style.time_signature_n;
        }

        private void halt_continuous_notes () {
            for (uint channel = 0; channel < 16; channel++) {
                if (channel < 9 || channel > 10) {
                    channel_note_on[channel] = -1;
                }
            }

            Application.event_bus.synth_halt_notes (true);
        }

        private int parse_ticks (int ticks) {
            // If there is a chord change
            if (queue_chord_change) {
                queue_chord_change = false;
                Application.event_bus.synth_halt_notes (true);
                for (uint8 channel = 0; channel < 16; channel++) {
                    if ((channel < 9 || channel > 10) && channel_note_on[channel] >= 0) {
                        resend_key (channel_note_on[channel], channel);
                    }
                }
            }

            var current_part_bounds = part_bounds_map.get (current_part);
            uint current_measure_start = (uint)Math.floor ((double)ticks / (double)measure_length) * measure_length;
            uint current_measure_end = (uint)Math.ceil ((double)(ticks - 1) / (double)measure_length) * measure_length;

            // Fill Ins
            if (queue_fill) {
                queue_fill = false;
                Application.event_bus.style_break_changed (false);
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
                                default:
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
                                default:
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
                                default:
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
                                    current_part = StylePartType.FILL_D;
                                    break;
                                case StylePartType.VARIATION_D:
                                    current_part = StylePartType.FILL_D;
                                    break;
                                default:
                                break;
                            }
                            break;
                        case StylePartType.BREAK:
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
                                default:
                                break;
                            }
                            break;
                        default:
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
                        default:
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
                            default:
                            break;
                        }
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

            // Break
            if (queue_break) {
                queue_break = false;
                Application.event_bus.style_break_changed (true);
                var break_part_bounds = part_bounds_map.get (StylePartType.BREAK);
                var break_start = break_part_bounds.start + (ticks - current_measure_start);
                current_part = StylePartType.BREAK;
                halt_continuous_notes ();

                return style_player.seek ((int)break_start);
            }

            bool measure;
            if (is_beat (ticks, out measure)) {
                Application.event_bus.beat (measure, style.time_signature_n, style.time_signature_d);
                //  print ("%d %u  %u  %u  %u\n", ticks, current_part_bounds.start,
                //  current_part_bounds.end, current_measure_start, current_measure_end);
                //  print ("%d, %u, %d\n", ticks, current_measure_end, current_part);

                if (ticks >= current_measure_end) {
                    if (sync_stop) {
                        sync_stop = false;
                        sync_start = true;
                        Application.event_bus.style_sync_changed (true);
                        current_part = current_variation;
                        next_part = current_variation;
                        stop ();
                    }
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
                                    return seek_measure (part_bounds_map.get (next_part).start);
                                }
                            } else {
                                current_part = next_part;
                                return seek_measure (part_bounds_map.get (next_part).start);
                            }
                            break;
                        case StylePartType.INTRO_1:
                        case StylePartType.INTRO_2:
                        case StylePartType.INTRO_3:
                            if (current_part == next_part) {
                                next_part = current_variation;
                            }
                            if (ticks >= current_part_bounds.end || force_change_part) {
                                current_part = next_part;
                                force_change_part = false;
                                return seek_measure (part_bounds_map.get (next_part).start);
                            }
                            break;
                        case StylePartType.ENDING_1:
                        case StylePartType.ENDING_2:
                        case StylePartType.ENDING_3:
                            if (force_change_part) {
                                force_change_part = false;
                                current_part = next_part;
                                return seek_measure (part_bounds_map.get (next_part).start);
                            }
                            if (ticks >= current_part_bounds.end) {
                                if (current_part == next_part) {
                                    current_part = current_variation;
                                    next_part = current_variation;
                                    stop ();
                                } else {
                                    current_part = next_part;
                                    return seek_measure (part_bounds_map.get (next_part).start);
                                }
                            }
                            break;
                        case StylePartType.FILL_A:
                        case StylePartType.FILL_B:
                        case StylePartType.FILL_C:
                        case StylePartType.FILL_D:
                            if (current_part == StylePartType.FILL_A) {
                                current_variation = StylePartType.VARIATION_A;
                            } else if (current_part == StylePartType.FILL_B) {
                                current_variation = StylePartType.VARIATION_B;
                            } else if (current_part == StylePartType.FILL_C) {
                                current_variation = StylePartType.VARIATION_C;
                            } else if (current_part == StylePartType.FILL_D) {
                                current_variation = StylePartType.VARIATION_D;
                            }
                            current_part = next_part;
                            return seek_measure (part_bounds_map.get (next_part).start);
                        case StylePartType.BREAK:
                            if (current_part == StylePartType.INTRO_1 ||
                            current_part == StylePartType.INTRO_2 ||
                            current_part == StylePartType.INTRO_3 ||
                            current_part == StylePartType.ENDING_1 ||
                            current_part == StylePartType.ENDING_2 ||
                            current_part == StylePartType.ENDING_3) {
                                current_part = current_variation;
                                next_part = current_variation;
                            } else {
                                current_part = next_part;
                            }
                            Application.event_bus.style_break_changed (false);
                            return seek_measure (part_bounds_map.get (next_part).start);
                        default:
                        break;
                    }
                }
            }

            return Fluid.OK;
        }

        private int seek_measure (int ticks) {
            halt_continuous_notes ();
            absolute_beat_number = ticks / style.time_resolution;
            absolute_measure_number = ticks / (style.time_resolution * style.time_signature_n);
            return style_player.seek (ticks);
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
            // Decode key and velocity from the integer value
            new_event.set_key (StyleMIDIModifers.modify_key_by_chord (value & 0xFFFF,
                chord, style.scale_type, alt_channels_active));
            new_event.set_velocity ((value >> 16) & 0xFFFF);

            Application.event_bus.style_midi_event (new_event);
        }

        /**
         * Starts style playback if not already playing.
         */
        public void play () {
            if (style_player.get_status () != Fluid.PlayerStatus.PLAYING) {
                next_part = current_part;
                Application.event_bus.synth_sounds_off ();
                style_player.seek (part_bounds_map.get (current_part).start);
                style_player.play ();
            }
        }

        /**
         * Stops the style playback if already playing.
         */
        public void stop () {
            if (style_player.get_status () == Fluid.PlayerStatus.PLAYING) {
                style_player.stop ();
                halt_continuous_notes ();
                Application.event_bus.beat_reset ();
            }
        }

        /**
         * Plays the style if not already playing
         * or stops the style if playing.
         */
        public void toggle_play () {
            if (style_player.get_status () != Fluid.PlayerStatus.PLAYING) {
                play ();
            } else {
                stop ();
            }

            sync_start = false;
            sync_stop = false;
            Application.event_bus.style_sync_changed (false);
        }

        /**
         * Change the style variation level or trigger a fill-in.
         *
         * @param part The style part to queue
         */
        public void queue_next_part (StylePartType part) {
            // Wait for measure end if already playing else instantly change part
            if (style_player.get_status () == Fluid.PlayerStatus.PLAYING) {
                if (part != StylePartType.INTRO_1 &&
                    part != StylePartType.INTRO_2 &&
                    part != StylePartType.INTRO_3 &&
                    part != StylePartType.ENDING_1 &&
                    part != StylePartType.ENDING_2 &&
                    part != StylePartType.ENDING_3 &&
                    current_part != StylePartType.INTRO_1 &&
                    current_part != StylePartType.INTRO_2 &&
                    current_part != StylePartType.INTRO_3 &&
                    current_part != StylePartType.ENDING_1 &&
                    current_part != StylePartType.ENDING_2 &&
                    current_part != StylePartType.ENDING_3) {
                    if (next_part == part || Ensembles.settings.autofill) {
                        queue_fill = true;
                    }
                }

                if (next_part != part) {
                    next_part = part;
                } else if (
                    current_part == StylePartType.INTRO_1 ||
                    current_part == StylePartType.INTRO_2 ||
                    current_part == StylePartType.INTRO_3 ||
                    current_part == StylePartType.ENDING_1 ||
                    current_part == StylePartType.ENDING_2 ||
                    current_part == StylePartType.ENDING_3
                ) {
                    next_part = part;
                    force_change_part = true;
                }
            } else {
                current_part = part;
                if (part == StylePartType.VARIATION_A ||
                    part == StylePartType.VARIATION_B ||
                    part == StylePartType.VARIATION_C ||
                    part == StylePartType.VARIATION_D) {
                    next_part = part;
                    current_variation = part;
                }
            }

            queue_break = false;
        }

        /**
         * Inserts a minimum voice section during playback. It could be a short
         * build-up or a drop.
         */
        public void break_play () {
            if (style_player.get_status () == Fluid.PlayerStatus.PLAYING) {
                queue_break = true;
                Application.event_bus.style_break_changed (true);
            }
        }

        /**
         * Start the style playback with chord input or stop the style
         * playback on the next measure.
         */
        public void sync () {
            if (style_player.get_status () == Fluid.PlayerStatus.PLAYING) {
                sync_start = false;
                sync_stop = !sync_stop;
            } else {
                sync_start = !sync_start;
                sync_stop = false;
            }

            Application.event_bus.style_sync_changed (sync_start || sync_stop);
        }

        /**
         * Ask the style player to stop and wait.
         *
         * **Note:** This is a blocking call, meaning the function will wait until the
         * style player is done playing the current measure.
         *
         * @param current_tempo Variable to store the current tempo
         */
        public void stop_and_wait (out uint8 current_tempo) {
            current_tempo = 0;
            if (style_player.get_status () == Fluid.PlayerStatus.PLAYING) {
                sync_stop = true;
                current_tempo = (uint8) style_player.get_bpm ();
                style_player.join ();
            }
        }

        /**
         * Change the chord of the style.
         *
         * This will stop all voices that are playing the current chord
         * and restart them selectively with the new chord.
         *
         * @param chord The chord to change to
         */
        public void change_chord (Chord chord) {
            if (chord.root != ChordRoot.NONE) {
                queue_chord_change = true;
            }

            if (sync_start) {
                sync_start = false;
                Application.event_bus.style_sync_changed (false);
                play ();
            }
        }
    }
}
