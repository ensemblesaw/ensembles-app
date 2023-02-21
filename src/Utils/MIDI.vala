namespace Ensembles.MIDI {
    public enum EventType {
        NOTE_ON = 144,
        NOTE_OFF = 128,
        CONTROL = 176
    }

    public enum Controls {
        MODULATTION = 1,
        GAIN = 7,
        PAN = 10,
        EXPRESSION = 11,
        EXPLICIT_BANK_SELECT = 85
    }
}
