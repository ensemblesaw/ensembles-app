[CCode (cheader_filename = "lv2/lv2plug.in/ns/extensions/ui/ui.h")]
namespace LV2.UI {
    [CCode (cname = "LV2_UI_URI")]
    public const string URI;

    [CCode (cname = "LV2UI_Write_Function", has_target = false)]
    public delegate void Write_Function (Controller controller,
                                         uint32         port_index,
                                         uint32         buffer_size,
                                         uint32         format,
                                         void*    buffer);

    [Compact]
    [CCode (cname="void")]
    public class Widget {
    }

    [Compact]
    [CCode (cname="void")]
    public class Handle {
    }

    [Compact]
    [CCode (cname="void")]
    public class Controller {
    }

    [CCode (cname="LV2_URI_Map_Feature", cheader_filename="lv2/lv2plug.in/ns/ext/uri-map/uri-map.h", has_destroy_function=false, has_copy_function=false)]
    public struct Feature {
    	unowned CallbackData callback_data;
    	Callback uri_to_id;
    }
}

