/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Models;

namespace Ensembles.Core.Analysers {
    public class VoiceAnalyser : Object {
        private List<Voice?> voice_list;

        public VoiceAnalyser (
            AudioEngine.SynthProvider synth_provider,
            string sf_path,
            string sf_schema_path
        ) {
            voice_list = new List<Voice?> ();

            unowned Fluid.Synth sf_synth = synth_provider.utility_synth;
            unowned Fluid.SoundFont soundfont = sf_synth.get_sfont (0);


            FileStream stream = FileStream.open (sf_schema_path, "r");
            string? line = "";
            line = stream.read_line ();
            string category = "";

            uint index = 0;
            unowned Fluid.Preset sf_preset = null;
            soundfont.iteration_start ();
            sf_preset = soundfont.iteration_next ();
            while (sf_preset != null) {
                int preset_num = sf_preset.get_num ();
                int bank_num = sf_preset.get_banknum ();
                var voice_name = sf_preset.get_name ();

                if (line != null) {
                    var parts = line.split (",");
                    int schema_bank = int.parse (parts[0]);
                    int schema_preset = int.parse (parts[1]);

                    if (bank_num == schema_bank && preset_num == schema_preset) {
                        category = parts[2];
                        line = stream.read_line ();
                    }
                }

                voice_list.append (Voice () {
                    index = index++,
                    preset = preset_num,
                    bank = (uint8) bank_num,
                    name = voice_name,
                    category = category,
                    sf_path = sf_path
                });

                sf_preset = soundfont.iteration_next ();
            }
        }

        public owned Voice[] get_voices () {
            var n = voice_list.length ();
            var voices = new Voice[n];

            for (uint i = 0; i < n; i++) {
                var voice = voice_list.nth_data (i);
                voices[i] = Voice () {
                    name = voice.name,
                    category = voice.category,
                    sf_path = voice.sf_path,
                    preset = voice.preset,
                    bank = voice.bank,
                    index = voice.index
                };
            }

            return voices;
        }
    }
}
