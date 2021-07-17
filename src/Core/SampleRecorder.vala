
/* Code adapted from Ryo Nakano's Reco */
namespace Ensembles.Core {
    public class SampleRecorder : Object {
        private enum SourceDevice {
            MIC,
            SYSTEM,
            BOTH
        }

        private string suffix = ".wav";
        private string tmp_full_path;
        private Gst.Element system_sound;
        private Gst.Pipeline pipeline;

        bool flatpak_environment;

        public signal void handle_recording_complete (string tmp_full_path);

        public void start_recording () {
            SourceDevice device_id = SourceDevice.MIC;

            pipeline = new Gst.Pipeline ("pipeline");
            var mic_sound = Gst.ElementFactory.make ("pulsesrc", "mic_sound");
            var sink = Gst.ElementFactory.make ("filesink", "sink");

            if (device_id != SourceDevice.MIC) {
                system_sound = Gst.ElementFactory.make ("pulsesrc", "sys_sound");
                if (system_sound == null) {
                    error ("The GStreamer element pulsesrc (named \"sys_sound\") was not created correctly");
                }
            }

            if (pipeline == null) {
                error ("The GStreamer element pipeline was not created correctly");
            } else if (mic_sound == null) {
                error ("The GStreamer element pulsesrc (named \"mic_sound\") was not created correctly");
            } else if (sink == null) {
                error ("The GStreamer element filesink was not created correctly");
            }

            var flatpak_info = File.new_for_path ("/.flatpak-info");
            flatpak_environment = flatpak_info.query_exists ();
            if (flatpak_environment) {
                print ("Running as flatpak\n");
            } else {
                print ("Running natively\n");
            }

            if (device_id != SourceDevice.MIC) {
                string default_output = "";
                try {
                    string sound_devices = "";
                    GLib.Regex regex = new Regex ("Monitor Source: (.*)");
                    if (flatpak_environment) {
                        Process.spawn_command_line_sync ("env LANG=C pactl list sinks", out sound_devices);
                    } else {
                        Process.spawn_command_line_sync ("pacmd list-sinks", out sound_devices);
                        regex = new Regex ("\\*\\sindex:\\s\\d+\\s\\sname:\\s<([\\w\\.\\-]*)");
                    }
                    MatchInfo match_info;
                    if (regex.match (sound_devices, 0, out match_info)) {
                        default_output = match_info.fetch (1);
                    }
                    if (!flatpak_environment) {
                        default_output += ".monitor";
                    }
    
                    system_sound.set ("device", default_output);
                    debug ("Detected system sound device: %s", default_output);
                } catch (Error e) {
                    warning (e.message);
                }
            }

            if (device_id != SourceDevice.SYSTEM) {
                string default_input = "";
                try {
                    string sound_devices = "";
                    GLib.Regex regex = new Regex ("Name: (.*(?<!monitor)$)", RegexCompileFlags.MULTILINE);
                    if (flatpak_environment) {
                        Process.spawn_command_line_sync ("env LANG=C pactl list sources", out sound_devices);
                    } else {
                        Process.spawn_command_line_sync ("pacmd list-sources", out sound_devices);
                        regex = new Regex ("\\*\\sindex:\\s\\d+\\s\\sname:\\s<([\\w\\.\\-]*)");
                    }
                    MatchInfo match_info;
                    if (regex.match (sound_devices, 0, out match_info)) {
                        default_input = match_info.fetch (1);
                    }
                    mic_sound.set ("device", default_input);
                    debug ("Detected microphone: %s", default_input);
                } catch (Error e) {
                    warning (e.message);
                }
            }

            Gst.Element encoder = Gst.ElementFactory.make ("wavenc", "encoder");
            Gst.Element muxer = null;

            if (encoder == null) {
                error ("The GStreamer element encoder was not created correctly");
            }

            string tmp_filename = "sample_" + new DateTime.now_local ().to_unix ().to_string ();
            tmp_full_path = Environment.get_tmp_dir () + "/%s%s".printf (tmp_filename, suffix);
            sink.set ("location", tmp_full_path);
            debug ("The recording is temporary stored at %s", tmp_full_path);

            // Dual-channelization
            var caps_filter = Gst.ElementFactory.make ("capsfilter", "filter");
            caps_filter.set ("caps", new Gst.Caps.simple (
                             "audio/x-raw", "channels", GLib.Type.INT,
                             2
            ));

            pipeline.add_many (caps_filter, encoder, sink);

            switch (device_id) {
                case SourceDevice.MIC:
                    pipeline.add_many (mic_sound);
                    mic_sound.link_many (caps_filter, encoder);
                    break;
                case SourceDevice.SYSTEM:
                    pipeline.add_many (system_sound);
                    system_sound.link_many (caps_filter, encoder);
                    break;
                case SourceDevice.BOTH:
                    var mixer = Gst.ElementFactory.make ("audiomixer", "mixer");
                    pipeline.add_many (mic_sound, system_sound, mixer);
                    mic_sound.get_static_pad ("src").link (mixer.get_request_pad ("sink_%u"));
                    system_sound.get_static_pad ("src").link (mixer.get_request_pad ("sink_%u"));
                    mixer.link_many (caps_filter, encoder);
                    break;
                default:
                    assert_not_reached ();
            }

            if (muxer != null) {
                pipeline.add (muxer);
                encoder.get_static_pad ("src").link (muxer.get_request_pad ("audio_%u"));
                muxer.link (sink);
            } else {
                encoder.link (sink);
            }
            pipeline.get_bus ().add_watch (Priority.DEFAULT, bus_message_cb);
            if (pipeline.set_state (Gst.State.PLAYING) == Gst.StateChangeReturn.FAILURE) {
                warning("Cannot record");
            } else {
                debug ("Recording...");
            }
        }

        private bool bus_message_cb (Gst.Bus bus, Gst.Message msg) {
            switch (msg.type) {
                case Gst.MessageType.ERROR:
                    cancel_recording ();
    
                    Error err;
                    string debug;
                    msg.parse_error (out err, out debug);
    
                    //handle_error (err, debug);

                    warning ("%s. More Details: %s", err.message, debug);
                    break;
                case Gst.MessageType.EOS:
                    pipeline.set_state (Gst.State.NULL);
                    pipeline.dispose ();
    
                    handle_recording_complete (tmp_full_path);
                    break;
                default:
                    break;
            }
    
            return true;
        }

        public void cancel_recording () {
            pipeline.set_state (Gst.State.NULL);
            pipeline.dispose ();
    
            // Remove canceled file in /tmp
            try {
                File.new_for_path (tmp_full_path).delete ();
            } catch (Error e) {
                warning (e.message);
            }
        }
    
        public void stop_recording () {
            pipeline.send_event (new Gst.Event.eos ());
            debug ("Stopping");
        }
    }
}
