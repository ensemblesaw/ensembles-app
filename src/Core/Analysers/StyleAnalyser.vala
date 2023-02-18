using Ensembles.Models;

namespace Ensembles.Core.Analysers {
    public class StyleAnalyser : Object {
        public bool valid = false;

        //  private const char[] config_delimiters = { ':', ';', ',' };

        private string enstl_path;
        private string name;
        private string genre;
        private uint8[] copyright_notice;
        private uint8 time_signature_n;
        private uint8 time_signature_d;
        private MIDIMarker[] markers;

        public StyleAnalyser (string enstl_path) {
            this.enstl_path = enstl_path;

            var file_tokens = enstl_path.split ("/");
            string file_name = file_tokens[file_tokens.length - 1];
            genre = file_name.substring (0, file_name.index_of_char ('@'));
            name = file_name.substring (file_name.index_of_char ('@') + 1, file_name.index_of_char ('.'));

            var style_file = File.new_for_path (enstl_path);

            if (!style_file.query_exists ()) {
                Console.log ("Style file is missing or invalid", Ensembles.Console.LogLevel.WARNING);
            }

            uint8[] buffer;

            try {
                var fs = style_file.read ();
                var dis = new DataInputStream (fs);
                dis.set_byte_order (GLib.DataStreamByteOrder.LITTLE_ENDIAN);

                dis.seek (0, GLib.SeekType.END);
                var filelen = dis.tell ();
                dis.seek (0, GLib.SeekType.SET);

                buffer = new uint8[filelen];

                if (!dis.read_all (buffer, out filelen)) {

                }

                dis.close ();

                uint ticks_per_beat = 0;
                markers = new MIDIMarker[18];
                uint8 marker_index = 0;

                for (uint64 i = 0; i < filelen; i++) {
                    // Find copyright notice
                    if (buffer[i] == 0xFF && buffer[i + 1] == 0x02) {
                        uint8 copyright_str_len = buffer[i + 2];

                        copyright_notice = new uint8[copyright_str_len];
                        for (uint8 j = 0; j < copyright_str_len; j++) {
                            copyright_notice[j] = buffer[i + 3 + j];
                        }
                    }

                    // Find ticks per beat from MTHD header
                    if (buffer[i] == 0x4D && buffer[i + 1] == 0x54 && buffer[i + 2] == 0x68 && buffer[i + 3] == 0x64) {
                        uint8 a = buffer[i + 12];
                        uint8 b = buffer[i + 13];
                        ticks_per_beat = (a << 8) | (b & 0x000000FF);
                    }

                    if (ticks_per_beat > 0 && buffer[i] == 0xFF) {
                        // Find time signature
                        if (buffer[i + 1] == 0x58 && buffer[i + 2] == 0x04) {
                            time_signature_n = buffer[i + 3];
                            time_signature_d = (uint8)Math.pow (2, buffer[i + 4]);
                        }

                        // Get marker data
                        if (buffer[i + 1] == 0x06) {
                            uint8 marker_str_length = buffer[i + 2];
                            uint8[] marker_str = new uint8[marker_str_length];

                            for (uint8 j = 0; j < marker_str_length; j++) {
                                marker_str[j] = buffer[i + 3 + j];
                            }

                            string str = (string)marker_str;
                            // Get measure
                            int marker_token_index = str.index_of_char (':');

                            int scale_type_index = str.index_of_char (';');

                            int measure = 0;
                            if (marker_token_index > 0 && marker_token_index < marker_str_length) {
                                measure = int.parse (str.substring (marker_token_index,
                                    scale_type_index < marker_str_length ? scale_type_index : marker_str_length));
                            }

                            int scale_type = 0;
                            if (scale_type_index > 0 && scale_type_index < marker_str_length) {
                                scale_type = int.parse (str.substring (scale_type_index));
                            }

                            markers[marker_index++] = MIDIMarker () {
                                time_stamp = (uint16)(((measure - 1) * 4 * time_signature_n  * ticks_per_beat)
                                    / time_signature_d),
                                marker_name = str.substring (0, marker_token_index)
                            };
                        }
                    }
                }
            } catch (Error r) {

            }
        }

        public Style get_style () {
            return Style () {
                name = this.name,
                genre = this.genre,
                tempo = 0,
                time_signature_n = this.time_signature_n,
                time_signature_d = this.time_signature_d,
                enstl_path = this.enstl_path,
                copyright_notice = (string)this.copyright_notice
            };
        }
    }
}
