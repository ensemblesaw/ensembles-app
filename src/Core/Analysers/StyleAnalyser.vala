/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Models;

namespace Ensembles.Core.Analysers {
    /**
     * A style analyser can analyse an `enstl` style and describe it.
     * The analysis takes place when the object is created using the given path
     * and the resulting `Style` object can be retreived using the
     * `get_style ()` method.
     */
    public class StyleAnalyser : Object {
        public bool valid = false;

        private string enstl_path;
        private string name;
        private string genre;
        private uint8[] copyright_notice;
        private uint8 time_signature_n;
        private uint8 time_signature_d;
        private uint32 ticks_per_beat;
        private uint32 tempo_ms;
        private bool scale_type;
        private StylePart[] parts;

        private const string[] EXPECTED_PARTS = {
            "CONFIG",
            "INT_1",
            "INT_2",
            "INT_3",
            "BRK",
            "VAR_A",
            "FILL_A",
            "VAR_B",
            "FILL_B",
            "VAR_C",
            "FILL_C",
            "VAR_D",
            "FILL_D",
            "END_1",
            "EOS",
            "END_2",
            "EOS",
            "END_3",
            "EOS"
        };

        /**
         * Creates a new `StyleAnalyser` object for analysing the style in the
         * given path.
         *
         * @param enstl_path path to the enstl file
         */
        public StyleAnalyser (string enstl_path) throws StyleError, Error {
            this.enstl_path = enstl_path;

            var file_tokens = enstl_path.split ("/");
            string file_name = file_tokens[file_tokens.length - 1];
            int file_name_delimit_index = file_name.index_of_char ('@');
            genre = file_name.substring (0, file_name_delimit_index);
            name = file_name.substring (file_name_delimit_index + 1,
                file_name.index_of_char ('.') - file_name_delimit_index - 1).replace ("_", " ");

            var style_file = File.new_for_path (enstl_path);

            if (!style_file.query_exists ()) {
                Console.log ("Style file is missing or invalid", Ensembles.Console.LogLevel.WARNING);
            }

            uint8[] buffer;

            var fs = style_file.read ();
            var dis = new DataInputStream (fs);
            dis.set_byte_order (GLib.DataStreamByteOrder.LITTLE_ENDIAN);

            dis.seek (0, GLib.SeekType.END);
            var filelen = dis.tell ();
            dis.seek (0, GLib.SeekType.SET);

            buffer = new uint8[filelen];

            if (!dis.read_all (buffer, out filelen)) {
                dis.close ();
                throw new StyleError.INVALID_FILE ("Failed to read style file. Make sure the file is accessible");
            }

            dis.close ();


            ticks_per_beat = 0;
            parts = new StylePart[18];
            uint8 expected_part_index = 0;
            uint8 marker_index = 0;
            bool default_tempo_acquired = false;

            for (uint64 i = 0; i < filelen; i++) {
                // Find ticks per beat from MTHD header
                if (buffer[i] == 0x4D && buffer[i + 1] == 0x54 && buffer[i + 2] == 0x68 && buffer[i + 3] == 0x64) {
                    uint8 a = buffer[i + 12];
                    uint8 b = buffer[i + 13];
                    ticks_per_beat = (a << 8) | (b & 0x000000FF);
                }

                // Get Meta Events
                if (ticks_per_beat > 0 && buffer[i] == 0xFF) {
                    // Find copyright notice
                    if (buffer[i + 1] == 0x02) {
                        uint8 copyright_str_len = buffer[i + 2];

                        copyright_notice = new uint8[copyright_str_len];
                        for (uint8 j = 0; j < copyright_str_len; j++) {
                            copyright_notice[j] = buffer[i + 3 + j];
                        }
                    }

                    // Get default tempo
                    if (!default_tempo_acquired && buffer[i + 1] == 0x51) {
                        tempo_ms = get_tempo (buffer, i + 2);
                        default_tempo_acquired = true;
                    }

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

                        uint measure = 0;
                        if (marker_token_index > 0 && marker_token_index < marker_str_length) {
                            measure = uint.parse (str.substring (marker_token_index + 1,
                                scale_type_index < marker_str_length
                                ? scale_type_index - marker_token_index - 1: -1));
                        }

                        int i_scale_type = 0;
                        if (scale_type_index > 0 && scale_type_index < marker_str_length) {
                            i_scale_type = int.parse (str.substring (scale_type_index + 1));
                        }
                        scale_type = i_scale_type > 0;

                        var marker_name = str.substring (0, marker_token_index);

                        if (marker_name[0] != 'C') {
                            parts[marker_index++] = StylePart () {
                                time_stamp = (uint)(((measure - 1) * 4 * time_signature_n * ticks_per_beat)
                                    / time_signature_d),
                                style_part_type = get_style_part_type_from_marker (marker_name)
                            };
                        }

                        if (marker_name != EXPECTED_PARTS[expected_part_index++]) {
                            if (expected_part_index == 1) {
                                throw new StyleError.INVALID_LAYOUT ("Expected config marker");
                            } else {
                                throw new StyleError.INVALID_LAYOUT ("Expected %s marker after %s marker",
                                EXPECTED_PARTS[expected_part_index - 1], EXPECTED_PARTS[expected_part_index - 2]);
                            }
                        }
                    }
                }
            }
        }

        /**
         * Get the analysed style object
         */
        public Style get_style () {
            return Style () {
                name = this.name,
                genre = this.genre,
                tempo = (uint8)(60000000 / this.tempo_ms),
                time_signature_n = this.time_signature_n,
                time_signature_d = this.time_signature_d,
                time_resolution = this.ticks_per_beat,
                enstl_path = this.enstl_path,
                copyright_notice = (string)this.copyright_notice,
                scale_type = this.scale_type ? ChordType.MINOR : ChordType.MAJOR,
                parts = this.parts
            };
        }

        //  private uint32 get_variable_length_value (uint8[] buffer, uint64 offset) {
        //      uint32 value = buffer[offset];

        //      uint8 c = 0xFF;
        //      uint i = 0;

        //      if ((value & 0x80) > 0) {
        //          value &= 0x7F;
        //          do {
        //              c = buffer[offset + (i++)];
        //              value = (value << 7) | (c & 0x7F);
        //          } while ((c & 0x80) > 0);
        //      }

        //      return value;
        //  }

        private uint32 get_tempo (uint8[] buffer, uint64 offset) {
            uint8 len = buffer[offset];

            uint32 tempo = 0;
            for (uint8 i = 1; i <= len; i++) {
                tempo = (tempo << 8) | buffer[offset + i];
            }

            return tempo;
        }

        private StylePartType get_style_part_type_from_marker (string marker) {
            switch (marker) {
                case "INT_1":
                return (StylePartType.INTRO_1);
                case "INT_2":
                return (StylePartType.INTRO_2);
                case "INT_3":
                return (StylePartType.INTRO_3);
                case "BRK":
                return (StylePartType.BREAK);
                case "VAR_A":
                return (StylePartType.VARIATION_A);
                case "VAR_B":
                return (StylePartType.VARIATION_B);
                case "VAR_C":
                return (StylePartType.VARIATION_C);
                case "VAR_D":
                return (StylePartType.VARIATION_D);
                case "FILL_A":
                return (StylePartType.FILL_A);
                case "FILL_B":
                return (StylePartType.FILL_B);
                case "FILL_C":
                return (StylePartType.FILL_C);
                case "FILL_D":
                return (StylePartType.FILL_D);
                case "END_1":
                return (StylePartType.ENDING_1);
                case "END_2":
                return (StylePartType.ENDING_2);
                case "END_3":
                return (StylePartType.ENDING_3);
            }

            return (StylePartType.EOS);
        }
    }
}
