/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
/*
 * This file incorporates work covered by the following copyright and
 * permission notices:
 *
 * ---
 *
  Copyright 2006-2012 Steve Harris, David Robillard.
  Copyright 2000-2002 Richard W.E. Furse, Paul Barton-Davis, Stefan Westerfeld.

  Permission to use, copy, modify, and/or distribute this software for any
  purpose with or without fee is hereby granted, provided that the above
  copyright notice and this permission notice appear in all copies.

  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
  REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
  FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
  INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
  LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
  OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
  PERFORMANCE OF THIS SOFTWARE.
 *
 * ---
 */

// LV2 Core ////////////////////////////////////////////////////////////////////
[CCode(cheader_filename="lv2.h", cprefix="LV2_", lower_case_cprefix="lv2_")]
namespace LV2 {
    [CCode(cname="LV2_Feature", has_destroy_function=false, has_copy_function=false)]
	public struct Feature {
	    string URI;
        void* data;
    }

    public struct Descriptor {
        string URI;
    }

    [SimpleType]
    public struct Handle {
    }

    public class Core {
        public const string URI;
        public const string PREFIX;

        public const string _AllpassPlugin;
        public const string _AmplifierPlugin;
        public const string _AnalyserPlugin;
        public const string _AudioPort;
        public const string _BandpassPlugin;
        public const string _CVPort;
        public const string _ChorusPlugin;
        public const string _CombPlugin;
        public const string _CompressorPlugin;
        public const string _ConstantPlugin;
        public const string _ControlPort;
        public const string _ConverterPlugin;
        public const string _DelayPlugin;
        public const string _DistortionPlugin;
        public const string _DynamicsPlugin;
        public const string _EQPlugin;
        public const string _EnvelopePlugin;
        public const string _ExpanderPlugin;
        public const string _ExtensionData;
        public const string _Feature;
        public const string _FilterPlugin;
        public const string _FlangerPlugin;
        public const string _FunctionPlugin;
        public const string _GatePlugin;
        public const string _GeneratorPlugin;
        public const string _HighpassPlugin;
        public const string _InputPort;
        public const string _InstrumentPlugin;
        public const string _LimiterPlugin;
        public const string _LowpassPlugin;
        public const string _MixerPlugin;
        public const string _ModulatorPlugin;
        public const string _MultiEQPlugin;
        public const string _OscillatorPlugin;
        public const string _OutputPort;
        public const string _ParaEQPlugin;
        public const string _PhaserPlugin;
        public const string _PitchPlugin;
        public const string _Plugin;
        public const string _PluginBase;
        public const string _Point;
        public const string _Port;
        public const string _PortProperty;
        public const string _Resource;
        public const string _ReverbPlugin;
        public const string _ScalePoint;
        public const string _SimulatorPlugin;
        public const string _SpatialPlugin;
        public const string _Specification;
        public const string _SpectralPlugin;
        public const string _UtilityPlugin;
        public const string _WaveshaperPlugin;
        public const string _appliesTo;
        public const string _binary;
        public const string _connectionOptional;
        public const string _control;
        public const string _default;
        public const string _designation;
        public const string _documentation;
        public const string _enabled;
        public const string _enumeration;
        public const string _extensionData;
        public const string _freeWheeling;
        public const string _hardRTCapable;
        public const string _inPlaceBroken;
        public const string _index;
        public const string _integer;
        public const string _isLive;
        public const string _latency;
        public const string _maximum;
        public const string _microVersion;
        public const string _minimum;
        public const string _minorVersion;
        public const string _name;
        public const string _optionalFeature;
        public const string _port;
        public const string _portProperty;
        public const string _project;
        public const string _prototype;
        public const string _reportsLatency;
        public const string _requiredFeature;
        public const string _sampleRate;
        public const string _scalePoint;
        public const string _symbol;
        public const string _toggled;
    }
}



// Extensions //////////////////////////////////////////////////////////////////

/**
 * User interfaces of any type for plugins.
 * See <http://lv2plug.in/ns/extensions/ui> for details.
 */
[CCode (cheader_filename = "lv2/lv2plug.in/ns/extensions/ui/ui.h")]
namespace LV2.UI {
    public const string URI;

    public const string PREFIX;

    public const string _CocoaUI;
    public const string _Gtk3UI;
    public const string _GtkUI;
    public const string _PortNotification;
    public const string _PortProtocol;
    public const string _Qt4UI;
    public const string _Qt5UI;
    public const string _UI;
    public const string _WindowsUI;
    public const string _X11UI;
    public const string _binary;
    public const string _fixedSize;
    public const string _idleInterface;
    public const string _noUserResize;
    public const string _notifyType;
    public const string _parent;
    public const string _plugin;
    public const string _portIndex;
    public const string _portMap;
    public const string _portNotification;
    public const string _portSubscribe;
    public const string _protocol;
    public const string _requestValue;
    public const string _floatProtocol;
    public const string _peakProtocol;
    public const string _resize;
    public const string _showInterface;
    public const string _touch;
    public const string _ui;
    public const string _updateRate;
    public const string _windowTitle;
    public const string _scaleFactor;
    public const string _foregroundColor;
    public const string _backgroundColor;

    [CCode (cname = "LV2UI_INVALID_PORT_INDEX")]
    public const uint32 INVALID_PORT_INDEX;

    [SimpleType]
    [CCode (cname = "LV2UI_Widget")]
    public struct Widget {
    }

    [SimpleType]
    [CCode (cname = "LV2UI_Handle")]
    public struct Handle {
    }
}


[CCode(cheader_filename="lv2/lv2plug.in/ns/ext/urid/urid.h")]
namespace LV2.URID {
    [SimpleType]
    [CCode (cname = "LV2_URID_Map_Handle")]
    public struct MapHandle {
    }

    [SimpleType]
    [CCode (cname = "LV2_URID_Unmap_Handle")]
    public struct UnmapHandle {
    }

    [SimpleType]
    [IntegerType (rank = 9)]
    [CCode (cname = "LV2_URID", has_type_id = false)]
    public struct Urid {
    }

    [CCode(instance_pos=0)]
    public delegate Urid UridMapFunc (string uri);
    [CCode(instance_pos=0)]
    public delegate string UridUnmapFunc (Urid urid);

    [CCode (cname = "LV2_URID_Map", destroy_function = "")]
    public struct UridMap {
        [CCode (cname = "handle")]
        public MapHandle handle;
        [CCode (cname = "map", has_target = false, delegate_target_cname = "handle")]
        public unowned UridMapFunc map;
    }

    [CCode (cname = "LV2_URID_Unmap", destroy_function = "")]
    public struct UridUnmap {
        [CCode (cname = "handle")]
        public UnmapHandle handle;
        [CCode (cname = "unmap", has_target = false, delegate_target_cname = "handle")]
        public unowned UridUnmapFunc unmap;
    }

    public const string URI;
    public const string PREFIX;

    public const string _map;
    public const string _unmap;
}


[CCode(cheader_filename="lv2/lv2plug.in/ns/ext/atom/atom.h")]
namespace LV2.Atom {
    public const string URI;

    public const string PREFIX;

    public const string _Atom;
    public const string _AtomPort;
    public const string _Blank;
    public const string _Bool;
    public const string _Chunk;
    public const string _Double;
    public const string _Event;
    public const string _Float;
    public const string _Int;
    public const string _Literal;
    public const string _Long;
    public const string _Number;
    public const string _Object;
    public const string _Path;
    public const string _Property;
    public const string _Resource;
    public const string _Sequence;
    public const string _Sound;
    public const string _String;
    public const string _Tuple;
    public const string _URI;
    public const string _URID;
    public const string _Vector;
    public const string _atomTransfer;
    public const string _beatTime;
    public const string _bufferType;
    public const string _childType;
    public const string _eventTransfer;
    public const string _frameTime;
    public const string _supports;
    public const string _timeUnit;

    [CCode (cname = "LV2_ATOM_CONTENTS", generic_type_pos = 0)]
    public static unowned void* contents<T> (T atom);

    [CCode (cname = "LV2_ATOM_BODY", generic_type_pos = 0)]
    public static unowned void* body (Atom atom);

    [CCode (cname = "LV2_Atom", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct Atom {
        uint32 size;
        uint32 type;
    }

    [CCode (cname = "LV2_Atom_Int", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct Int {
        Atom atom;
        int32 body;
    }

    [CCode (cname = "LV2_Atom_Long", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct Long {
        Atom atom;
        int64 body;
    }

    [CCode (cname = "LV2_Atom_Float", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct Float {
        Atom atom;
        float body;
    }

    [CCode (cname = "LV2_Atom_Double", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct Double {
        Atom atom;
        double body;
    }

    [SimpleType]
    [CCode (cname = "LV2_Atom_Bool", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct Bool : Int {}

    [CCode (cname = "LV2_Atom_URID", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct URID {
        Atom atom;
        uint32 body;
    }

    [CCode (cname = "LV2_Atom_String", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct String {
        Atom atom;
    }

    [CCode (cname = "LV2_Atom_Literal_Body", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct LiteralBody {
        uint32 datatype;
        uint32 lang;
    }

    [CCode (cname = "LV2_Atom_Literal", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct Literal {
        Atom atom;
        LiteralBody body;
    }

    [CCode (cname = "LV2_Atom_Tuple", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct Tuple {
        Atom atom;
    }

    [CCode (cname = "LV2_Atom_Vector_Body", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct VectorBody {
        uint32 child_size;
        uint32 child_type;
    }

    [CCode (cname = "LV2_Atom_Vector", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct Vector {
        Atom atom;
        VectorBody body;
    }

    [CCode (cname = "LV2_Atom_Property_Body", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct PropertyBody {
        uint32 key;
        uint32 context;
        Atom value;
    }

    [CCode (cname = "LV2_Atom_Property", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct Property {
        Atom atom;
        PropertyBody body;
    }

    [CCode (cname = "LV2_Atom_Object_Body", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct ObjectBody {
        uint32 id;
        uint32 otype;
    }

    [CCode (cname = "LV2_Atom_Object", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct Object {
        Atom atom;
        ObjectBody body;
    }

    [CCode (cname = "LV2_Atom_Event", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct Event {
        [CCode (cname = "time.frames")]
        int64 time_frames;
        [CCode (cname = "time.beats")]
        double time_beats;
        Atom body;
    }


    [CCode (cname = "LV2_Atom_Sequence_Body", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct SequenceBody {
        uint32 unit;
        uint32 pad;
    }

    [CCode (cname = "LV2_Atom_Sequence", destroy_function = "", has_type_id = false, has_copy_function = false)]
    public struct Sequence {
        Atom atom;
        SequenceBody body;
    }
}

[CCode(cheader_filename="lv2/lv2plug.in/ns/ext/midi/midi.h")]
namespace LV2.MIDI {
    public const string URI;

    public const string PREFIX;

    public const string _ActiveSense;
    public const string _Aftertouch;
    public const string _Bender;
    public const string _Chunk;
    public const string _Continue;
    public const string _Controller;
    public const string _MidiEvent;
    public const string _NoteOff;
    public const string _NoteOn;
    public const string _ProgramChange;
    public const string _QuarterFrame;
    public const string _Reset;
    public const string _SongPosition;
    public const string _SongSelect;
    public const string _Start;
    public const string _Stop;
    public const string _SystemCommon;
    public const string _SystemExclusive;
    public const string _SystemMessage;
    public const string _SystemRealtime;
    public const string _Tick;
    public const string _TuneRequest;
    public const string _VoiceMessage;
    public const string _benderValue;
    public const string _binding;
    public const string _byteNumber;
    public const string _channel;
    public const string _chunk;
    public const string _controllerNumber;
    public const string _controllerValue;
    public const string _noteNumber;
    public const string _pressure;
    public const string _programNumber;
    public const string _property;
    public const string _songNumber;
    public const string _songPosition;
    public const string _status;
    public const string _statusMask;
    public const string _velocity;

    [CCode (ctype="inline")]
    public static bool is_voice_message (uint8 msg);

    [CCode (ctype="inline")]
    public static bool is_system_message (uint8 msg);

    [CCode (ctype="inline")]
    public static uint8 message_type (uint8 msg);
}

[CCode(cheader_filename="lv2/lv2plug.in/ns/ext/worker/worker.h")]
namespace LV2.Worker {
    public const string URI;

    public const string PREFIX;

    public const string _interface;
    public const string _schedule;

    [CCode (cname = "interface_work_t", has_target = false)]
    public delegate Status InterfaceWorkFunc (LV2.Handle instance, RespondFunc respond, RespondHandle handle, uint32 size, [CCode (type="const void*")] void* data);

    [CCode (cname = "interface_work_reponse_t", has_target = false)]
    public delegate Status InterfaceWorkResponseFunc (LV2.Handle instance, uint32 size, [CCode (type="const void*")] void* body);

    [CCode (cname = "interface_end_run_t", has_target = false)]
    public delegate Status InterfaceEndRunFunc (LV2.Handle instance);

    [Compact]
    [SimpleType]
    [CCode (cname = "LV2_Worker_Interface", has_type_id = false, free_function = "")]
    public class Interface {
        [CCode (cname = "work", has_target = false, delegate_target_cname = "", simple_generics = true)]
        public unowned InterfaceWorkFunc work;
        [CCode (cname = "work_response", has_target = false, delegate_target_cname = "", simple_generics = true)]
        public unowned InterfaceWorkResponseFunc work_response;
        [CCode (cname = "end_run", has_target = false, delegate_target_cname = "", simple_generics = true)]
        public unowned InterfaceEndRunFunc end_run;
    }

    /* Status code for worker functions.  */
    [CCode (cname = "LV2_Worker_Status", has_type_id = false, cprefix = "LV2_WORKER_")]
    public enum Status {
        /** Completed successfully. */
        SUCCESS = 0,
        /** Unknown error. */
        ERR_UNKNOWN = 1,
        /** Failed due to lack of space. */
        ERR_NO_SPACE = 2
    }

    [SimpleType]
    [CCode (cname = "LV2_Worker_Respond_Handle")]
    public struct RespondHandle {
    }

    [SimpleType]
    [CCode (cname = "LV2_Worker_Respond_Function", has_target = false)]
    public delegate Status RespondFunc (RespondHandle handle, uint32 size, [CCode (type="const void*")] void* data);

    [SimpleType]
    [CCode (cname = "LV2_Worker_Schedule_Handle")]
    public struct ScheduleHandle {
    }

    [CCode (instance_pos = 0)]
    public delegate Status SchedulerFunc (uint32 size, void* data);

    [CCode (cname = "LV2_Worker_Schedule", destroy_function = "")]
    public struct Schedule {
        [CCode (cname = "handle")]
        public ScheduleHandle handle;
        [CCode (cname = "schedule_work", has_target = false, delegate_target_cname = "handle")]
        public unowned SchedulerFunc schedule_work;
    }

}


[CCode(cheader_filename="lv2/units/units.h")]
namespace LV2.Units {
    public const string URI;

    public const string PREFIX;

    public const string _Conversion;
    public const string _Unit;
    public const string _bar;
    public const string _beat;
    public const string _bpm;
    public const string _cent;
    public const string _cm;
    public const string _coef;
    public const string _conversion;
    public const string _db;
    public const string _degree;
    public const string _frame;
    public const string _hz;
    public const string _inch;
    public const string _khz;
    public const string _km;
    public const string _m;
    public const string _mhz;
    public const string _midiNote;
    public const string _mile;
    public const string _min;
    public const string _mm;
    public const string _ms;
    public const string _name;
    public const string _oct;
    public const string _pc;
    public const string _prefixConversion;
    public const string _render;
    public const string _s;
    public const string _semitone12TET;
    public const string _symbol;
    public const string _unit;
}


[CCode(cheader_filename="lv2/options/options.h")]
namespace LV2.Options {
    public const string URI;

    public const string PREFIX;

    public const string _Option;
    public const string _interface;
    public const string _options;
    public const string _requiredOption;
    public const string _supportedOption;

    /**
     * The context of an Option, which defines the subject it applies to.
     */
    [CCode (cname = "LV2_Options_Context", has_type_id = false, cprefix = "LV2_OPTIONS_")]
    public enum Context {
        /**
         * This option applies to the instance itself.
         *
         * The subject must be ignored.
         */
        INSTANCE,
        /**
         * This option applies to some named resource.
         *
         * The subject is a URI mapped to an integer (a LV2_URID, like the key)
         */
        RESOURCE,
        /**
         * This option applies to some blank node.
         *
         * The subject is a blank node identifier, which is valid only within the current local scope.
         */
        BLANK,
        /**
         * This option applies to a port on the instance.
         *
         * The subject is the port's index.
         */
        PORT
    }

    /**
     * A status code for option functions.
     */
    [CCode (cname = "LV2_Options_Status", has_type_id = false, cprefix = "LV2_OPTIONS_")]
    public enum Status {
        SUCCESS,
        ERR_UNKNOWN,
        ERR_BAD_SUBJECT,
        ERR_BAD_KEY,
        ERR_BAD_VALUE
    }

    /**
     * An option.
     *
     * ----------
     * This is a property with a subject, also known as a triple or statement.
     *
     * This struct is useful anywhere a statement needs to be passed where no memory ownership issues are present
     * (since the value is a const pointer).
     *
     * Options can be passed to an instance via the feature `LV2_OPTIONS__options` with data pointed to an array of
     * options terminated by a zeroed option, or accessed/manipulated using `LV2_Options_Interface`.
     */
    [SimpleType]
    [CCode (cname = "LV2_Options_Option")]
    public struct Option {
        public Context context;
        public uint32 subject;
        public URID.Urid key;
        public uint32 size;
        public URID.Urid type;
        public void* value;
    }

    [CCode (cname = "lv2_options_interface_get_t", has_target = false)]
    public delegate uint32 InterfaceGetFunc (LV2.Handle instance, out Option options);

    [CCode (cname = "lv2_options_interface_set_t", has_target = false)]
    public delegate uint32 InterfaceSetFunc (LV2.Handle instance, Option options);

    /**
     * Interface for dynamically setting options `(LV2_OPTIONS__interface)`.
     */
    [Compact]
    [SimpleType]
    [CCode (cname = "LV2_Options_Interface", has_type_id = false, free_function = "")]
    public class Interface {
        /**
         * Get the given options.
         *
         * ----------------------
         * Each element of the passed options array MUST have type, subject, and key set. All other fields (size, type,
         * value) MUST be initialised to zero, and are set to the option value if such an option is found.
         *
         * This function is in the "instantiation" LV2 threading class, so no other instance functions may be called
         * concurrently.
         *
         * @returns Bitwise OR of LV2_Options_Status values.
         */
        [CCode (cname = "get", has_target = false, delegate_target_cname = "", simple_generics = true)]
        public unowned InterfaceGetFunc get;
        /**
         * Set the given options.
         *
         * ----------------------
         * This function is in the "instantiation" LV2 threading class, so no other instance functions may be called concurrently.
         *
         * @returns Bitwise OR of LV2_Options_Status values.
         */
        [CCode (cname = "set", has_target = false, delegate_target_cname = "", simple_generics = true)]
        public unowned InterfaceSetFunc set;
    }
}


[CCode(cheader_filename="lv2/parameters/parameters.h")]
namespace LV2.Parameters {
    public const string URI;

    public const string PREFIX;

    public const string _CompressorControls;
    public const string _ControlGroup;
    public const string _EnvelopeControls;
    public const string _FilterControls;
    public const string _OscillatorControls;
    public const string _amplitude;
    public const string _attack;
    public const string _bypass;
    public const string _cutoffFrequency;
    public const string _decay;
    public const string _delay;
    public const string _dryLevel;
    public const string _frequency;
    public const string _gain;
    public const string _hold;
    public const string _pulseWidth;
    public const string _ratio;
    public const string _release;
    public const string _resonance;
    public const string _sampleRate;
    public const string _sustain;
    public const string _threshold;
    public const string _waveform;
    public const string _wetDryRatio;
    public const string _wetLevel;
}


[CCode(cheader_filename="lv2/buf-size/buf-size.h")]
namespace LV2.BufSize {
    public const string URI;

    public const string PREFIX;

    public const string _boundedBlockLength;
    public const string _coarseBlockLength;
    public const string _fixedBlockLength;
    public const string _maxBlockLength;
    public const string _minBlockLength;
    public const string _nominalBlockLength;
    public const string _powerOf2BlockLength;
    public const string _sequenceSize;
}


[CCode(cheader_filename="lv2/log/log.h")]
namespace LV2.Log {
    public const string URI;

    public const string PREFIX;

    public const string _Entry;
    public const string _Error;
    public const string _Note;
    public const string _Trace;
    public const string _Warning;
    public const string _log;

    [SimpleType]
    [CCode (cname = "LV2_Log_Handle")]
    public struct LogHandle {
    }

    [CCode (instance_pos = 0)]
    public delegate int PrintFunc (URID.Urid type, string fmt, ...);

    [CCode (instance_pos = 0)]
    public delegate int VPrintFunc (URID.Urid type, string fmt, va_list ap);

    [CCode (cname = "LV2_Log_Log", destroy_function = "")]
    public struct Log {
        [CCode (cname = "handle")]
        public LogHandle handle;
        [CCode (cname = "printf", has_target = false, delegate_target_cname = "handle")]
        public unowned PrintFunc printf;
        [CCode (cname = "vprintf", has_target = false, delegate_target_cname = "handle")]
        public unowned VPrintFunc vprintf;
    }
}


[CCode(cheader_filename="lv2/patch/patch.h")]
namespace LV2.Patch {
    public const string URI;

    public const string PREFIX;

    public const string _Ack;
    public const string _Delete;
    public const string _Copy;
    public const string _Error;
    public const string _Get;
    public const string _Message;
    public const string _Move;
    public const string _Patch;
    public const string _Post;
    public const string _Put;
    public const string _Request;
    public const string _Response;
    public const string _Set;
    public const string _accept;
    public const string _add;
    public const string _body;
    public const string _context;
    public const string _destination;
    public const string _property;
    public const string _readable;
    public const string _remove;
    public const string _request;
    public const string _subject;
    public const string _sequenceNumber;
    public const string _value;
    public const string _wildcard;
    public const string _writable;
}


[CCode(cheader_filename="lv2/time/time.h")]
namespace LV2.Time {
    public const string URI;

    public const string PREFIX;

    public const string _Time;
    public const string _Position;
    public const string _Rate;
    public const string _position;
    public const string _barBeat;
    public const string _bar;
    public const string _beat;
    public const string _beatUnit;
    public const string _beatsPerBar;
    public const string _beatsPerMinute;
    public const string _frame;
    public const string _framesPerSecond;
    public const string _speed;
}


[CCode(cheader_filename="lv2/port-groups/port-groups.h")]
namespace LV2.PortGroups {
    public const string URI;

    public const string PREFIX;

    public const string _DiscreteGroup;
    public const string _Element;
    public const string _FivePointOneGroup;
    public const string _FivePointZeroGroup;
    public const string _FourPointZeroGroup;
    public const string _Group;
    public const string _InputGroup;
    public const string _MidSideGroup;
    public const string _MonoGroup;
    public const string _OutputGroup;
    public const string _SevenPointOneGroup;
    public const string _SevenPointOneWideGroup;
    public const string _SixPointOneGroup;
    public const string _StereoGroup;
    public const string _ThreePointZeroGroup;
    public const string _center;
    public const string _centerLeft;
    public const string _centerRight;
    public const string _element;
    public const string _group;
    public const string _left;
    public const string _lowFrequencyEffects;
    public const string _mainInput;
    public const string _mainOutput;
    public const string _rearCenter;
    public const string _rearLeft;
    public const string _rearRight;
    public const string _right;
    public const string _side;
    public const string _sideChainOf;
    public const string _sideLeft;
    public const string _sideRight;
    public const string _source;
    public const string _subGroupOf;
}


[CCode(cheader_filename="lv2/port-props/port-props.h")]
namespace LV2.PortProps {
    public const string URI;

    public const string PREFIX;

    public const string _causesArtifacts;
    public const string _continuousCV;
    public const string _discreteCV;
    public const string _displayProperty;
    public const string _expensive;
    public const string _hasStrictBounds;
    public const string _logarithmic;
    public const string _notAutomatic;
    public const string _notOnGUI;
    public const string _rangeSteps;
    public const string _supportsStrictBounds;
    public const string _trigger;
}


[CCode(cheader_filename="lv2/presets/presets.h")]
namespace LV2.Presets {
    public const string URI;

    public const string PREFIX;

    public const string _Bank;
    public const string _Preset;
    public const string _bank;
    public const string _preset;
    public const string _value;
}


[CCode(cheader_filename="lv2/resize-port/resize-port.h")]
namespace LV2.ResizePort {
    public const string URI;

    public const string PREFIX;

    public const string _asLargeAs;
    public const string _minimumSize;
    public const string _resize;

    /**
     * A status code for state functions.
     */
    [CCode (cname = "LV2_Resize_Port_Status", has_type_id = false, cprefix = "LV2_RESIZE_PORT_")]
    public enum Status {
        SUCCESS,
        ERR_UNKNOWN,
        ERR_NO_SPACE
    }

    [SimpleType]
    [CCode (cname = "LV2_Resize_Port_Feature_Data")]
    public struct FeatureData {
    }

    [CCode (cname = "lv2_port_resize_func_t", has_target = false)]
    public delegate Status ResizeFunc (FeatureData data, uint32 index, size_t size);

    [Compact]
    [SimpleType]
    [CCode (cname = "LV2_Resize_Port_Resize", has_type_id = false, free_function = "")]
    public class PortResize {
        FeatureData data;
        [CCode (cname = "resize", has_target = false, delegate_target_cname = "", simple_generics = true)]
        public unowned ResizeFunc resize;
    }
}
