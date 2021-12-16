/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Core {
    public class InstrumentRack : Object {
        static List<Ensembles.PlugIns.PlugIn> plugin_references;
        public static Voice[] plugin_voice_reference; // Used for referencing plugins using voice menu

        public static void populate_rack (PlugIns.PlugIn plugin) {
            plugin_references.append (plugin);
            if (plugin_voice_reference == null) {
                plugin_voice_reference = new Voice[0];
            }
            print ("%s\n", plugin.plug_name);
            plugin_voice_reference.resize (plugin_voice_reference.length + 1);
            var voice = new Voice (0, 10, (int)(plugin_references.length () - 1), plugin.plug_name, _("Plugin"));
            plugin_voice_reference[plugin_voice_reference.length - 1] = voice;
        }
    }
}
