
/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
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
        public uint32 time_resolution;
        public string enstl_path;
        public string copyright_notice;
        public ChordType scale_type;
        public StylePart[] parts;

        public string to_string () {
            string output = "Style Object ->\n╭──────────────────────────────────────────────────────────╮\n";
            output += "│ \x1B[1m%s\x1B[0m, Genre: %s".printf (name, genre);
            for (uint8 i = 0; i < 48 - (name.length + genre.length); i++) {output += " ";}
            output += "│\n";
            output += "│ Tempo: %u BPM, Time Signature: %u/%u".printf (tempo, time_signature_n, time_signature_d);
            for (
                uint8 i = 0;
                i < 27 - (tempo.to_string ().length + time_signature_n.to_string ().length
                + time_signature_d.to_string ().length);
                i++
            ) { output += " "; }
            output += "│\n";
            output += "│ " + copyright_notice;
            if (copyright_notice.length < 60) {
                for (
                    uint8 i = 0;
                    i < 57 - copyright_notice.length;
                    i++
                ) { output += " "; }
                output += "│";
            }

            output += "\n┢━━━━━━━━━━┯━━━━━━━━━━━┯━━━━━━━━━━━┯━━━━━━━━━━━┯━━━━━━━━━━━┪\n";
            output += "┃PART      │     1     │     2     │     3     │     4     ┃\n";
            output += "┡┅┅┅┅┅┅┅┅┅┅┿┅┅┅┅┅┅┅┅┅┅┅┿┅┅┅┅┅┅┅┅┅┅┅┿┅┅┅┅┅┅┅┅┅┅┅┿┅┅┅┅┅┅┅┅┅┅┅┩\n";
            output += "│INTRO     │  %07u  │  %07u  │  %07u  │    N/A    │\n".printf (
                2 * parts[0].time_stamp, 2 * parts[1].time_stamp, 2 * parts[2].time_stamp
            );
            output += "│VARIATION │  %07u  │  %07u  │  %07u  │  %07u  │\n".printf (
                2 * parts[4].time_stamp, 2 * parts[6].time_stamp, 2 * parts[8].time_stamp, 2 * parts[10].time_stamp
            );
            output += "│FILL-IN   │  %07u  │  %07u  │  %07u  │  %07u  │\n".printf (
                2 * parts[5].time_stamp, 2 * parts[7].time_stamp, 2 * parts[9].time_stamp, 2 * parts[11].time_stamp
            );
            output += "│BREAK     │  %07u  │    N/A    │    N/A    │    N/A    │\n".printf (
                2 * parts[3].time_stamp
            );
            output += "│ENDING    │  %07u  │  %07u  │  %07u  │    N/A    │\n".printf (
                2 * parts[12].time_stamp, 2 * parts[14].time_stamp, 2 * parts[16].time_stamp
            );
            output += "│EOS       │  %07u  │  %07u  │  %07u  │    N/A    │\n".printf (
                2 * parts[13].time_stamp, 2 * parts[15].time_stamp, 2 * parts[17].time_stamp
            );
            output += "╰──────────┴───────────┴───────────┴───────────┴───────────╯";

            return output;
        }

        /**
         * Updates a given hash table with `StylePartType` as the key and the
         * part bounds as the value.
         */
        public void update_part_hash_table (HashTable<StylePartType, StylePartBounds?>? hash_table) {
            for (uint8 i = 0; i < parts.length; i++) {
                hash_table.insert (parts[i].style_part_type, StylePartBounds () {
                    start = (int)parts[i].time_stamp,
                    end = (int)parts[i + 1].time_stamp
                });
            }
        }
    }
}
