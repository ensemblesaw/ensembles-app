/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
/*
* Adapted from Melody by Artem Anufrij <artem.anufrij@live.de>
*/

// vala-lint=skip-file

namespace Ensembles.Interfaces {
    [DBus (name = "org.gnome.SettingsDaemon.MediaKeys")]
    public interface GnomeMediaKeys : GLib.Object {
        public abstract void GrabMediaPlayerKeys (string application, uint32 time) throws Error;
        public abstract void ReleaseMediaPlayerKeys (string application) throws Error;
        public signal void MediaPlayerKeyPressed (string application, string key);
    }

    public class MediaKeyListener : GLib.Object {
        public static MediaKeyListener instance { get; private set; }
        public signal void media_key_pressed_play ();
        public signal void media_key_pressed_pause ();
        public signal void media_key_pressed_prev ();

        private GnomeMediaKeys? media_keys;

        construct {
            assert (media_keys == null);

            try {
                media_keys = Bus.get_proxy_sync (BusType.SESSION, "org.gnome.SettingsDaemon", "/org/gnome/SettingsDaemon/MediaKeys");
            } catch (Error e) {
                warning ("Mediakeys error: %s", e.message);
            }

            if (media_keys != null) {
                media_keys.MediaPlayerKeyPressed.connect (pressed_key);
                try {
                    media_keys.GrabMediaPlayerKeys (Ensembles.Application.instance.application_id, (uint32)0);
                }
                catch (Error err) {
                    warning ("Could not grab media player keys: %s", err.message);
                }
            }
        }

        private MediaKeyListener () {}

        public static MediaKeyListener listen () {
            instance = new MediaKeyListener ();
            return instance;
        }

        private void pressed_key (dynamic Object bus, string application, string key) {
            if (application == (Ensembles.Application.instance.application_id)) {
                if (key == "Previous") {
                    media_key_pressed_prev ();
                }
                else if (key == "Play") {
                    media_key_pressed_play ();
                }
                else if (key == "Pause") {
                    media_key_pressed_pause ();
                }
            }
        }
    }
}
