/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
/*
* Adapted from Melody by Artem Anufrij <artem.anufrij@live.de>
*/

// vala-lint=skip-file

 namespace Ensembles.Interfaces {
    public class SoundIndicator {
        public static SoundIndicator instance { get; private set; }
        public static SoundIndicator listen (Shell.MainWindow main_window) {
            instance = new SoundIndicator ();
            instance.initialize (main_window);
            return instance;
        }

        SoundIndicatorPlayer player;
        SoundIndicatorRoot root;

        unowned DBusConnection conn;
        uint owner_id;
        uint root_id;
        uint player_id;

        Shell.MainWindow main_window;

        private void initialize (Shell.MainWindow main_window) {
            owner_id = Bus.own_name (BusType.SESSION,
                                    "org.mpris.MediaPlayer2.com.github.subhadeepjasu.ensembles",
                                    GLib.BusNameOwnerFlags.NONE,
                                    on_bus_acquired,
                                    null,
                                    null);
            if (owner_id == 0) {
                warning ("Could not initialize MPRIS session.\n");
            }
            this.main_window = main_window;
            main_window.close_request.connect (() => {
                this.conn.unregister_object (root_id);
                this.conn.unregister_object (player_id);
                Bus.unown_name (owner_id);
            });
        }

        private void on_bus_acquired (DBusConnection connection, string name) {
            this.conn = connection;
            try {
                root = new SoundIndicatorRoot ();
                root_id = connection.register_object ("/org/mpris/MediaPlayer2", root);
                player = new SoundIndicatorPlayer (connection, main_window);
                player_id = connection.register_object ("/org/mpris/MediaPlayer2", player);
            }
            catch (Error e) {
                warning ("could not create MPRIS player: %s\n", e.message);
            }
        }

        public void change_song_state (string song_name, Core.SongPlayer.PlayerStatus status) {
            player.player_state_changed (song_name, status);
        }
    }

    [DBus(name = "org.mpris.MediaPlayer2")]
    public class SoundIndicatorRoot : GLib.Object {
        Ensembles.Application app;

        construct {
            this.app = Ensembles.Application.instance;
        }

        public string DesktopEntry {
            owned get {
                return app.application_id;
            }
        }
    }

    [DBus(name = "org.mpris.MediaPlayer2.Player")]
    public class SoundIndicatorPlayer : GLib.Object {
        DBusConnection connection;
        Ensembles.Application app;
        Shell.MainWindow main_window;

        public SoundIndicatorPlayer (DBusConnection connection, Shell.MainWindow main_window) {
            this.app = Ensembles.Application.instance;
            this.main_window = main_window;
            this.connection = connection;
        }

        private static string[] get_simple_string_array (string text) {
            string[] array = new string[0];
            array += text;
            return array;
        }

        private void send_properties (string property, Variant val) {
            var property_list = new HashTable<string,Variant> (str_hash, str_equal);
            property_list.insert (property, val);

            var builder = new VariantBuilder (VariantType.ARRAY);
            var invalidated_builder = new VariantBuilder (new VariantType("as"));

            foreach(string name in property_list.get_keys ()) {
                Variant variant = property_list.lookup (name);
                builder.add ("{sv}", name, variant);
            }

            try {
                connection.emit_signal (null,
                                  "/org/mpris/MediaPlayer2",
                                  "org.freedesktop.DBus.Properties",
                                  "PropertiesChanged",
                                  new Variant("(sa{sv}as)", "org.mpris.MediaPlayer2.Player", builder, invalidated_builder));
            }
            catch(Error e) {
                print("Could not send MPRIS property change: %s\n", e.message);
            }
        }

        public bool CanGoNext { get { return false; } }

        public bool CanGoPrevious { get { return true; } }

        public bool CanPlay { get { return true; } }

        public bool CanPause { get { return true; } }

        public void PlayPause () throws Error {
            main_window.media_toggle_play ();
        }

        public void Next () throws Error {
            // Do nothing
        }

        public void Previous() throws Error {
            main_window.media_prev ();
        }

        public void player_state_changed (string song_name, Core.SongPlayer.PlayerStatus status) {
            Variant property;
            if (status == Core.SongPlayer.PlayerStatus.PLAYING) {
                property = "Playing";
                var metadata = new HashTable<string, Variant> (null, null);
                metadata.insert("xesam:title", "Ensembles Song Player");
                metadata.insert("xesam:artist", get_simple_string_array(song_name));
                send_properties ("Metadata", metadata);
            } else {
                property = "Stopped";
                var metadata = new HashTable<string, Variant> (null, null);
                metadata.insert("xesam:title", "Ensembles Song Player");
                metadata.insert("xesam:artist", get_simple_string_array("Not Playing"));
                send_properties ("Metadata", metadata);
            }
            send_properties ("PlaybackStatus", property);
        }
    }
}
