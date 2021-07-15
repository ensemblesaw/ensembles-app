/*-
 * Copyright (c) 2021-2022 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License 
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
 */

namespace Ensembles.Core {
    public class VoiceAnalyser : Object {
        Voice[] voices;
        int[] category_indices;
        public VoiceAnalyser (string sf_path, string sf_schema_path) {
            FileStream stream = FileStream.open (sf_schema_path, "r");

            if (voice_analyser_init (sf_path) == 0) {
                voices = new Voice[0];
                category_indices = new int[0];
                int i = 0, j = 0;
                string? line = "";
                line = stream.read_line ();
                string category = "";
                while (voice_analyser_next () > 0) {
                    voices.resize (voices.length + 1);
                    if (line != null) {
                        string[] parts = line.split (",");
                        int bank = int.parse (parts[0]);
                        int preset = int.parse (parts[1]);
                        if (bank == sf_preset_bank_num && preset == sf_preset_num) {
                            category = parts[2];
                            category_indices.resize (category_indices.length + 1);
                            category_indices[j++] = i;
                            line = stream.read_line ();
                        }
                    }
                    voices[i] = new Voice (i, sf_preset_bank_num, sf_preset_num, sf_preset_name, category);
                    i++;
                }
            } else {
                warning ("Soundfont is invalid");
            }
        }

        public Voice[] get_all_voices () {
            return this.voices;
        }

        public int[] get_all_category_indices () {
            return this.category_indices;
        }

        ~VoiceAnalyser () {
            voice_analyser_deconstruct ();
        }
    }
}

extern int voice_analyser_init (string sf_path);
extern int voice_analyser_next ();
extern void voice_analyser_deconstruct ();


// Data
extern string sf_preset_name;
extern int sf_preset_bank_num;
extern int sf_preset_num;
