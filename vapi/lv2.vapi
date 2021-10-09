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

