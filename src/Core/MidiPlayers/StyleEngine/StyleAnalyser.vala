/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core {
    public class StyleAnalyser {
        public int time_sig_n {
            get {
                return time_signature_n;
            }
        }

        public int time_sig_d {
            get {
                return time_signature_d;
            }
        }

        public string copyright_notice {
            get {
                return copyright_string;
            }
        }

        public int analyze_style (string mid_file) {
            return style_analyser_analyze (mid_file);
        }
    }
}

extern int style_analyser_analyze (string mid_file);

extern int time_signature_n;
extern int time_signature_d;
extern string copyright_string;
