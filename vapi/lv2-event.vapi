[CCode (cheader_filename = "lv2/lv2plug.in/ns/ext/event/event.h")]
namespace LV2.Event {

    [CCode (has_target = false)]
    public delegate uint32 EventRefCallback(CallbackData callback_data, Event* event);
	public delegate uint32 EventUnrefCallback(CallbackData callback_data, Event* event);

    [CCode(cname="LV2_EVENT_URI")]
    public const string URI;
    [CCode(cname="LV2_EVENT_AUDIO_STAMP")]
    public const uint16 AUDIO_STAMP;
    [CCode(cname="LV2_EVENT_PPQN")]
    static const uint32 PPQN;

    [CCode(cname="LV2_Event")]
    public struct Event {
        	uint32 frames;
	        uint32 subframes;
	        uint16 type;
	        uint16 size;
	        /* size bytes of data follow here */
    }
    
    [CCode(cname="LV2_Event_Buffer")]
    public struct Buffer {
        uint8* data;
        uint16 header_size;
        uint16 stamp_type;
        uint32 event_count;
        uint32 capacity;
        uint32 size;
        
        [CCode(cname="lv2_event_buffer_new",
            cheader_filename="lv2/lv2plug.in/ns/ext/event/event-helpers.h")]
        public static Buffer* new(uint32 capacity, uint16 stamp_type);
        
        [CCode(cname="lv2_event_buffer_reset",
            cheader_filename="lv2/lv2plug.in/ns/ext/event/event-helpers.h")]
        public void reset(uint16 stamp_type, uint8* data);
        
    }
    
    [Compact]
    [CCode (cname="void")]
    public class CallbackData {
    }
    
    [CCode(cname="LV2_Event_Feature")]
    public struct Feature {
        unowned CallbackData callback_data;
        EventRefCallback lv2_event_ref;
        EventUnrefCallback lv2_event_unref;
    }
    
    [CCode(cname="LV2_Event_Iterator", cheader_filename="lv2/lv2plug.in/ns/ext/event/event-helpers.h")]
    struct Iterator {
	    Buffer* buf;
	    uint32  offset;
	    
	    [CCode(cname="lv2_event_begin", cheader_filename="lv2/lv2plug.in/ns/ext/event/event-helpers.h")]
	    public bool begin(Buffer* buf);
	    
	    [CCode(cname="lv2_event_is_valid", cheader_filename="lv2/lv2plug.in/ns/ext/event/event-helpers.h")]
	    public bool is_valid();
	    
	    [CCode(cname="lv2_event_increment", cheader_filename="lv2/lv2plug.in/ns/ext/event/event-helpers.h")]
	    public bool increment();
	    
	    [CCode(cname="lv2_event_get", cheader_filename="lv2/lv2plug.in/ns/ext/event/event-helpers.h")]
	    public Event* get(uint8** data);
	    
	    [CCode(cname="lv2_event_write", cheader_filename="lv2/lv2plug.in/ns/ext/event/event-helpers.h")]
	    public bool write(uint32 frames,
                uint32 subframes,
                uint16 type,
                uint16 size,
                uint8* data);
    }
}

