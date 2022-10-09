/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core {
    public class VoiceAnalyser : Object {
        Voice[] voices;
        int[] category_indices;
        public signal void analysis_complete ();
        public void analyse (string sf_path, string sf_schema_path) {
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
                    Thread.usleep (10000);
                    if (Application.main_window != null) {
                        Application.main_window.main_display_unit.update_splash_text (
                            _("Loading Voice: ") + sf_preset_name
                        );
                    }
                    i++;
                }
                analysis_complete ();
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
    }
}

extern int voice_analyser_init (string sf_path);
extern int voice_analyser_next ();


// Data
extern string sf_preset_name;
extern int sf_preset_bank_num;
extern int sf_preset_num;
