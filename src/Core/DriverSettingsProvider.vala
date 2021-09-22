/*-
 * Copyright (c) 2021-2022 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License 
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
 */

namespace Ensembles.Core {
    public class DriverSettingsProvider {
        public static bool pipewire_found = false;
        public static bool get_is_pipewire_available () {
            string info = "";
            try {
                Process.spawn_command_line_sync ("env LANG=C pw-cli --version", out info);
                if (info.contains ("Linked with libpipewire ")) {
                    print ("PipeWire detected!\n");
                    pipewire_found = true;
                    return true;
                }
            } catch (Error e) {
                warning (e.message);
            }
            return false;
        }
        public static bool pipewire_pulse_found = false;
        public static bool get_is_pipewire_pulse_available () {
            string info = "";
            try {
                Process.spawn_command_line_sync ("env LANG=C pactl info", out info);
                if (info.contains ("PulseAudio (on PipeWire")) {
                    print ("PipeWire Pulse detected!\n");
                    pipewire_pulse_found = true;
                    return true;
                }
            } catch (Error e) {
                warning (e.message);
            }
            return false;
        }
        public static bool alsa_found = false;
        public static bool get_is_alsa_available () {
            string info = "";
            try {
                Process.spawn_command_line_sync ("env LANG=C aplay --version", out info);
                if (info.contains ("aplay: version ")) {
                    print ("Alsa detected!\n");
                    alsa_found = true;
                    return true;
                }
            } catch (Error e) {
                warning (e.message);
            }
            return false;
        }
        public static void check_drivers () {

        }
    }
}
