namespace Ensembles.MIDI {
    public enum EventType {
        NOTE_ON = 144,
        NOTE_OFF = 128,
        CONTROL = 176
    }

    public enum Control {
        MODULATTION = 1,
        EXPLICIT_PITCH = 3,
        GAIN = 7,
        PAN = 10,
        EXPRESSION = 11,
        PITCH = 66,
        RESONANCE = 71,
        CUT_OFF = 74,
        EXPLICIT_BANK_SELECT = 85,
        REVERB = 91,
        CHORUS = 93
    }
}
