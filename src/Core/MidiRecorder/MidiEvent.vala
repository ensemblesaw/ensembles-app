/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core {
    public class MidiEvent {
        public enum EventType {
            NOTE,
            CONTROL,
            VOICECHANGE,
            REVERB,
            REVERBON,
            CHORUS,
            CHORUSON,
            ACCOMP,
            STYLECHANGE,
            STYLECONTROL,
            STYLECONTROLACTUAL,
            STYLESTARTSTOP,
            STYLECHORD,
            TEMPO
        }

        public EventType event_type;
        public uint8 track;        // Which track this event belongs to
        public int value1;         // note value, voice number, style number, control number
        public int value2;         // note on
        public uint8 channel;
        public int velocity;
        public ulong time_stamp;
    }
}
