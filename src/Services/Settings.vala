/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
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

        // Main Window /////////////////////////////////////////////////////////
        /** The saved x-position of the window. */
        public int window_x {
            get { return get_int ("window-x"); }
            set { set_int ("window-x", value); }
        }

        /** The saved y-position of the window. */
        public int window_y {
            get { return get_int ("window-y"); }
            set { set_int ("window-y", value); }
        }

        /** The saved width of the window. */
        public int window_w {
            get { return get_int ("window-w"); }
            set { set_int ("window-w", value); }
        }

        /** The saved height of the window. */
        public int window_h {
            get { return get_int ("window-h"); }
            set { set_int ("window-h", value); }
        }

        /** If window should be maximized */
        public bool window_maximized {
            get { return get_boolean ("window-maximized"); }
            set { set_boolean ("window-maximized", value); }
        }

        /** Info Display theme */
        public string display_theme {
            owned get { return get_string ("display-theme"); }
            set { set_string ("display-theme", value); }
        }

        // Arranger Core ///////////////////////////////////////////////////////
        /** Enstl style path of the last used style*/
        public string style_path {
            owned get { return get_string ("style-path"); }
            set { set_string ("style-path", value); }
        }

        // Style Engine ////////////////////////////////////////////////////////
        /**
         * If autofill is `true`, then style engine automatically adds a fill-in
         * when switching between variations.
         */
        public bool autofill {
            get { return get_boolean ("autofill"); }
            set { set_boolean ("autofill", value); }
        }

        /**
         * How chord should be interpreted from the keyboard input.
         *
         * - `SPLIT_LONG`: Determine chord from multiple keys only on left side
         * of split point
         * - `SPLIT_SHORT`: Determine chord from two fingers only on left side
         * of split point
         * - `FULL_RANGE`: Determine chord from multiple fingers from any place
         * on the keyboard
         */
        public Core.Analysers.ChordAnalyser.ChordDetectionMode chord_detection_mode {
            get { return get_enum ("chord-detection-mode"); }
            set { set_enum ("chord-detection-mode", value); }
        }
    }
}
