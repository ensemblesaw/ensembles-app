namespace Ensembles.Core { 
    public struct ControllerDevice {
        string name;
        int id;
        bool available;
    }
    public class Controller : Object {
        ControllerDevice[] controller_device;

        public Controller () {
            controller_init ();
        }
        
        ~Controller () {
            stream_connected = false;
            controller_destruct ();
        }

        bool stream_connected = false;

        public signal void receive_note_event (int key, int on, int velocity);

        public Ensembles.Core.ControllerDevice[] get_device_list () {
            int n = controller_query_input_device_count ();
            //print ("Found %d devices...\n", n);
            controller_device = new ControllerDevice[n];
            for (int i = 0; i < n; i++) {
                controller_query_device_info (i);
                controller_device[i].name = controller_input_device_name;
                controller_device[i].available = controller_input_device_available > 0 ? true : false;
                controller_device[i].id = i;
                //print("Found %s device: %s\n", controller_device[i].available ? "input" : "output", controller_device[i].name);
            }
            return controller_device;
        }

        int read_device_stream () {
            while (stream_connected) {
                if (controller_poll_device () > 0) {
                    int message = controller_read_device_stream ();
                    
                    int key = (((0x00FF00 & message) - 9216)/256) + 36;
                    double velocity = 0.0 + ((127.0 - 0.0) / (8323072.0 - 65536.0)) * (double)((0xFF0000 & message) - 65536);
                    //print ("%d %d %d\n", (int)velocity, key, message & 0x0000FF);
                    Idle.add (() => {
                        receive_note_event (key, message & 0x0000FF, (int)velocity);
                        return false;
                    });
                }
            }
            controller_close_connection ();
            return 0;
        }

        public void connect_device (int id) {
            if (!Thread.supported ()) {
                stderr.printf ("Cannot run without thread support.\n");
                return;
            }
            stream_connected = false;
            if (controller_connect_device (id) > 0) {
                stream_connected = true;
                new Thread<int> ("read_device_stream", read_device_stream);
            }
        }
    }
}

extern string controller_input_device_name;
extern int controller_input_device_available;

extern void controller_init ();
extern void controller_destruct ();

extern int controller_query_input_device_count ();
extern void controller_query_device_info (int id);
extern int controller_connect_device (int id);
extern int32 controller_read_device_stream ();
extern void controller_close_connection ();
extern int controller_poll_device ();