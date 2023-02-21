/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

 namespace Ensembles.Services {
    public class EventBus : Object {
        public signal void arranger_ready ();

        // Style Player Events
        public signal void chord_changed (Ensembles.Models.Chord chord);
        public signal int style_midi_event (Fluid.MIDIEvent event);

        // Synthesizer
        public signal void halt_notes (bool except_drums = false);
    }
}