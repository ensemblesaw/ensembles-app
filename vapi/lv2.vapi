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

//  [CCode(cheader_filename="lv2/lv2plug.in/ns/ext/urid/urid.h")]
//  namespace LV2.ext.URID {
//      [SimpleType]
//      [CCode (cname = "LV2_URID_Map_Handle", has_type_id = false)]
//      public class LV2URIDMapHandle : LV2.Handle {
//      }

//      [SimpleType]
//      [CCode (cname = "LV2_URID_Unmap_Handle", has_type_id = false)]
//      public class LV2URIDUnmapHandle : LV2.Handle {
//      }

//      [SimpleType]
//      [IntegerType (rank = 9)]
//      [CCode (cname = "LV2_URID", has_type_id = false)]
//      public struct LV2Urid {
//      }

//      [CCode (cname = "LV2_URID_Map", has_type_id = false)]
//      public class LV2UridMap {
//          public LV2UridMap (LV2URIDMapHandle handle, map_call_back map) {
//              this.handle = handle;
//              this.map = map;
//          }
//          public LV2URIDMapHandle handle;
//          [CCode (cname = "map", has_target = false)]
//          public delegate LV2Urid map_call_back (LV2URIDMapHandle handle, string uri);
//          public map_call_back map;
//      }

//      [CCode (cname = "LV2_URID_Unmap", has_type_id = false)]
//      public class LV2UridUnmap {
//          public LV2UridUnmap () {

//          }
//          public LV2URIDUnmapHandle handle;
//          [CCode (cname = "unmap", has_target = false)]
//          public delegate LV2Urid unmap_call_back (LV2URIDUnmapHandle handle, string uri);
//          public unmap_call_back unmap;
//      }
//  }
