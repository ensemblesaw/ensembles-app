
/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Models {
    /**
     * Data structure representing auto accompaniment styles
     */
    public struct Style {
        public string name;
        public string genre;
        public uint8 tempo;
        public uint8 time_signature_n;
        public uint8 time_signature_d;
        public string enstl_path;
        public string copyright_notice;
        public StylePart[] parts;

        public string to_string () {
            string output = "Style Object ->\n╭──────────────────────────────────────────────────────────\n";
            output += "│ \x1B[1m%s\x1B[0m, Genre: %s\n".printf (name, genre);
            output += "│ Tempo: %u BPM, Time Signature: %u/%u\n".printf (tempo, time_signature_n, time_signature_d);
            output += "│ " + copyright_notice + "\n";
            output += "├──────────────────────────────────────────────────────────╮\n";
            output += "│                       STYLE  PARTS                       │\n";
            output += "┢━━━━━━━━━━┯━━━━━━━━━━━┯━━━━━━━━━━━┯━━━━━━━━━━━┯━━━━━━━━━━━┪\n";
            output += "┃PART      │     1     │     2     │     3     │     4     ┃\n";
            output += "┡┅┅┅┅┅┅┅┅┅┅┿┅┅┅┅┅┅┅┅┅┅┅┿┅┅┅┅┅┅┅┅┅┅┅┿┅┅┅┅┅┅┅┅┅┅┅┿┅┅┅┅┅┅┅┅┅┅┅┩\n";
            output += "│INTRO     │  %07u  │  %07u  │  %07u  │           │\n".printf (
                2 * parts[0].time_stamp, 2 * parts[1].time_stamp, 2 * parts[2].time_stamp
            );
            output += "│VARIATION │  %07u  │  %07u  │  %07u  │  %07u  │\n".printf (
                2 * parts[4].time_stamp, 2 * parts[6].time_stamp, 2 * parts[8].time_stamp, 2 * parts[10].time_stamp
            );
            output += "│FILL-IN   │  %07u  │  %07u  │  %07u  │  %07u  │\n".printf (
                2 * parts[5].time_stamp, 2 * parts[7].time_stamp, 2 * parts[9].time_stamp, 2 * parts[11].time_stamp
            );
            output += "│BREAK     │  %07u  │           │           │           │\n".printf (
                2 * parts[3].time_stamp
            );
            output += "│ENDING    │  %07u  │  %07u  │  %07u  │           │\n".printf (
                2 * parts[12].time_stamp, 2 * parts[14].time_stamp, 2 * parts[16].time_stamp
            );
            output += "│EOS       │  %07u  │  %07u  │  %07u  │           │\n".printf (
                2 * parts[13].time_stamp, 2 * parts[15].time_stamp, 2 * parts[17].time_stamp
            );
            output += "╰──────────┴───────────┴───────────┴───────────┴───────────╯\n";

            return output;
        }
    }
}
