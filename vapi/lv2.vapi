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

    [Compact]
    [CCode (cname = "void")]
    public class Handle {
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



// Extensions

[CCode(cheader_filename="lv2/lv2plug.in/ns/ext/urid/urid.h")]
namespace LV2.URID {
    [SimpleType]
    [CCode (cname = "LV2_URID_Map_Handle", has_type_id = false)]
    public struct LV2URIDMapHandle {
    }

    [SimpleType]
    [CCode (cname = "LV2_URID_Unmap_Handle", has_type_id = false)]
    public struct LV2URIDUnmapHandle {
    }

    [SimpleType]
    [IntegerType (rank = 9)]
    [CCode (cname = "LV2_URID", has_type_id = false)]
    public struct Urid {
    }

    [CCode (has_target = false)]
    public delegate Urid map_call_back (void* handle, string uri);
    [CCode (has_target = false)]
    public delegate string unmap_call_back (void* handle, Urid urid);

    [CCode (cname = "LV2_URID_Map", destroy_function = "")]
    public struct UridMap {
        public void* handle;
        [CCode (cname = "map", has_target = false, delegate_target_cname = "")]
        public unowned map_call_back map;
    }

    [CCode (cname = "LV2_URID_Unmap", destroy_function = "")]
    public struct UridUnmap {
        public void* handle;
        [CCode (cname = "unmap", has_target = false, delegate_target_cname = "")]
        public unowned unmap_call_back unmap;
    }

    public const string URI;
    public const string PREFIX;

    public const string _map;
    public const string _unmap;
}


[CCode(cheader_filename="lv2/lv2plug.in/ns/ext/atom/atom.h")]
namespace LV2.Atom {

    [CCode (cname = "LV2_Atom", destroy_function = "", has_type_id = false)]
    public struct Atom {
        uint32 size;
        uint32 type;
    }

    [CCode (destroy_function = "", has_type_id = false)]
    public struct Int {
        Atom atom;
        int32 body;
    }

    [CCode (destroy_function = "", has_type_id = false)]
    public struct Long {
        Atom atom;
        int64 body;
    }

    [CCode (destroy_function = "", has_type_id = false)]
    public struct Float {
        Atom atom;
        float body;
    }

    [CCode (destroy_function = "", has_type_id = false)]
    public struct Double {
        Atom atom;
        double body;
    }

    [SimpleType]
    [CCode (destroy_function = "", has_type_id = false)]
    public struct Bool : Int {}

    [CCode (destroy_function = "", has_type_id = false)]
    public struct URID {
        Atom atom;
        uint32 body;
    }

    [CCode (destroy_function = "", has_type_id = false)]
    public struct String {
        Atom atom;
    }

    [CCode (cname = "LV2_Atom_Literal_Body", destroy_function = "", has_type_id = false)]
    public struct LiteralBody {
        uint32 datatype;
        uint32 lang;
    }

    [CCode (destroy_function = "", has_type_id = false)]
    public struct Literal {
        Atom atom;
        LiteralBody body;
    }

    [CCode (destroy_function = "", has_type_id = false)]
    public struct Tuple {
        Atom atom;
    }

    [CCode (cname = "LV2_Atom_Vector_Body", destroy_function = "", has_type_id = false)]
    public struct VectorBody {
        uint32 child_size;
        uint32 child_type;
    }

    [CCode (destroy_function = "", has_type_id = false)]
    public struct Vector {
        Atom atom;
        VectorBody body;
    }

    [CCode (cname = "LV2_Atom_Property_Body", destroy_function = "", has_type_id = false)]
    public struct PropertyBody {
        uint32 key;
        uint32 context;
        Atom value;
    }

    [CCode (destroy_function = "", has_type_id = false)]
    public struct Property {
        Atom atom;
        PropertyBody body;
    }

    [CCode (cname = "LV2_Atom_Object_Body", destroy_function = "", has_type_id = false)]
    public struct ObjectBody {
        uint32 id;
        uint32 otype;
    }

    [CCode (destroy_function = "", has_type_id = false)]
    public struct Object {
        Atom atom;
        ObjectBody body;
    }

    [CCode (destroy_function = "", has_type_id = false)]
    public struct Event {
        [CCode (cname = "time.frames")]
        int64 time_frames;
        [CCode (cname = "time.beats")]
        double time_beats;
        Atom body;
    }


    [CCode (cname = "LV2_Atom_Sequence_Body", destroy_function = "", has_type_id = false)]
    public struct SequenceBody {
        uint32 unit;
        uint32 pad;
    }

    [CCode (destroy_function = "", has_type_id = false)]
    public struct Sequence {
        Atom atom;
        SequenceBody body;
    }

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
}
