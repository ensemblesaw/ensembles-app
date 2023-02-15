/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

 /**
  * FluidSynth
  */
[CCode(cheader_filename="fluidsynth.h", cprefix="FLUID_", lower_case_cprefix="fluid_")]
namespace Fluid {
    /**
      * Value that indicates success, used by most libfluidsynth functions.
      *
      * @since 1.1.0
      */
    const int OK;
    /**
      * Value that indicates failure, used by most libfluidsynth functions.
      *
      * @since 1.1.0
      */
    const int FAILED;
    /**
      * String constant of libfluidsynth version.
      */
    const string VERSION;
    /**
      * libfluidsynth major version integer constant.
      */
    const int VERSION_MAJOR;
    /**
      * Value that indicates failure, used by most libfluidsynth functions.
      */
    const int VERSION_MICRO;
    /**
      * libfluidsynth micro version integer constant.
      */
    const int VERSION_MINOR;
    /**
      * libfluidsynth minor version integer constant.
      */

    /**
      * Wrapper for `free()` that satisfies at least C90 requirements.
      *
      * **Warning**:
      * Calling {@link Fluid.free} on memory that is advised to be freed with
      * `fluid_free()` results in undefined behaviour! (cf.: "Potential Errors
      * Passing CRT Objects Across DLL Boundaries" found in MS Docs)
      *
      * @since 2.0.7
      * @param ptr Pointer to memory region that should be freed
      */
    void free (void* ptr);
    /**
      * Check if a file is a MIDI file.
      *
      * The current implementation only checks for the "MThd" header in the
      * file. It is useful only to distinguish between SoundFont and MIDI files.
      *
      * @param filename Path to the file to check
      * @return TRUE if it could be a MIDI file, FALSE otherwise
      */
    bool is_midifile (string filename);
    /**
      * Check if a file is a SoundFont file.
      *
      * If fluidsynth was built with DLS support, this function will also
      * identify DLS files.
      *
      * **Note:** This function only checks whether header(s) in the RIFF chunk
      * are present. A call to {@link Fluid.Synth.sfload} might still fail.
      *
      * @param filename Path to the file to check
      * @return TRUE if it could be a SF2, SF3 or DLS file, FALSE otherwise
      */
    bool is_soundfont (string filename);
    /**
      * Get FluidSynth runtime version.
      *
      * @param major Location to store major number
      * @param minor Location to store minor number
      * @param micro Location to store micro number
      */
    void version (out int major, out int minor, out int micro);
    /**
      * Get FluidSynth runtime version as a string.
      *
      * @return FluidSynth version string, which is internal and
      * should not be modified or freed.
      */
    string version_str ();

    [CCode (cprefix = "HINT_")]
    namespace Hint {
        /**
          * Hint FLUID_HINT_BOUNDED_ABOVE indicates that the UpperBound field of
          * the FLUID_PortRangeHint should be considered meaningful.
          *
          * The value in this field should be considered the (inclusive) upper
          * bound of the valid range. If FLUID_HINT_SAMPLE_RATE is also
          * specified then the value of UpperBound should be multiplied by
          * the sample rate.
          */
        public const int BOUNDED_ABOVE;
        /**
          * Hint FLUID_HINT_BOUNDED_BELOW indicates that the LowerBound field of
          * the FLUID_PortRangeHint should be considered meaningful.
          *
          * The value in this field should be considered the (inclusive) lower
          * bound of the valid range. If FLUID_HINT_SAMPLE_RATE is also specified
          * then the value of LowerBound should be multiplied by the sample rate.
          */
        public const int BOUNDED_BELOW;
        /**
          * Setting is a list of string options.
          */
        public const int OPTIONLIST;
        /**
          * Hint FLUID_HINT_TOGGLED indicates that the data item should be
          * considered a Boolean toggle.
          *
          * Data less than or equal to zero should be considered ‘off’ or
          * ‘false,’ and data above zero should be considered ‘on’ or ‘true.’
          * FLUID_HINT_TOGGLED may not be used in conjunction with any other hint.
          */
        public const int TOGGLED;
    }

    /**
      * Settings type.
      *
      * Each setting has a defined type: numeric (double), integer, string or a
      * set of values. The type of each setting can be retrieved using the
      * function {@link Fluid.Settings.get_type}
      */
    [CCode (cname = "enum fluid_types_enum", has_type_id = false, cprefix = "FLUID_")]
    public enum Types {
        /** Undefined type  */
        NO_TYPE,
        /** Numeric (double) */
        NUM_TYPE,
        /** Integer */
        INT_TYPE,
        /** String */
        STR_TYPE,
        /** Set of values */
        SET_TYPE
    }

    /** Chorus modulation waveform type. */
    [CCode (cname = "enum fluid_chorus_mod", has_type_id = false, cprefix = "FLUID_CHORUS_")]
    public enum ChorusMod {
        /** Sine wave chorus modulation. */
        SINE,
        /** Triangle wave chorus modulation. */
        TRIANGLE
    }

    /**
      *Specifies optional settings to use for the custom IIR filter.
      *
      * Can be bitwise ORed.
      */
    [CCode (cname = "enum fluid_iir_filter_flags", has_type_id = false, cprefix = "FLUID_IIR_")]
    public enum IIRFilterFlags {
        /**
          *The Soundfont spec requires the filter Q to be interpreted in dB.
          *
          * If this flag is set the filter Q is instead assumed to be in
          * a linear range  */
        Q_LINEAR,
        /** If this flag the filter is switched off if
        * Q == 0 (prior to any transformation)  */
        Q_ZERO_OFF,
        /**
          * The Soundfont spec requires to correct the gain of the
          * filter depending on the filter's Q.
          *
          * If this flag is set the filter gain will not be corrected.
          */
        NO_GAIN_AMP
    }

    /**
      * Specifies the type of filter to use for the custom IIR filter.
      */
    [CCode (cname = "enum fluid_iir_filter_type", has_type_id = false, cprefix = "FLUID_IIR_")]
    public enum IIRFilterTypes {
        /** Custom IIR filter is not operating.  */
        DISABLED,
        /** Custom IIR filter is operating as low-pass filter. */
        LOWPASS,
        /** Custom IIR filter is operating as high-pass filter. */
        HIGHPASS,
        LAST
    }

    [CCode (cname = "enum fluid_gen_type", has_type_id = false, cprefix = "GEN_")]
    public enum GenType {
        STARTADDROFS,
        ENDADDROFS,
        STARTLOOPADDROFS,
        ENDLOOPADDROFS,
        STARTADDRCOARSEOFS,
        MODLFOTOPITCH,
        VIBLFOTOPITCH,
        MODENVTOPITCH,
        FILTERFC,
        FILTERQ,
        MODLFOTOFILTERFC,
        MODENVTOFILTERFC,
        ENDADDRCOARSEOFS,
        MODLFOTOVOL,
        UNUSED1,
        CHORUSSEND,
        REVERBSEND,
        PAN,
        UNUSED2,
        UNUSED3,
        UNUSED4,
        MODLFODELAY,
        MODLFOFREQ,
        VIBLFODELAY,
        VIBLFOFREQ,
        MODENVDELAY,
        MODENVATTACK,
        MODENVHOLD,
        MODENVDECAY,
        MODENVSUSTAIN,
        MODENVRELEASE,
        KEYTOMODENVHOLD,
        KEYTOMODENVDECAY,
        VOLENVDELAY,
        VOLENVATTACK,
        VOLENVHOLD,
        VOLENVDECAY,
        VOLENVSUSTAIN,
        VOLENVRELEASE,
        KEYTOVOLENVHOLD,
        KEYTOVOLENVDECAY,
        INSTRUMENT,
        RESERVED1,
        KEYRANGE,
        VELRANGE,
        STARTLOOPADDRCOARSEOFS,
        KEYNUM,
        VELOCITY,
        ATTENUATION,
        RESERVED2,
        ENDLOOPADDRCOARSEOFS,
        COARSETUNE,
        FINETUNE,
        SAMPLEID,
        SAMPLEMODE,
        RESERVED3,
        SCALETUNE,
        EXCLUSIVECLASS,
        OVERRIDEROOTKEY,
        PITCH,
        CUSTOM_BALANCE,
        CUSTOM_FILTERFC,
        CUSTOM_FILTERQ,
        LAST
    }

    [CCode (cname = "enum fluid_midi_channel_type", has_type_id = false, cprefix = "CHANNEL_TYPE_")]
    public enum MIDIChannelType {
        MELODIC,
        DRUM
    }

    [CCode (cname = "enum fluid_channel_mode_flags", has_type_id = false, cprefix = "FLUID_CHANNEL_")]
    public enum ChannelModeFlags {
        POLY_OFF,
        OMNI_OFF
    }

    [CCode (cname = "enum fluid_basic_channel_modes", has_type_id = false, cprefix = "FLUID_CHANNEL_MODE_")]
    public enum BasicChannelModes {
        MASK,
        OMNION_POLY,
        OMNION_MONO,
        OMNIOFF_POLY,
        OMNIOFF_MONO,
        LAST
    }

    [CCode (cname = "enum fluid_channel_legato_mode", has_type_id = false, cprefix = "FLUID_CHANNEL_LEGATO_MODE_")]
    public enum ChannelLegatoMode {
        RETRIGGER,
        MULTI_RETRIGGER,
        LAST
    }

    [CCode (cname = "enum fluid_channel_portamento_mode", has_type_id = false, cprefix = "FLUID_CHANNEL_PORTAMENTO_MODE_")]
    public enum ChannelPortamentoMode {
        EACH_NOTE,
        LEGATO_ONLY,
        STACCATO_ONLY,
        LAST
    }

    [CCode (cname = "enum fluid_channel_breath_flags", has_type_id = false, cprefix = "FLUID_CHANNEL_BREATH_")]
    public enum ChannelBreathFlags {
        POLY,
        MONO,
        SYNC
    }

    [CCode (cname = "enum fluid_player_set_tempo_type", has_type_id = false, cprefix = "FLUID_PLAYER_TEMPO_")]
    public enum TempoType {
        INTERNAL,
        EXTERNAL_BPM,
        EXTERNAL_MIDI,
        NBR
    }

    [CCode (cname = "enum fluid_player_status ", has_type_id = false, cprefix = "FLUID_PLAYER_")]
    public enum PlayerStatus {
        READY,
        PLAYING,
        STOPPING,
        DONE
    }

    [CCode (cname = "enum fluid_midi_router_rule_type ", has_type_id = false, cprefix = "FLUID_MIDI_ROUTER_RULE_")]
    public enum MIDIRouterRuleType {
        NOTE,
        CC,
        PROG_CHANGE,
        PITCH_BEND,
        CHANNEL_PRESSURE,
        KEY_PRESSURE
    }

    [SimpleType]
    [CCode (cname = "fluid_audio_func_t", has_target = false)]
    public delegate int handle_audio_func_t (void* data, int len, [CCode (array_length_pos = 2.1)] float*[] fx, [CCode (cname = "out", array_length_pos = 3.1)] float*[] aout);

    [SimpleType]
    [CCode (cname = "handle_midi_event_func_t", has_target = false)]
    public delegate int handle_midi_event_func_t (void* data, MIDIEvent event);

    [SimpleType]
    [CCode (cname = "handle_midi_tick_func_t", has_target = false)]
    public delegate int handle_midi_tick_func_t (void* data, int tick);

    /**
      * SoundFont synthesizer.
      *
      * You have to load a SoundFont in order to hear any sound. For that you use
      * the {@link sfload} function.
      *
      * You can use the audio driver functions to open the audio device and
      * create a background audio thread.
      *
      * The API for sending MIDI events is probably
      * what you expect: {@link noteon}, {@link noteoff()}, ...
      */
    [Compact]
    [CCode (cname = "fluid_synth_t", cprefix = "fluid_synth_", free_function = "delete_fluid_synth", has_type_id = false)]
    public class Synth {
        [CCode (cname = "new_fluid_synth")]
        public Synth (Settings settings);

        public Synth get_settings ();
        /**
          * Get a textual representation of the last error.
          *
          * @return Pointer to string of last error message. Valid until the
          * same calling thread calls another FluidSynth function which fails.
          * String is internal and should not be modified or freed.
          *
          * @deprecated
          */
        public string error ();
        /** Get the synth CPU load value.
          *
          * @return Estimated CPU load value in percent (0-100) */
        public double get_cpu_load ();

        // Audio Rendering
        //  [CCode (cname = "fluid_synth_process")]
        //  private int internal_process (int len, int nfx, float** fx, int nout, [CCode (cname = "out")] float** aout);
        //  [CCode (cname = "_v_fluid_synth_process")]
        //  public int process (float[,] fx, float[,] aout) {
        //      return internal_process (fx.length[1], fx.length[0], fx, aout.length[0], aout);
        //  }


        /**
         * Synthesize floating point audio to stereo audio channels
         * (implements the default interface {@link handle_audio_func_t}).
         *
         * Synthesize and mix audio to a given number of planar audio buffers.
         * Therefore pass `aout.length = N*2` float buffers
         * to `out` in order to render the synthesized audio to `N` stereo channels.
         * Each float buffer must be able to hold `len` elements.
         *
         * `aout` contains an array of planar buffers for normal, dry, stereo
         * audio (alternating left and right). Like:
         * {{{
         * aout[0]  = left_buffer_audio_channel_0
         * aout[1]  = right_buffer_audio_channel_0
         * aout[2]  = left_buffer_audio_channel_1
         * aout[3]  = right_buffer_audio_channel_1
         * ...
         * aout[ (i * 2 + 0) % aout.length ]  = left_buffer_audio_channel_i
         * aout[ (i * 2 + 1) % aout.length ]  = right_buffer_audio_channel_i
         * }}}
         *
         * for zero-based channel index `i`. The buffer layout of `fx` used for
         * storing effects like reverb and chorus looks similar:
         *
         * {{{
         * fx[0]  = left_buffer_channel_of_reverb_unit_0
         * fx[1]  = right_buffer_channel_of_reverb_unit_0
         * fx[2]  = left_buffer_channel_of_chorus_unit_0
         * fx[3]  = right_buffer_channel_of_chorus_unit_0
         * fx[4]  = left_buffer_channel_of_reverb_unit_1
         * fx[5]  = right_buffer_channel_of_reverb_unit_1
         * fx[6]  = left_buffer_channel_of_chorus_unit_1
         * fx[7]  = right_buffer_channel_of_chorus_unit_1
         * fx[8]  = left_buffer_channel_of_reverb_unit_2
         * ...
         * fx[ ((k * synth.count_effects_channels() + j) * 2 + 0) % fx.length ]  = left_buffer_for_effect_channel_j_of_unit_k
         * fx[ ((k * synth.count_effects_channels() + j) * 2 + 1) % fx.length ]  = right_buffer_for_effect_channel_j_of_unit_k
         * }}}
         *
         *  where `0 <= k < synth.link count_effects_groups()` is a zero-based index
         * denoting the effects unit and `0 <= j < synth.count_effects_channels()`
         * is a zero-based index denoting the effect channel within unit `k`.
         *
         * Any playing voice is assigned to audio channels based on the MIDI
         * channel it's playing on: Let chan be the zero-based MIDI channel index
         * an arbitrary voice is playing on. To determine the audio channel and
         * effects unit it is going to be rendered to use:
         *
         * `i = chan % synth.count_audio_groups()`
         *
         * `k = chan % synth.count_effects_groups()`
         *
         * **Note:** The owner of the sample buffers must zero them out before
         * calling this function, because any synthesized audio is mixed
         * (i.e. added) to the buffers. E.g. if {@link Fluid.Synth.process} is called
         * from a custom audio driver process function {@link Fluid.AudioDriver.with_audio_callback}),
         * the audio driver takes care of zeroing the buffers.
         *
         * **Note:** No matter how many buffers you pass in, {@link Fluid.Synth.process}
         * will always render all audio channels to the buffers in out and all
         * effects channels to the buffers in `fx`, provided that `aout.length > 0`
         * and `fx.length > 0` respectively.
         * If `aout.length/2 < synth.count_audio_channels()` it will wrap around.
         * Same is true for effects audio if
         * `fx.length/2 < (synth.count_effects_channels() * synth.count_effects_groups()).
         * See usage examples below.
         *
         * **Note:** Should only be called from synthesis thread.
         *
         * @see Fluid.AudioDriver.with_audio_callback
         * @param len Count of audio frames to synthesize and store in every
         * single buffer provided by out and fx. Zero value is permitted,
         * the function does nothing and return {@link FLUID.OK}.
         * @param fx Array of buffers to store effects audio to. Buffers may
         * alias with buffers of `out`. Individual NULL buffers are permitted
         * and will cause to skip mixing any audio into that buffer.
         * @param aout Array of buffers to store (dry) audio to. Buffers may
         * alias with buffers of `fx`. Individual NULL buffers are permitted and
         * will cause to skip mixing any audio into that buffer
         * @return {@link Fluid.OK} on success, {@link Fluid.FAILED} otherwise,
         * * `fx == NULL` while `fx.length > 0`, or `out == NULL` while `nout > 0`.
         * * `nfx` or `aout.length` not multiple of 2.
         * * `len < 0`
         * * `fx.length` or `aout.length` exceed the range explained above.
         */
        public int process (int len, [CCode (array_length_pos = 1.1)] float*[] fx, [CCode (cname = "out", array_length_pos = 2.1)] float*[] aout);

        // Effect - Chorus
        public int chorus_on (int fx_group, bool on);
        public int get_chorus_group_depth (int fx_group, out double depth_ms);
        public int get_chorus_group_level (int fx_group, out double level);
        public int get_chorus_group_nr (int fx_group, out int nr);
        public int get_chorus_group_speed (int fx_group, out double speed);
        public int get_chorus_group_type (int fx_group, out ChorusMod type);
        public int set_chorus_group_depth (int fx_group, double depth_ms);
        public int set_chorus_group_level (int fx_group, double level);
        public int set_chorus_group_nr (int fx_group, int nr);
        public int set_chorus_group_speed (int fx_group, double speed);
        public int set_chorus_group_type (int fx_group, ChorusMod type);

        // Effect - Reverb
        public int get_reverb_group_damp (int fx_group, out double damping);
        public int get_reverb_group_level (int fx_group, out double level);
        public int get_reverb_group_roomsize (int fx_group, out double roomsize);
        public int get_reverb_group_width (int fx_group, out double width);
        public int reverb_on (int fx_group, bool on);
        public int set_reverb_group_damp (int fx_group, double damping);
        public int set_reverb_group_level (int fx_group, double level);
        public int set_reverb_group_roomsize (int fx_group, double roomsize);
        public int set_reverb_group_width (int fx_group, double width);

        // Effect - IIR Filter
        public int set_custom_filter (IIRFilterTypes type, IIRFilterFlags flags);

        // Effect - LADSPA
        public LADSPAFx get_ladspa_fx ();

        // MIDI Channel Messages
        public int all_notes_off (int chan);
        public int all_sounds_off (int chan);
        public int bank_select (int chan, int bank);
        public int cc (int chan, int num, int val);
        public int channel_pressure (int chan, int val);
        public int get_cc (int chan, int num, out int pval);
        public float get_gen (int chan, GenType param);
        public int get_pitch_bend (int chan, out int ppitch_bend);
        public int get_pitch_wheel_sens (int chan, out int pval);
        public int get_program (int chan, out int sfont_id, out int back_num, out int preset_num);
        public int key_pressure (int chan, int key, int val);
        public int noteoff (int chan, int key);
        public int noteon (int chan, int key, int vel);
        public int pitch_bend (int chan, int val);
        public int pitch_wheel_sens (int chan, int val);
        public int program_change (int chan, int program);
        public int program_reset ();
        public int program_select (int chan, int sfont_id, int bank_num, int preset_num);
        public int program_select_by_sfont_name (int chan, string sfont_name, int bank_num, int preset_num);
        public int set_gen (int chan, GenType param, float value);
        public int sfont_select (int chan, int sfont_id);
        public int sysex (uint8[] data, int len, char* response, out int response_len, out bool handled, int dryrun);
        public int system_reset ();
        public int unset_program (int chan);

        // MIDI Channel Setup
        public int get_breath_mode (int chan, out ChannelBreathFlags breathmode);
        public int get_legato_mode (int chan, out ChannelLegatoMode legatomode);
        public int get_portamento_mode (int chan, out ChannelPortamentoMode portamentomode);
        public int set_channel_type (int chan, MIDIChannelType type);
        public int reset_basic_channel (int chan);
        public int set_basic_channel (int chan, BasicChannelModes mode, int val);
        public int set_breath_mode (int chan, ChannelBreathFlags breathmode);
        public int set_legato_mode (int chan, ChannelLegatoMode legatomode);
        public int set_portamento_mode (int chan, ChannelPortamentoMode portamentomode);

        // MIDI Tuning
        public int activate_tuning (int chan, int bank, int prog, bool apply);
        public int deactivate_tuning (int chan, bool apply);
        public bool tuning_iteration_next (out int bank, out int prog);
        public void tuning_iteration_start ();

        // Soundfont Management
        public int add_sfont (SoundFont sfont);
        public int get_bank_offset (int sfont_id);
        public SoundFont get_sfont (uint num);
        public SoundFont get_sfont_by_id (int id);
        public SoundFont get_sfont_by_name (string name);
        public int remove_sfont (SoundFont sfont);
        public int set_bank_offset (int sfont_id, int offset);
        public int sfcount ();
        public int sfreload (int id);
        public int sfunload (int id, bool reset_presets);

        public int handle_midi_event (MIDIEvent event);
    }

    /**
      * Functions for settings management.
      */
    [Compact]
    [CCode (cname = "fluid_settings_t", cprefix = "fluid_settings_", free_function = "delete_fluid_settings", has_type_id = false)]
    public class Settings {
        [CCode (cname = "new_fluid_settings")]
        public Settings ();
        public int copystr (string name, out string str, int len);
        public int dupstr (string name, out string str);
        public void foreach (void* data, foreach_t func);
        public void foreach_option (string name, void* data, foreach_option_t func);
        public int get_hints (string name, out int hints);
        public Types get_type (string name);
        public int getint (string name, out int val);
        public int getint_default (string name, out int val);
        public int getint_range (string name, out int min, out int max);
        public int getnum (string name, out double val);
        public int getnum_default (string name, out double val);
        public int getnum_range (string name, out double min, out double max);
        public int getstr_default (string name, out string def);
        public bool is_realtime (string name);
        public string option_concat (string name, string separator);
        public int option_count (string name);
        public int setint (string name, int val);
        public int setnum (string name, double val);
        public int setstr (string name, string str);
        public bool str_equal (string name, string s);

        [SimpleType]
        [CCode (has_target = false)]
        public delegate void foreach_option_t (void* data, string name, string option);

        [SimpleType]
        [CCode (has_target = false)]
        public delegate void foreach_t (void* data, string name, int type);
    }

    [Compact]
    [CCode (cname = "fluid_sfont_t", cprefix = "fluid_sfont_", free_function = "delete_fluid_sfont", has_type_id = false)]
    public class SoundFont {
    }

    /**
      * Functions for managing audio drivers.
      */
    [Compact]
    [CCode (cname = "fluid_audio_driver_t", cprefix = "fluid_audio_", free_function = "delete_fluid_audio_driver", has_type_id = false)]
    public class AudioDriver {
        [CCode (cname = "new_fluid_audio_driver")]
        public AudioDriver (Settings settings, Synth synth);
        [CCode (cname = "new_fluid_audio_driver2")]
        public AudioDriver.with_audio_callback (Settings settings, handle_audio_func_t func, void* data);
    }

    /**
      * Parse standard MIDI files and emit MIDI events.
      */
    [Compact]
    [CCode (cname = "fluid_player_t", cprefix = "fluid_player_", free_function = "delete_fluid_player", has_type_id = false)]
    public class Player {
        [CCode (cname = "new_fluid_player")]
        public Player (Synth synth);

        public int bpm {
            get {
                return get_bpm ();
            }
        }

        public int midi_tempo {
            get {
                return get_midi_tempo ();
            }
        }

        public int current_tick {
            get {
                return get_current_tick ();
            }
        }

        public int total_ticks {
            get {
                return get_total_ticks ();
            }
        }

        public int loop {
            set {
                set_loop (value);
            }
        }

        public int add (string midifile);
        public int add_mem (void* buffer, size_t len);
        public int get_bpm ();
        public int get_current_tick ();
        public int get_midi_tempo ();
        public PlayerStatus get_status ();
        public int get_total_ticks ();
        public int join ();
        public int play ();
        public int seek (int ticks);
        public int set_loop (int loop);
        public int set_playback_callback (handle_midi_event_func_t handler, void* handler_data);
        public int set_tempo (TempoType tempo_type, double tempo);
        public int set_tick_callback (handle_midi_tick_func_t handler, void* handler_data);
        public int stop ();
    }

    /**
     * Functions to create, modify, query and delete MIDI events.
     */
    [Compact]
    [CCode (cname = "fluid_midi_event_t", cprefix = "fluid_midi_event_", free_function = "delete_fluid_midi_event", has_type_id = false)]
    public class MIDIEvent {
        [CCode (cname = "new_fluid_midi_event")]
        public MIDIEvent ();

        public int channel {
            get {
                return get_channel ();
            }
            set {
                set_channel (value);
            }
        }

        public int control {
            get {
                return get_control ();
            }
            set {
                set_control (value);
            }
        }

        public int key {
            get {
                return get_key ();
            }
            set {
                set_key (value);
            }
        }

        public int pitch {
            get {
                return get_pitch ();
            }
            set {
                set_pitch (value);
            }
        }

        public int type {
            get {
                return get_type ();
            }
            set {
                set_type (value);
            }
        }

        public int value {
            get {
                return get_value ();
            }
            set {
                set_value (value);
            }
        }

        public int velocity {
            get {
                return get_velocity ();
            }
            set {
                set_velocity (value);
            }
        }

        public int get_channel ();
        public int get_control ();
        public int get_key ();
        public int get_lyrics (void** data, out int size);
        public int get_pitch ();
        public int get_program ();
        public int get_text (void** data, out int size);
        public int get_type ();
        public int get_value ();
        public int get_velocity ();

        public int set_channel (int chan);
        public int set_control (int v);
        public int set_key (int v);
        public int set_lyrics (void* data, int size, bool dynamic);
        public int set_pitch (int val);
        public int set_program (int val);
        public int set_text (void* data, int size, bool dynamic);
        public int set_sysex (void* data, int size, bool dynamic);
        public int set_type (int type);
        public int set_value (int v);
        public int set_velocity (int v);
    }

    /**
     * Functions for managing MIDI drivers.
     */
    [Compact]
    [CCode (cname = "fluid_midi_driver_t", cprefix = "fluid_midi_driver_", free_function = "delete_fluid_midi_driver", has_type_id = false)]
    public class MIDIDriver {
        [CCode (cname = "new_fluid_midi_driver")]
        public MIDIDriver ();
    }

    /**
     * Rule based transformation and filtering of MIDI events.
     */
    [Compact]
    [CCode (cname = "fluid_midi_router_t", cprefix = "fluid_midi_router_", free_function = "delete_fluid_midi_router", has_type_id = false)]
    public class MIDIRouter {
        [CCode (cname = "new_fluid_midi_router")]
        public MIDIRouter (Settings settings, handle_midi_event_func_t handler, void* event_handler_data);

        [CCode (has_target = false)]
        public int dump_postrouter (void* data, MIDIEvent event);
        [CCode (has_target = false)]
        public int dump_prerouter (void* data, MIDIEvent event);
        public int add_rule (MIDIRouterRule rule, MIDIRouterRuleType type);
        public int clear_rules ();
        [CCode (has_target = false)]
        public int handle_midi_event (void* data, MIDIEvent event);
        public int set_default_rules ();
    }

    /**
     * MIDI ROuter Rule
     */
    [Compact]
    [CCode (cname = "fluid_midi_router_rule_t", cprefix = "fluid_midi_router_rule_", free_function = "delete_fluid_midi_router_rule", has_type_id = false)]
    public class MIDIRouterRule {
        [CCode (cname = "new_fluid_midi_router_rule")]
        public MIDIRouterRule ();

        public void set_chan (int min, int max, float mul, int add);
        public void set_param1 (int min, int max, float mul, int add);
        public void set_param2 (int min, int max, float mul, int add);
    }

    /**
     * Functions for configuring the LADSPA effects unit.
     */
    [Compact]
    [CCode (cname = "fluid_ladpsa_fx_t", cprefix = "fluid_ladpsa_", has_type_id = false)]
    public class LADSPAFx {
        public int activate ();
        public int add_buffer (string name);
        public int add_effect (string effect_name, string lib_name, string plugin_name);
        public bool buffer_exists (string name);
        public int check (char* err, int err_size);
        public int deactivate ();
        public bool effect_can_mix (string name);
        public int effect_link (string effect_name, string port_name, string name);
        public bool effect_port_exists (string effect_name, string port_name);
        public int effect_set_control (string effect_name, string port_name, float val);
        public int effect_set_mix (string name, int mix, float gain);
        public bool host_port_exists (string name);
        public bool is_active ();
        public int reset ();
    }
}
