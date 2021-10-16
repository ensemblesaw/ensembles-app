/*
  Copyright 2011 David Robillard <http://drobilla.net>
  Copyright 2011 Artem Popov <artfwo@gmail.com>

  Permission to use, copy, modify, and/or distribute this software for any
  purpose with or without fee is hereby granted, provided that the above
  copyright notice and this permission notice appear in all copies.

  THIS SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

[CCode(cheader_filename="suil/suil.h", cprefix="Suil", lower_case_cprefix="suil_")]
namespace Suil {

    [CCode (cname = "SuilArg", cprefix = "SUIL_ARG_", has_type_id = false)]
    public enum SuilArgs {
        NONE
    }

    public static void init (int* argc, string*[] argv, SuilArgs key, ...);

    public static uint ui_supported(string host_type_uri, string ui_type_uri);

    [CCode (cname = "SuilPortWriteFunc", has_target = false)]
    public delegate void PortWriteFunc(Controller controller,
        uint32  port_index,
        uint32  buffer_size,
        uint32  protocol,
        void*   buffer);

    [CCode (cname = "SuilPortIndexFunc", has_target = false)]
    public delegate uint32 PortIndexFunc(Controller controller, string port_symbol);

    [CCode (cname = "SuilPortSubscribeFunc", has_target = false)]
    public delegate uint32 PortSubscribeFunc(Controller controller,
        uint32 port_index,
        uint32 protocol,
        LV2.Feature** features);

    [CCode (cname = "SuilPortUnsubscribeFunc", has_target = false)]
    public delegate uint32 PortUnsubscribeFunc(Controller controller,
        uint32 port_index,
        uint32 protocol,
        LV2.Feature** features);

    [Compact]
    [CCode (cname="void")]
    public class Widget {
    }

    [Compact]
    [CCode (cname="void")]
    public class Controller {
    }

    [Compact]
    [CCode (free_function = "suil_host_free")]
    public class Host {
        public Host(PortWriteFunc write_func,
            PortIndexFunc         index_func,
            PortSubscribeFunc   subscribe_func,
            PortUnsubscribeFunc unsubscribe_func);
    }

    [Compact]
    [CCode (free_function = "suil_instance_free")]
    public class Instance {
        public Instance(Host host,
            Controller controller,
            string container_type_uri,
            string plugin_uri,
            string ui_uri,
            string ui_type_uri,
            string ui_bundle_path,
            string ui_binary_path,
            LV2.Feature** features);

        public Widget get_widget();
        public void port_event(uint32 port_index,
            uint32 buffer_size,
            uint32 format,
            void* buffer);
        public unowned void* extension_data(string uri);
    }
}
