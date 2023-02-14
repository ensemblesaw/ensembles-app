[CCode(cheader_filename="fluidsynth.h", cprefix="FLUID_", lower_case_cprefix="fluid_")]
namespace Fluid {
    const int OK;
    const int FAILED;
    const string VERSION;
    const int VERSION_MAJOR;
    const int VERSION_MICRO;
    const int VERSION_MINOR;

    void free (void* ptr);
    bool is_midifile (string filename);
    bool is_soundfont (string filename);
    void version (out int major, out int minor, out int micro);
    string version_str ();

    [CCode (cprefix = "HINT_")]
    namespace Hint {
        public const int BOUNDED_ABOVE;
        public const int BOUNDED_BELOW;
        public const int OPTIONLIST;
        public const int TOGGLED;
    }

    [CCode (cname = "enum fluid_types_enum", has_type_id = false, cprefix = "FLUID_")]
    public enum Types {
        NO_TYPE,
        NUM_TYPE,
        INT_TYPE,
        STR_TYPE,
        SET_TYPE
    }

    [CCode (cname = "enum fluid_chorus_mod", has_type_id = false, cprefix = "FLUID_CHORUS_")]
    public enum ChorusMod {
        SINE,
        TRIANGLE
    }

    [CCode (cname = "enum fluid_iir_filter_flags", has_type_id = false, cprefix = "FLUID_IIR_")]
    public enum IIRFilterFlags {
        Q_LINEAR,
        Q_ZERO_OFF,
        NO_GAIN_AMP
    }

    [CCode (cname = "enum fluid_iir_filter_type", has_type_id = false, cprefix = "FLUID_IIR_")]
    public enum IIRFilterTypes {
        DISABLED,
        LOWPASS,
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
    public enum MidiChannelType {
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

    [Compact]
    [CCode (cname = "fluid_synth_t", cprefix = "fluid_synth_", free_function = "delete_fluid_synth", has_type_id = false)]
    public class Synth {
        [CCode (cname = "new_fluid_synth")]
        public Synth (Settings settings);
        public Synth get_settings ();
        public string error ();
        public double get_cpu_load ();

        // Audio Rendering
        [CCode (cname = "fluid_synth_process")]
        private int internal_process (int len, int nfx, float** fx, int nout, [CCode (cname = "out")] float** aout);
        [CCode (cname = "_v_fluid_synth_process")]
        public int process (float[,] fx, float[,] aout) {
            return internal_process (fx.length[1], fx.length[0], fx, aout.length[0], aout);
        }

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
        public int set_channel_type (int chan, MidiChannelType type);
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

        public int handle_midi_event (MidiEvent event);
    }

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

    [Compact]
    [CCode (cname = "fluid_audio_driver_t", cprefix = "fluid_audio_", free_function = "delete_fluid_audio_driver", has_type_id = false)]
    public class AudioDriver {
        [CCode (cname = "new_fluid_audio_driver")]
        public AudioDriver (Settings settings, Synth synth);
        [CCode (cname = "new_fluid_audio_driver2")]
        public AudioDriver.with_audio_callback (Settings settings, handle_audio_func_t func, void* data);

        [SimpleType]
        [CCode (cname = "fluid_audio_func_t", has_target = false)]
        public delegate int handle_audio_func_t (void* data, int len, out float[] fx, [CCode (cname = "out")] out float[] aout);
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

    [SimpleType]
    [CCode (cname = "handle_midi_event_func_t", has_target = false)]
    public delegate int handle_midi_event_func_t (void* data, MidiEvent event);

    [SimpleType]
    [CCode (cname = "handle_midi_tick_func_t", has_target = false)]
    public delegate int handle_midi_tick_func_t (void* data, int tick);

    [Compact]
    [CCode (cname = "fluid_midi_event_t", cprefix = "fluid_midi_event_", free_function = "delete_fluid_midi_event", has_type_id = false)]
    public class MidiEvent {
        [CCode (cname = "new_fluid_midi_event")]
        public MidiEvent ();

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

    [Compact]
    [CCode (cname = "fluid_midi_driver_t", cprefix = "fluid_midi_driver_", free_function = "delete_fluid_midi_driver", has_type_id = false)]
    public class MidiDriver {
        [CCode (cname = "new_fluid_midi_driver")]
        public MidiDriver ();
    }

    [Compact]
    [CCode (cname = "fluid_midi_router_t", cprefix = "fluid_midi_router_", free_function = "delete_fluid_midi_router", has_type_id = false)]
    public class MidiRouter {
        [CCode (cname = "new_fluid_midi_router")]
        public MidiRouter (Settings settings, handle_midi_event_func_t handler, void* event_handler_data);

        [CCode (has_target = false)]
        public int dump_postrouter (void* data, MidiEvent event);
        [CCode (has_target = false)]
        public int dump_prerouter (void* data, MidiEvent event);
        public int add_rule (MidiRouterRule rule, MIDIRouterRuleType type);
        public int clear_rules ();
        [CCode (has_target = false)]
        public int handle_midi_event (void* data, MidiEvent event);
        public int set_default_rules ();
    }

    [Compact]
    [CCode (cname = "fluid_midi_router_rule_t", cprefix = "fluid_midi_router_rule_", free_function = "delete_fluid_midi_router_rule", has_type_id = false)]
    public class MidiRouterRule {
        [CCode (cname = "new_fluid_midi_router_rule")]
        public MidiRouterRule ();

        public void set_chan (int min, int max, float mul, int add);
        public void set_param1 (int min, int max, float mul, int add);
        public void set_param2 (int min, int max, float mul, int add);
    }


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
