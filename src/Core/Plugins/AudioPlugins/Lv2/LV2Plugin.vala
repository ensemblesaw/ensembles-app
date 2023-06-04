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

namespace Ensembles.Core.Plugins.AudioPlugins.Lv2 {
    /**
     * An LV2 Plugin that can be used for DSP or as voices, expanding
     * the standard set of sampled voices that Ensembles come with.
     *
     * LV2 is an extensible open standard for audio plugins.
     * LV2 has a simple core interface, which is accompanied by extensions
     * that add more advanced functionality.
     */
    public class LV2Plugin : Plugins.AudioPlugins.AudioPlugin {
        public string plugin_uri { get; private set; }
        public string plugin_class { get; private set; }

        // LV2 Features ////////////////////////////////////////////////////////
        private LV2.Feature*[] features;
        private const string[] SUPPORTED_FEATURE_URIS = {
            LV2.URID._map,
            LV2.URID._unmap
        };

        LV2.Feature urid_map_feature;
        LV2.Feature urid_unmap_feature;
        //  LV2.Feature options_feature;
        //  LV2.Feature scheduler_feature;

        // Feature Structures
        LV2.URID.UridMap urid_map;
        LV2.URID.UridUnmap urid_unmap;

        // Plugin Instances ////////////////////////////////////////////////////
        private Lilv.Instance lv2_instance_l; // Stereo audio / Mono L Processor
        private Lilv.Instance lv2_instance_r; // Mono R Processor

        // Ports ///////////////////////////////////////////////////////////////
        // Control ports
        public LV2ControlPort[] control_in_ports;
        public float[] control_in_variables;

        // Atom ports
        // MIDI
        public LV2AtomPort[] atom_midi_in_ports;
        public Fluid.MIDIEvent[] midi_event_buffer;
        public LV2EvBuf[] atom_midi_in_variables;
        public uint8 midi_input_event_count;

        public unowned Lilv.Plugin? lilv_plugin { get; protected set; }

        public LV2Plugin (Lilv.Plugin? lilv_plugin) throws PluginError {
            Object (
                lilv_plugin: lilv_plugin
            );

            if (!features_are_supported ()) {
                throw new PluginError.UNSUPPORTED_FEATURE ("Feature not supported");
            }

            name = lilv_plugin.get_name ().as_string ();
            print ("plugin: %s\n--------------\n".printf (name));
            plugin_uri = lilv_plugin.get_uri ().as_uri ();
            plugin_class = lilv_plugin.get_class ().get_label ().as_string ();
            author_name = lilv_plugin.get_author_name ().as_string ();
            author_email = lilv_plugin.get_author_email ().as_string ();
            author_homepage = lilv_plugin.get_author_homepage ().as_string ();

            protocol = Protocol.LV2;

            // Get all ports from plugin
            category = get_category ();
        }

        private Category get_category () {
            var port_analyser = new LV2PortAnalyser (lilv_plugin);
            if ( // Check if it is DSP (effect) plugin
                (
                    plugin_class.contains ("Amplifier") ||
                    plugin_class.contains ("Utility") ||
                    plugin_class.contains ("Reverb")
                ) && (
                    port_analyser.audio_in_port_list.length () > 0 &&
                    port_analyser.audio_out_port_list.length () > 0
                )
            ) {
                return Category.DSP;
            } else if ( // Check if it is Voice (instrument) plugin
                plugin_class == "Instrument Plugin" ||
                (
                    port_analyser.n_atom_midi_in_ports > 0 &&
                    port_analyser.audio_in_port_list.length () > 0 &&
                    port_analyser.audio_out_port_list.length () > 0
                )
            ) {
                return Category.VOICE;
            }

            return Category.UNSUPPORTED;
        }

        /**
         * Creates a workable instance of the lv2 plugin.
         * Instantiate must be called on this object before connecting any ports
         * or running the plugin.
         */
        public override void instantiate () {
            if (lv2_instance_l == null) {
                active = false;
                create_features ();

                lv2_instance_l = lilv_plugin.instantiate (AudioEngine.Synthesizer.sample_rate, features);

                // Check if plugin is mono
                if (!stereo) {
                    lv2_instance_r = lilv_plugin.instantiate (AudioEngine.Synthesizer.sample_rate, features);
                }

                create_ports ();
                allocate_control_ports ();
                allocate_midi_port_buffers ();
                build_ui ();
            }
        }

        private void allocate_control_ports () {
            control_in_variables = new float[control_in_ports.length];
            for (uint32 i = 0; i < control_in_ports.length; i++) {
                control_in_variables[i] = control_in_ports[i].default_value;
                connect_port (control_in_ports[i], &control_in_variables[i]);
            }
        }

        private void allocate_midi_port_buffers () {
            atom_midi_in_variables = new LV2EvBuf [atom_midi_in_ports.length];

            for (uint8 i = 0; i < atom_midi_in_ports.length; i++) {
                atom_midi_in_variables[i] = new LV2EvBuf (
                    AudioEngine.Synthesizer.get_buffer_size (),
                    LV2Manager.map_uri (this, LV2.Atom._Chunk),
                    LV2Manager.map_uri (this, LV2.Atom._Sequence)
                );

                atom_midi_in_variables[i].reset (true);

                connect_port (atom_midi_in_ports[i], atom_midi_in_variables[i].get_buffer ());
            }
        }

        public override AudioPlugin duplicate () throws PluginError {
            return new LV2Plugin (lilv_plugin);
        }

        protected override void activate () {
            if (lv2_instance_l != null) {
                lv2_instance_l.activate ();
            }

            if (lv2_instance_r != null) {
                lv2_instance_r.activate ();
            }
        }

        protected override void deactivate () {
            if (lv2_instance_l != null) {
                lv2_instance_l.deactivate ();
            }

            if (lv2_instance_r != null) {
                lv2_instance_r.deactivate ();
            }
        }

        public override void connect_source_buffer (void* in_l, void* in_r) {
            if (stereo) {
                // Stereo plugin
                for (uint8 i = 0; i < audio_in_ports.length; i++) {
                    if ((i & 1) == 0) { // If even
                        if (lv2_instance_l != null) {
                            lv2_instance_l.connect_port (
                                audio_in_ports[i].index,
                                in_l
                            );
                        }
                    } else {
                        if (lv2_instance_l != null) {
                            lv2_instance_l.connect_port (
                                audio_in_ports[i].index,
                                in_r
                            );
                        }
                    }
                }
            } else {
                lv2_instance_l.connect_port (
                    audio_in_ports[0].index,
                    in_l
                );

                lv2_instance_r.connect_port (
                    audio_in_ports[0].index,
                    in_r
                );
            }
        }

        public override void connect_sink_buffer (void* out_l, void* out_r) {
            if (stereo) {
                for (uint8 i = 0; i < audio_out_ports.length; i++) {
                    if ((i & 1) == 0) { // If even
                        if (lv2_instance_l != null) {
                            lv2_instance_l.connect_port (
                                audio_out_ports[i].index,
                                out_l
                            );
                        }
                    } else {
                        if (lv2_instance_l != null) {
                            lv2_instance_l.connect_port (
                                audio_out_ports[i].index,
                                out_r
                            );
                        }
                    }
                }
            } else {
                lv2_instance_l.connect_port (
                    audio_out_ports[0].index,
                    out_l
                );

                lv2_instance_r.connect_port (
                    audio_out_ports[0].index,
                    out_r
                );
            }
        }

        public override void connect_port (Port port, void* data_pointer) {
            if (lv2_instance_l != null) {
                lv2_instance_l.connect_port (port.index, data_pointer);
            }

            if (lv2_instance_r != null) {
                lv2_instance_r.connect_port (port.index, data_pointer);
            }
        }

        public override int send_midi_event (Fluid.MIDIEvent midi_event) {
            if (active) {
                //  print ("midi, %d\n", midi_event.get_key ());
                if (midi_event_buffer == null) {
                    midi_event_buffer = new Fluid.MIDIEvent [AudioEngine.Synthesizer.get_buffer_size ()];
                }

                midi_event_buffer[midi_input_event_count] = new Fluid.MIDIEvent ();
                midi_event_buffer[midi_input_event_count].set_type (midi_event.get_type ());
                midi_event_buffer[midi_input_event_count].set_key (midi_event.get_key ());
                midi_event_buffer[midi_input_event_count++].set_velocity (midi_event.get_velocity ());

                return Fluid.OK;
            }

            return Fluid.FAILED;
        }

        private void fill_event_buffers () {
            for (uint16 p = 0; p < atom_midi_in_ports.length; p++) {
                //  unowned LV2AtomPort port = atom_midi_in_ports[p];
                unowned LV2EvBuf evbuf = atom_midi_in_variables[p];
                evbuf.reset (true);
                var iter = evbuf.begin ();

                //  print ("midi buffer size %d\n", midi_event_buffer.length);

                for (uint8 i = 0; i < midi_input_event_count; i++) {
                    unowned Fluid.MIDIEvent midi_event = midi_event_buffer[i];
                    var buffer = new uint8[3];
                    buffer[0] = (uint8) midi_event.get_type ();
                    buffer[1] = (uint8) midi_event.get_key ();
                    buffer[2] = (uint8) midi_event.get_velocity ();
                    iter.write (
                        (uint32) (
                            new DateTime.now_utc ().to_unix () - AudioEngine.Synthesizer.get_process_start_time ()
                        ),
                        0,
                        (uint32) LV2Manager.map_uri (this, LV2.MIDI._MidiEvent),
                        3,
                        buffer
                    );
                }
            }

            midi_input_event_count = 0;
        }

        public override void process (uint32 sample_count) {
            fill_event_buffers ();

            if (lv2_instance_l != null) {
                lv2_instance_l.run (sample_count);
            }

            if (lv2_instance_r != null) {
                lv2_instance_r.run (sample_count);
            }
        }

        /**
         * Create plugin features
         */
         private void create_features () {
            urid_map = LV2.URID.UridMap ();
            urid_map.handle = (LV2.URID.MapHandle) this;
            urid_map.map = LV2Manager.map_uri;
            urid_unmap = LV2.URID.UridUnmap ();
            urid_unmap.handle = (LV2.URID.UnmapHandle) this;
            urid_unmap.unmap = LV2Manager.unmap_uri;

            features = new LV2.Feature* [2];
            urid_map_feature = register_feature (LV2.URID._map, &urid_map);
            urid_unmap_feature = register_feature (LV2.URID._unmap, &urid_unmap);

            features[0] = &urid_map_feature;
            features[1] = &urid_unmap_feature;

        }

        private bool features_are_supported () {
            var lilv_features = lilv_plugin.get_required_features ();
            for (var iter = lilv_features.begin (); !lilv_features.is_end (iter);
            iter = lilv_features.next (iter)) {
                string required_feature = lilv_features.get (iter).as_uri ();
                print ("checking: %s\n", required_feature);
                if (!feature_supported (required_feature)) {
                    return false;
                }
            }

            return true;
        }

        private bool feature_supported (string feature) {
            for (uint8 i = 0; i < SUPPORTED_FEATURE_URIS.length; i++) {
                if (feature == SUPPORTED_FEATURE_URIS[i]) {
                    return true;
                }
            }

            return false;
        }

        private LV2.Feature register_feature (string uri, void* data) {
            return LV2.Feature () {
                URI = uri,
                data = data
            };
        }

        private void create_ports () {
            var port_analyser = new LV2PortAnalyser (lilv_plugin);

            var n_audio_in_ports = port_analyser.audio_in_port_list.length ();
            audio_in_ports = new Port[n_audio_in_ports];

            // If there's more than one audio in port then presume that
            // the plugin is stereo
            stereo = n_audio_in_ports > 1;
            for (uint32 p = 0; p < n_audio_in_ports; p++) {
                unowned LV2Port _port =
                    port_analyser.audio_in_port_list.nth_data (p);
                audio_in_ports[p] = new LV2Port (
                    _port.name,
                    _port.index,
                    _port.properties,
                    _port.symbol,
                    _port.turtle_token
                );
            }

            var n_audio_out_ports = port_analyser.audio_out_port_list.length ();
            audio_out_ports = new Port[n_audio_out_ports];
            for (uint32 p = 0; p < n_audio_out_ports; p++) {
                unowned LV2Port _port =
                    port_analyser.audio_out_port_list.nth_data (p);
                audio_out_ports[p] = new LV2Port (
                    _port.name,
                    _port.index,
                    _port.properties,
                    _port.symbol,
                    _port.turtle_token
                );
            }

            var n_control_in_ports = port_analyser.control_in_port_list.length ();
            control_in_ports = new LV2ControlPort[n_control_in_ports];
            for (uint32 p = 0; p < n_control_in_ports; p++) {
                unowned LV2ControlPort _port =
                    port_analyser.control_in_port_list.nth_data (p);
                control_in_ports[p] = new LV2ControlPort (
                    _port.name,
                    _port.index,
                    _port.properties,
                    _port.symbol,
                    _port.turtle_token,
                    _port.min_value,
                    _port.max_value,
                    _port.default_value,
                    _port.step
                );
            }

            var n_atom_in_ports = port_analyser.atom_in_port_list.length ();
            // MIDI Ports
            atom_midi_in_ports = new LV2AtomPort[port_analyser.n_atom_midi_in_ports];

            for (uint32 p = 0, i = 0; p < n_atom_in_ports; p++) {
                unowned LV2AtomPort _port =
                    port_analyser.atom_in_port_list.nth_data (p);
                if ((_port.flags & LV2AtomPort.Flags.SUPPORTS_MIDI_EVENT) > LV2AtomPort.Flags.NONE) {
                    atom_midi_in_ports[i++] = new LV2AtomPort (
                        _port.name,
                        _port.index,
                        _port.properties,
                        _port.symbol,
                        _port.turtle_token,
                        _port.flags
                    );
                }
            }
        }

        private void build_ui () {
            var box = new Gtk.Box (
                Gtk.Orientation.HORIZONTAL,
                8
            ) {
                spacing = 4,
                valign = Gtk.Align.CENTER,
                homogeneous = control_in_ports.length < 4
            };

            bool is_ui_required = false;

            if (control_in_ports.length > 0) {
                for (uint i = 0; i < control_in_ports.length; i++) {
                    var plugin_control = new Shell.Plugins.AudioPlugins.Widgets.AudioPluginControl (
                        control_in_ports[i],
                        & (control_in_variables[i]),
                        control_in_ports.length > 3 ? Gtk.IconSize.NORMAL : Gtk.IconSize.LARGE
                    );
                    box.append (plugin_control);
                }

                is_ui_required = true;
            }

            if (is_ui_required) {
                ui = box;
            }
        }
    }
}
