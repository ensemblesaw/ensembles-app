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
    public struct LV2Urid {
    }

    [CCode (has_target = false)]
    public delegate LV2Urid map_call_back (void* handle, string uri);
    [CCode (has_target = false)]
    public delegate string unmap_call_back (void* handle, LV2Urid urid);

    [CCode (cname = "LV2_URID_Map", destroy_function = "")]
    public struct LV2UridMap {
        public void* handle;
        [CCode (cname = "map", has_target = false, delegate_target_cname = "")]
        public unowned map_call_back map;
    }

    [CCode (cname = "LV2_URID_Unmap", destroy_function = "")]
    public struct LV2UridUnmap {
        public void* handle;
        [CCode (cname = "unmap", has_target = false, delegate_target_cname = "")]
        public unowned unmap_call_back unmap;
    }
}
