/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
/*
 * This file incorporates work covered by the following copyright and
 * permission notices:
 *
 * ---
 *
  Copyright 2007-2016 David Robillard <http://drobilla.net>
  Permission to use, copy, modify, and/or distribute this software for any
  purpose with or without fee is hereby granted, provided that the above
  copyright notice and this permission notice appear in all copies.
  THIS SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  ---
 * Copyright (C) 2008-2012 Carl Hetherington <carl@carlh.net>
 * Copyright (C) 2008-2017 Paul Davis <paul@linuxaudiosystems.com>
 * Copyright (C) 2008-2019 David Robillard <d@drobilla.net>
 * Copyright (C) 2012-2019 Robin Gareus <robin@gareus.org>
 * Copyright (C) 2013-2018 John Emmas <john@creativepost.co.uk>
 * Copyright (C) 2013 Michael R. Fisher <mfisher@bketech.com>
 * Copyright (C) 2014-2016 Tim Mayberry <mojofunk@gmail.com>
 * Copyright (C) 2016-2017 Damien Zammit <damien@zamaudio.com>
 * Copyright (C) 2016 Nick Mainsbridge <mainsbridge@gmail.com>
 * Copyright (C) 2017 Johannes Mueller <github@johannes-mueller.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * ---
 */

namespace Ensembles.Core.Plugins.AudioPlugins.LADSPAV2 {
    /**
     * The LV2PortAnalyser object is used to analyse LV2 ports
     * and provide port descriptors which the plugin object can the use to
     * create the ports.
     */
    public class LV2PortAnalyser : Object {
        /**
         * The Lilv Plugin whose ports are being described.
         */
        unowned Lilv.Plugin lilv_plugin { get; protected set; }

        /**
         * These ports represents a buffer for storing dry audio.
         */
        public List<LV2Port> audio_in_port_list;
        /**
         * These ports represents a buffer for storing wet audio.
         */
        public List<LV2Port> audio_out_port_list;
        /**
         * These ports represents basic control input ports.
         */
        public List<LV2ControlPort> control_in_port_list;
        /**
         * These ports represents basic control output ports.
         */
        public List<LV2ControlPort> control_out_port_list;
        /**
         * These ports represents atom input ports.
         */
        public List<LV2AtomPort> atom_in_port_list;
        /**
         * These ports represents atom output ports.
         */
        public List<LV2AtomPort> atom_out_port_list;

        // Atom ports classifications
        public uint16 n_atom_midi_in_ports { get; private set; }
        public uint16 n_atom_midi_out_ports { get; private set; }

        /**
         * Creates a new `LV2PortAnalyser` instance.
         *
         * @param lilv_plugin the lilv plugin object whose ports to describe
         */
        public LV2PortAnalyser (Lilv.Plugin lilv_plugin) {
            this.lilv_plugin = lilv_plugin;
            fetch_ports ();
        }

        private void fetch_ports () {
            audio_in_port_list = new List<LV2Port> ();
            audio_out_port_list = new List<LV2Port> ();
            control_in_port_list = new List<LV2ControlPort> ();
            atom_in_port_list = new List<LV2AtomPort> ();
            atom_out_port_list = new List<LV2AtomPort> ();

            var n_ports = lilv_plugin.get_num_ports ();
            for (uint32 i = 0; i < n_ports; i++) {
                // Get port from plugin
                unowned Lilv.Port port = lilv_plugin.get_port_by_index (i);

                var name = lilv_plugin.port_get_name (port).as_string ();
                print ("port: " + name + "\n");
                var symbol = lilv_plugin.port_get_symbol (port).as_string ();
                var turtle_token = lilv_plugin.port_get_symbol (port).get_turtle_token ();
                var properties = get_port_properties (port);

                // Plugin class flags
                bool is_audio_port = false;
                bool is_input_port = false;
                bool is_output_port = false;
                bool is_control_port = false;
                bool is_atom_port = false;

                // Get all classes associated with this port
                unowned Lilv.Nodes port_classes = lilv_plugin.port_get_classes (port);

                for (var class_iter = port_classes.begin ();
                !port_classes.is_end (class_iter);
                class_iter = port_classes.next (class_iter)) {
                    switch (port_classes.get (class_iter).as_string ()) {
                        case LV2.Core._AudioPort:
                            is_audio_port = true;
                        break;
                        case LV2.Core._ControlPort:
                            is_control_port = true;
                        break;
                        case LV2.Atom._AtomPort:
                            is_atom_port = true;
                        break;
                        case LV2.Core._InputPort:
                            is_input_port = true;
                        break;
                        case LV2.Core._OutputPort:
                            is_output_port = true;
                        break;
                    }
                }

                if (is_audio_port) {
                    if (is_input_port) {
                        audio_in_port_list.append (new LV2Port (
                            name,
                            i,
                            properties,
                            symbol,
                            turtle_token
                        ));
                    } else if (is_output_port) {
                        audio_out_port_list.append (new LV2Port (
                            name,
                            i,
                            properties,
                            symbol,
                            turtle_token
                        ));
                    }
                } else if (is_control_port) {
                    Lilv.Node default_value;
                    Lilv.Node min_value;
                    Lilv.Node max_value;

                    lilv_plugin.port_get_range (port, out default_value, out min_value, out max_value);

                    if (is_input_port) {
                        control_in_port_list.append (new LV2ControlPort (
                            name,
                            i,
                            properties,
                            symbol,
                            turtle_token,
                            min_value.as_float (),
                            max_value.as_float (),
                            default_value.as_float (),
                            0.1f
                        ));
                    }
                } else if (is_atom_port) {
                    var flags = LV2AtomPort.Flags.NONE;
                    Lilv.Nodes buffer_types = lilv_plugin.port_get_value (
                        port,
                        LV2Manager.get_node (LV2.Atom._bufferType)
                    );

                    Lilv.Nodes atom_supports = lilv_plugin.port_get_value (
                        port,
                        LV2Manager.get_node (LV2.Atom._supports)
                    );

                    if (
                        buffer_types.contains (
                            LV2Manager.get_node (LV2.Atom._Sequence)
                        )
                    ) {
                        flags |= LV2AtomPort.Flags.SEQUENCE;

                        if (atom_supports.contains (
                            LV2Manager.get_node (LV2.MIDI._MidiEvent)
                        )) {
                            flags |= LV2AtomPort.Flags.SUPPORTS_MIDI_EVENT;
                        }
                    }

                    if (is_input_port) {
                        atom_in_port_list.append (
                            new LV2AtomPort (
                                name,
                                i,
                                properties,
                                symbol,
                                turtle_token,
                                flags
                            )
                        );

                        if (
                            (flags & LV2AtomPort.Flags.SUPPORTS_MIDI_EVENT) >
                            LV2AtomPort.Flags.NONE
                        ) {
                            n_atom_midi_in_ports++;
                        }
                    } else if (is_output_port) {
                        atom_out_port_list.append (
                            new LV2AtomPort (
                                name,
                                i,
                                properties,
                                symbol,
                                turtle_token,
                                flags
                            )
                        );

                        if (
                            (flags & LV2AtomPort.Flags.SUPPORTS_MIDI_EVENT) >
                            LV2AtomPort.Flags.NONE
                        ) {
                            n_atom_midi_out_ports++;
                        }
                    }
                }
            }
        }


        private string[] get_port_properties (Lilv.Port port) {
            var prop_list = new List<string> ();;

            var properties = lilv_plugin.port_get_properties (port);

            for (var props_iter = properties.begin ();
            !properties.is_end (props_iter);
            props_iter = properties.next (props_iter)) {
                var prop = properties.get (props_iter).as_string ();
                print("port prop:" + prop + "\n");
                prop_list.append (prop);
            }

            var n = prop_list.length ();

            var props = new string[n];
            for (uint32 i = 0; i < n; i++) {
                props[i] = prop_list.nth_data (i) + ""; // Make owned
            }
            return props;
        }
    }
}
