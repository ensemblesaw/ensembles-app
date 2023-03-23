/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core.Plugins {
    /**
     * The base plugin type.
     *
     * A plugin is used to add additional functionality
     * or features to ensembles.
     */
    public abstract class Plugin : Object {
        public string name;
        public string author_name;
        public string author_email;
        public string author_homepage;

        private bool _active;

        /**
         * The plugin will only work if it's active
         */
        public bool active {
            get {
                return _active;
            }
            set {
                _active = value;
                if (value) {
                    activate ();
                } else {
                    deactivate ();
                }
            }
        }

        private Gtk.Widget _plugin_ui;

        public Gtk.Widget plugin_ui {
            get {
                return _plugin_ui;
            }
            protected set {
                _plugin_ui = value;
            }
        }

        protected Plugin () {
            active = false;
            instantiate ();
        }

        /**
         * This function is called when the plugin is instantiated.
         * This just means that the plugin data is created. A Plugin cannot be
         * used without instantiation.
         */
        public abstract void instantiate ();

        protected abstract void activate ();

        protected abstract void deactivate ();
    }
}
