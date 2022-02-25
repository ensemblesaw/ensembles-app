/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core {
    public class AudioDriverSniffer {
        public static bool alsa_driver_found;
        public static bool pulseaudio_driver_found;
        public static bool jack_driver_found;
        public static bool pipewire_driver_found;
        public static bool pipewire_pulse_driver_found;
        #if PIPEWIRE_CORE_DRIVER
        public static bool get_is_pipewire_available () {
            string info = "";
            try {
                Process.spawn_command_line_sync ("env LANG=C pw-cli --version", out info);
                if (info.contains ("Linked with libpipewire ")) {
                    print ("PipeWire detected!\n");
                    pipewire_driver_found = true;
                    return true;
                } else {
                    pipewire_driver_found = false;
                }
            } catch (Error e) {
                warning (e.message);
            }
            return false;
        }
        #endif
        #if PULSEAUDIO_DRIVER
        public static bool get_is_pulseaudio_available () {
            string info = "";
            try {
                Process.spawn_command_line_sync ("env LANG=C pactl info", out info);
                if (info.contains ("Server Name: pulseaudio")) {
                    print ("PulseAudio detected!\n");
                    pulseaudio_driver_found = true;
                    return true;
                } else {
                    pulseaudio_driver_found = false;
                }
            } catch (Error e) {
                warning (e.message);
            }
            return false;
        }
        public static bool get_is_pipewire_pulse_available () {
            string info = "";
            try {
                Process.spawn_command_line_sync ("env LANG=C pactl info", out info);
                if (info.contains ("Server Name: PulseAudio (on PipeWire")) {
                    print ("PipeWire Pulse detected!\n");
                    pipewire_pulse_driver_found = true;
                    if (pulseaudio_driver_found) {
                        pulseaudio_driver_found = false;
                    }
                    return true;
                } else {
                    pipewire_pulse_driver_found = false;
                }
            } catch (Error e) {
                warning (e.message);
            }
            return false;
        }
        #endif
        #if ALSA_DRIVER
        public static bool get_is_alsa_available () {
            string info = "";
            try {
                Process.spawn_command_line_sync ("cat /proc/asound/version", out info);
                if (info.contains ("Advanced Linux Sound Architecture Driver Version")) {
                    print ("Alsa detected!\n");
                    alsa_driver_found = true;
                    return true;
                } else {
                    alsa_driver_found = false;
                }
            } catch (Error e) {
                warning (e.message);
            }
            return false;
        }
        #endif
        #if JACK_DRIVER
        public static bool get_is_jack_available () {
            if (!Ensembles.Application.get_is_running_from_flatpak ()) {
                print("Assuming Jack is available\n");
                jack_driver_found = true;
                return true;
            }
            return false;
        }
        #endif
        public static void check_drivers () {
            debug ("Detecting Drivers\n");
            #if ALSA_DRIVER
            get_is_alsa_available ();
            #endif
            #if PULSEAUDIO_DRIVER
            get_is_pulseaudio_available ();
            get_is_pipewire_pulse_available ();
            #endif
            #if PIPEWIRE_CORE_DRIVER
            get_is_pipewire_available ();
            #endif
            #if JACK_DRIVER
            get_is_jack_available ();
            #endif
        }

        public static string get_available_driver (string driver_from_settings) {
            string driver_string = "";
            switch (driver_from_settings) {
                case "alsa":
                if (alsa_driver_found) {
                    driver_string = "alsa";
                }
                break;
                case "pulseaudio":
                if (pulseaudio_driver_found) {
                    driver_string = "pulseaudio";
                }
                break;
                case "pipewire":
                if (pipewire_driver_found) {
                    driver_string = "pipewire";
                }
                break;
                case "pipewire-pulse":
                if (pipewire_pulse_driver_found) {
                    driver_string = "pipewire-pulse";
                }
                break;
                case "jack":
                if (pipewire_pulse_driver_found) {
                    driver_string = "jack";
                }
                break;
            }
            if (driver_string == "") {
                if (alsa_driver_found) {
                    return "alsa";
                }
                if (pulseaudio_driver_found) {
                    return "pulseaudio";
                }
                if (pipewire_driver_found) {
                    return "pulseaudio";
                }
                if (pipewire_pulse_driver_found) {
                    return "pipewire-pulse";
                }
                if (jack_driver_found) {
                    return "jack";
                }
            }
            return driver_string;
        }
    }
}
