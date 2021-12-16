/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core {
    public class AudioDriverSniffer {
        #if PIPEWIRE_CORE_DRIVER
        public static bool get_is_pipewire_available () {
            string info = "";
            try {
                Process.spawn_command_line_sync ("env LANG=C pw-cli --version", out info);
                if (info.contains ("Linked with libpipewire ")) {
                    print ("PipeWire detected!\n");
                    pipewire_driver_found = 1;
                    return true;
                } else {
                    pipewire_driver_found = 0;
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
                    pulseaudio_driver_found = 1;
                    return true;
                } else {
                    pulseaudio_driver_found = 0;
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
                    pipewire_pulse_driver_found = 1;
                    if (pulseaudio_driver_found == 1) {
                        pulseaudio_driver_found = 0;
                    }
                    return true;
                } else {
                    pipewire_pulse_driver_found = 0;
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
                    alsa_driver_found = 1;
                    return true;
                } else {
                    alsa_driver_found = 0;
                }
            } catch (Error e) {
                warning (e.message);
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
        }

        public static void initialize_drivers (string driver_name, double period_size) {
            driver_settings_provider_init (driver_name, period_size);
        }

        public static int change_period_size (double period_size) {
            return driver_settings_change_period_size (period_size);
        }

        public static string get_available_driver (string driver_from_settings) {
            string driver_string = "";
            switch (driver_from_settings) {
                case "alsa":
                if (alsa_driver_found > 0) {
                    driver_string = "alsa";
                }
                break;
                case "pulseaudio":
                if (pulseaudio_driver_found > 0) {
                    driver_string = "pulseaudio";
                }
                break;
                case "pipewire":
                if (pipewire_driver_found > 0) {
                    driver_string = "pipewire";
                }
                break;
                case "pipewire-pulse":
                if (pipewire_pulse_driver_found > 0) {
                    driver_string = "pipewire-pulse";
                }
                break;
            }
            if (driver_string == "") {
                if (alsa_driver_found > 0) {
                    return "alsa";
                }
                if (pulseaudio_driver_found > 0) {
                    return "pulseaudio";
                }
                if (pipewire_driver_found > 0) {
                    return "pulseaudio";
                }
                if (pipewire_pulse_driver_found > 0) {
                    return "pipewire-pulse";
                }
            }
            return driver_string;
        }
    }
}

extern int alsa_driver_found;
extern int pulseaudio_driver_found;
extern int pipewire_driver_found;
extern int pipewire_pulse_driver_found;

extern void driver_settings_provider_init (string driver, double period_size);
extern int driver_settings_change_period_size (double period_size);
