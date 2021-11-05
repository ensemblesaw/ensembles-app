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
}


[CCode(cheader_filename="lv2/lv2plug.in/ns/ext/atom/atom.h")]
namespace LV2.Atom {

    [CCode (cname = "LV2_Atom", destroy_function = "", has_type_id = false)]
    public struct Atom {
        uint32 size;
        uint32 type;
    }

    [CCode (cname = "LV2_Atom_Int", destroy_function = "", has_type_id = false)]
    public struct AtomInt {
        Atom atom;
        int32 body;
    }

    [CCode (cname = "LV2_Atom_Long", destroy_function = "", has_type_id = false)]
    public struct AtomLong {
        Atom atom;
        int64 body;
    }

    [CCode (cname = "LV2_Atom_Float", destroy_function = "", has_type_id = false)]
    public struct AtomFloat {
        Atom atom;
        float body;
    }

    [CCode (cname = "LV2_Atom_Double", destroy_function = "", has_type_id = false)]
    public struct AtomDouble {
        Atom atom;
        double body;
    }

    [SimpleType]
    [CCode (cname = "LV2_Atom_Bool", destroy_function = "", has_type_id = false)]
    public struct AtomBool : AtomInt {}

    [CCode (cname = "LV2_Atom_URID", destroy_function = "", has_type_id = false)]
    public struct AtomURID {
        Atom atom;
        uint32 body;
    }

    [CCode (cname = "LV2_Atom_String", destroy_function = "", has_type_id = false)]
    public struct AtomString {
        Atom atom;
    }

    [CCode (cname = "LV2_Atom_Literal_Body", destroy_function = "", has_type_id = false)]
    public struct AtomLiteralBody {
        uint32 datatype;
        uint32 lang;
    }

    [CCode (cname = "LV2_Atom_Literal", destroy_function = "", has_type_id = false)]
    public struct AtomLiteral {
        Atom atom;
        AtomLiteralBody body;
    }

    [CCode (cname = "LV2_Atom_Tuple", destroy_function = "", has_type_id = false)]
    public struct AtomTuple {
        Atom atom;
    }

    [CCode (cname = "LV2_Atom_Vector_Body", destroy_function = "", has_type_id = false)]
    public struct AtomVectorBody {
        uint32 child_size;
        uint32 child_type;
    }

    [CCode (cname = "LV2_Atom_Vector", destroy_function = "", has_type_id = false)]
    public struct AtomVector {
        Atom atom;
        AtomVectorBody body;
    }

    [CCode (cname = "LV2_Atom_Property_Body", destroy_function = "", has_type_id = false)]
    public struct AtomPropertyBody {
        uint32 key;
        uint32 context;
        Atom value;
    }

    [CCode (cname = "LV2_Atom_Property", destroy_function = "", has_type_id = false)]
    public struct AtomProperty {
        Atom atom;
        AtomPropertyBody body;
    }

    [CCode (cname = "LV2_Atom_Object_Body", destroy_function = "", has_type_id = false)]
    public struct AtomObjectBody {
        uint32 id;
        uint32 otype;
    }

    [CCode (cname = "LV2_Atom_Object", destroy_function = "", has_type_id = false)]
    public struct AtomObject {
        Atom atom;
        AtomObjectBody body;
    }

    [CCode (cname = "LV2_Atom_Event", destroy_function = "", has_type_id = false)]
    public struct AtomEvent {
        [CCode (cname = "time.frames")]
        int64 time_frames;
        [CCode (cname = "time.beats")]
        double time_beats;
        Atom body;
    }


    [CCode (cname = "LV2_Atom_Sequence_Body", destroy_function = "", has_type_id = false)]
    public struct AtomSequenceBody {
        uint32 unit;
        uint32 pad;
    }

    [CCode (cname = "LV2_Atom_Sequence", destroy_function = "", has_type_id = false)]
    public struct AtomSequence {
        Atom atom;
        AtomSequenceBody body;
    }
}
