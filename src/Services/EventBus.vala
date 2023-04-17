/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Models;

namespace Ensembles.Services {
    public class EventBus : Object {
        // Shell Events
        public signal void size_change ();
        public signal bool show_menu (bool show);
        public signal void menu_shown (bool shown);

        // Homescreen
        public signal void voice_chosen (VoiceHandPosition position, string name);

        // Core Events
        public signal void arranger_ready ();

        public signal void beat (bool measure, uint8 time_signature_n, uint8 time_signature_d);
        public signal void beat_reset ();

        // Style Player Events
        public signal void style_change (Style style);
        public signal void style_chord_changed (Ensembles.Models.Chord chord);
        public signal int style_midi_event (Fluid.MIDIEvent event);
        public signal void style_play_toggle ();
        public signal void style_set_part (StylePartType part);
        public signal void style_current_part_changed (StylePartType part_type);
        public signal void style_next_part_changed (StylePartType part_type);
        public signal void style_sync ();
        public signal void style_sync_changed (bool active);
        public signal void style_break ();
        public signal void style_break_changed (bool active);

        // Synthesizer
        public signal int synth_send_event (Fluid.MIDIEvent event);
        public signal void synth_received_note (uint8 note_number, bool on);
        public signal void synth_halt_notes (bool except_drums = false);
        public signal void synth_sounds_off ();
        public signal int synth_midi_reroute (int channel, Fluid.MIDIEvent event);

        // Plugins
        public signal void rack_reconnected (Core.Racks.Rack rack, int change_index);
        public signal void show_plugin_ui (Core.Plugins.AudioPlugins.AudioPlugin plugin);
    }
}
