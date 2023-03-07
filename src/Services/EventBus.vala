/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Models;

namespace Ensembles.Services {
    public class EventBus : Object {
        public signal void arranger_ready ();

        public signal void beat (bool measure, uint8 time_signature_n, uint8 time_signature_d);
        public signal void beat_reset ();

        // Style Player Events
        public signal void style_chord_changed (Ensembles.Models.Chord chord);
        public signal int style_midi_event (Fluid.MIDIEvent event);
        public signal void style_play_toggle ();
        public signal void style_set_part (StylePartType part);
        public signal void style_current_part_changed (StylePartType part_type);
        public signal void style_next_part_changed (StylePartType part_type);

        // Synthesizer
        public signal void halt_notes (bool except_drums = false);
    }
}
