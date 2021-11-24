/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

 namespace Ensembles.Core {
    public class Style : Object {
        public string path;
        public string name;
        public string genre;
        public int tempo;
        public int timesignature_n;
        public int timesignature_d;
        public Style (string path,
                      string name,
                      string genre,
                      int tempo,
                      int timesignature_n,
                      int timesignature_d) {
            this.path = path;
            this.name = name;
            this.genre = genre;
            this.tempo = tempo;
            this.timesignature_n = timesignature_n;
            this.timesignature_d = timesignature_d;
        }
    }
}
