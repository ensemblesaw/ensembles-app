/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Services {
    public class Settings : GLib.Settings {
        public Settings () {
            Object (schema_id: Constants.APP_ID);
        }

        public string version {
            owned get { return get_string ("version"); }
            set { set_string ("version", value); }
        }

        //  public uint8 tempo {
        //      owned get { return (uint8)get_uint ("tempo"); }
        //      set { set_uint ("tempo", value); }
        //  }

        public bool autofill {
            get { return get_boolean ("autofill"); }
            set { set_boolean ("autofill", value); }
        }
    }
}
