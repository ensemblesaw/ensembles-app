/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Core.MIDIPlayers;
using Ensembles.Core.Plugins;
using Ensembles.Models;

namespace Ensembles.Core {
    public class ArrangerWorkstation : Object {
        private AudioEngine.SynthProvider synth_provider;
        private AudioEngine.Synthesizer synthesizer;
        private StyleEngine style_engine;
        private Plugins.PluginManager plugin_manager;
        private Racks.DSPRack main_dsp_rack;
        private Racks.VoiceRack voice_l_rack;
        private Racks.VoiceRack voice_r1_rack;
        private Racks.VoiceRack voice_r2_rack;

         // Arranger Data
        private Style[] styles;
        private Style next_style;
        private bool stopping_style;

        private const string SF_PATH = Constants.SF2DATADIR + "/EnsemblesGM.sf2";

        construct {
            #if PIPEWIRE_CORE_DRIVER
            Pipewire.init (null, null);
            #endif
            synth_provider = new AudioEngine.SynthProvider ();
            synth_provider.init_driver ("pulseaudio", 0.3);
            Console.log ("Loading Soundfont from %s".printf (SF_PATH));
            try {
                synthesizer = new AudioEngine.Synthesizer (synth_provider, SF_PATH);
            } catch (FluidError e) {
                Console.log (e.message, Console.LogLevel.ERROR);
            }

            Console.log ("Initializing Plugin Racks");
            main_dsp_rack = new Racks.DSPRack ();
            synthesizer.add_rack (main_dsp_rack);

            voice_l_rack = new Racks.VoiceRack ();
            synthesizer.add_rack (voice_l_rack);

            voice_r1_rack = new Racks.VoiceRack ();
            synthesizer.add_rack (voice_r1_rack);

            voice_r2_rack = new Racks.VoiceRack ();
            synthesizer.add_rack (voice_r2_rack);

            build_events ();
        }

        public ArrangerWorkstation () {
            new Thread<void> ("ensembles-data-discovery", load_data);
        }

        /**
         * Load all data like voices, styles and plugins
         */
        public void load_data () {
            Thread.usleep (500000);
            // Load Styles
            Console.log ("Searching for styles…");
            var style_loader = new FileLoaders.StyleFileLoader ();
            uint n_styles = 0;
            styles = style_loader.get_styles (out n_styles);
            Console.log (
                "Found %u styles".printf (n_styles),
                Console.LogLevel.SUCCESS
            );

            // Load Plugins
            plugin_manager = new PluginManager ();

            add_plugins_to_voice_racks ();

            // Send ready signal
            Idle.add (() => {
                Ensembles.Application.event_bus.arranger_ready ();
                return false;
            });
        }

        private void build_events () {
            Application.event_bus.style_play_toggle.connect (() => {
                if (style_engine != null) {
                    style_engine.toggle_play ();
                }
            });

            Application.event_bus.style_set_part.connect (
                (part) => {
                    if (style_engine != null) {
                        style_engine.queue_next_part (part);
                    }
                }
            );

            Application.event_bus.style_break.connect (() => {
                if (style_engine != null) {
                    style_engine.break_play ();
                }
            });

            Application.event_bus.style_sync.connect (() => {
                if (style_engine != null) {
                    style_engine.sync ();
                }
            });

            Application.event_bus.style_change.connect (
                (style) => {
                queue_change_style (style);
            });
        }

        /**
         * Creates a style engine with given style
         *
         * @param style A Style descriptor
         */
        public void queue_change_style (Models.Style style) {
            Console.log ("Changing style to the " + style.to_string ());
            next_style = style;
            if (!stopping_style) {
                stopping_style = true;
                new Thread<void> ("queue-load-style", () => {
                    uint8 current_tempo = 0;
                    if (style_engine != null) {
                        style_engine.stop_and_wait (out current_tempo);
                    }

                    style_engine = new StyleEngine (
                        synth_provider,
                        next_style,
                        current_tempo
                    );
                    stopping_style = false;
                });
            }
        }

        /**
         * Returns an array of styles loaded by the arranger workstation.
         */
        public unowned Style[] get_styles () {
            return styles;
        }

        private void add_plugins_to_voice_racks () {
            unowned List<AudioPlugins.AudioPlugin> plugins =
            plugin_manager.audio_plugins;
            for (uint32 i = 0; i < plugins.length (); i++) {
                if (plugins.nth_data (i).category ==
                AudioPlugins.AudioPlugin.Category.VOICE) {
                    try {
                        voice_l_rack.append (plugins.nth_data (i).duplicate ());
                        voice_r1_rack.append (plugins.nth_data (i).duplicate ());
                        voice_r2_rack.append (plugins.nth_data (i).duplicate ());
                    } catch (PluginError e) {

                    }
                }
            }

            voice_l_rack.active = true;
            voice_r1_rack.active = true;
            voice_r2_rack.active = true;
        }

        public unowned List<AudioPlugins.AudioPlugin> get_audio_plugins () {
            return plugin_manager.audio_plugins;
        }

        public unowned Racks.DSPRack get_main_dsp_rack () {
            return main_dsp_rack;
        }

        public unowned Racks.VoiceRack get_voice_rack (
            VoiceHandPosition position
        ) {
            switch (position) {
                case VoiceHandPosition.LEFT:
                return voice_l_rack;
                case VoiceHandPosition.RIGHT_LAYERED:
                return voice_r2_rack;
                default:
                return voice_r1_rack;
            }
        }
    }
}
