/*
  Copyright 2007-2016 David Robillard <d@drobilla.net>

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
*/

#ifndef LV2_HOST_H
#define LV2_HOST_H

#define _POSIX_C_SOURCE 200809L

#include "lv2_evbuf.h"
#include "symap.h"

#include "zix/ring.h"
#include "zix/sem.h"
#include "zix/thread.h"

#include <lilv/lilv.h>
#include <serd/serd.h>
#include <sord/sord.h>
#include <sratom/sratom.h>
#include <suil/suil.h>

#include <lv2/atom/atom.h>
#include <lv2/atom/forge.h>
#include <lv2/core/lv2.h>
#include <lv2/data-access/data-access.h>
#include <lv2/log/log.h>
#include <lv2/options/options.h>
#include <lv2/state/state.h>
#include <lv2/ui/ui.h>
#include <lv2/urid/urid.h>
#include <lv2/worker/worker.h>

#ifdef HAVE_ISATTY
#    include <unistd.h>
#endif

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef __clang__
#    define REALTIME __attribute__((annotate("realtime")))
#else
#    define REALTIME
#endif

#ifdef __GNUC__
#    define JALV_LOG_FUNC(fmt, arg1) __attribute__((format(printf, fmt, arg1)))
#else
#    define JALV_LOG_FUNC(fmt, arg1)
#endif

#ifdef __cplusplus
extern "C" {
#endif

struct Ensembles_LV2_Host;

typedef struct Ensembles_LV2_HostBackend Ensembles_LV2_HostBackend;

typedef struct Ensembles_LV2_Host Ensembles_LV2_Host;

enum PortFlow {
	FLOW_UNKNOWN,
	FLOW_INPUT,
	FLOW_OUTPUT
};

enum PortType {
	TYPE_UNKNOWN,
	TYPE_CONTROL,
	TYPE_AUDIO,
	TYPE_EVENT,
	TYPE_CV
};

struct Port {
	const LilvPort* lilv_port;  ///< LV2 port
	enum PortType   type;       ///< Data type
	enum PortFlow   flow;       ///< Data flow direction
	void*           sys_port;   ///< For audio/MIDI ports, otherwise NULL
	LV2_Evbuf*      evbuf;      ///< For MIDI ports, otherwise NULL
	void*           widget;     ///< Control widget, if applicable
	size_t          buf_size;   ///< Custom buffer size, or 0
	uint32_t        index;      ///< Port index
	float           control;    ///< For control ports, otherwise 0.0f
};

/* Controls */

/** Type of plugin control. */
typedef enum {
	PORT,     ///< Control port
	PROPERTY  ///< Property (set via atom message)
} ControlType;

typedef struct {
	float value;
	char* label;
} ScalePoint;

/** Order scale points by value. */
int scale_point_cmp(const ScalePoint* a, const ScalePoint* b);

/** Plugin control. */
typedef struct {
	Ensembles_LV2_Host*       lv2_host;
	ControlType type;
	LilvNode*   node;
	LilvNode*   symbol;          ///< Symbol
	LilvNode*   label;           ///< Human readable label
	LV2_URID    property;        ///< Iff type == PROPERTY
	uint32_t    index;           ///< Iff type == PORT
	LilvNode*   group;           ///< Port/control group, or NULL
	void*       widget;          ///< Control Widget
	size_t      n_points;        ///< Number of scale points
	ScalePoint* points;          ///< Scale points
	LV2_URID    value_type;      ///< Type of control value
	LilvNode*   min;             ///< Minimum value
	LilvNode*   max;             ///< Maximum value
	LilvNode*   def;             ///< Default value
	bool        is_toggle;       ///< Boolean (0 and 1 only)
	bool        is_integer;      ///< Integer values only
	bool        is_enumeration;  ///< Point values only
	bool        is_logarithmic;  ///< Logarithmic scale
	bool        is_writable;     ///< Writable (input)
	bool        is_readable;     ///< Readable (output)
} ControlID;

ControlID*
new_port_control(Ensembles_LV2_Host* lv2_host, uint32_t index);

ControlID*
new_property_control(Ensembles_LV2_Host* lv2_host, const LilvNode* property);

typedef struct {
	size_t      n_controls;
	ControlID** controls;
} Controls;

void
add_control(Controls* controls, ControlID* control);

ControlID*
get_property_control(const Controls* controls, LV2_URID property);

/**
   Control change event, sent through ring buffers for UI updates.
*/
typedef struct {
	uint32_t index;
	uint32_t protocol;
	uint32_t size;
	uint8_t  body[];
} ControlChange;

typedef struct {
	char*    name;              ///< Client name
	int      name_exact;        ///< Exit if name is taken
	char*    load;              ///< Path for state to load
	char*    preset;            ///< URI of preset to load
	char**   controls;          ///< Control values
	uint32_t buffer_size;       ///< Plugin <= >UI communication buffer size
	double   update_rate;       ///< UI update rate in Hz
	int      dump;              ///< Dump communication iff true
	int      trace;             ///< Print trace log iff true
	int      generic_ui;        ///< Use generic UI iff true
	int      show_hidden;       ///< Show controls for notOnGUI ports
	int      no_menu;           ///< Hide menu iff true
	int      show_ui;           ///< Show non-embedded UI
	int      print_controls;    ///< Print control changes to stdout
	int      non_interactive;   ///< Do not listen for commands on stdin
	char*    ui_uri;            ///< URI of UI to load
} Ensembles_LV2_HostOptions;

typedef struct {
	LV2_URID atom_Float;
	LV2_URID atom_Int;
	LV2_URID atom_Object;
	LV2_URID atom_Path;
	LV2_URID atom_String;
	LV2_URID atom_eventTransfer;
	LV2_URID bufsz_maxBlockLength;
	LV2_URID bufsz_minBlockLength;
	LV2_URID bufsz_sequenceSize;
	LV2_URID log_Error;
	LV2_URID log_Trace;
	LV2_URID log_Warning;
	LV2_URID midi_MidiEvent;
	LV2_URID param_sampleRate;
	LV2_URID patch_Get;
	LV2_URID patch_Put;
	LV2_URID patch_Set;
	LV2_URID patch_body;
	LV2_URID patch_property;
	LV2_URID patch_value;
	LV2_URID time_Position;
	LV2_URID time_bar;
	LV2_URID time_barBeat;
	LV2_URID time_beatUnit;
	LV2_URID time_beatsPerBar;
	LV2_URID time_beatsPerMinute;
	LV2_URID time_frame;
	LV2_URID time_speed;
	LV2_URID ui_updateRate;
} Ensembles_LV2_HostURIDs;

typedef struct {
	LilvNode* atom_AtomPort;
	LilvNode* atom_Chunk;
	LilvNode* atom_Float;
	LilvNode* atom_Path;
	LilvNode* atom_Sequence;
	LilvNode* lv2_AudioPort;
	LilvNode* lv2_CVPort;
	LilvNode* lv2_ControlPort;
	LilvNode* lv2_InputPort;
	LilvNode* lv2_OutputPort;
	LilvNode* lv2_connectionOptional;
	LilvNode* lv2_control;
	LilvNode* lv2_default;
	LilvNode* lv2_enumeration;
	LilvNode* lv2_extensionData;
	LilvNode* lv2_integer;
	LilvNode* lv2_maximum;
	LilvNode* lv2_minimum;
	LilvNode* lv2_name;
	LilvNode* lv2_reportsLatency;
	LilvNode* lv2_sampleRate;
	LilvNode* lv2_symbol;
	LilvNode* lv2_toggled;
	LilvNode* midi_MidiEvent;
	LilvNode* pg_group;
	LilvNode* pprops_logarithmic;
	LilvNode* pprops_notOnGUI;
	LilvNode* pprops_rangeSteps;
	LilvNode* pset_Preset;
	LilvNode* pset_bank;
	LilvNode* rdfs_comment;
	LilvNode* rdfs_label;
	LilvNode* rdfs_range;
	LilvNode* rsz_minimumSize;
	LilvNode* ui_showInterface;
	LilvNode* work_interface;
	LilvNode* work_schedule;
	LilvNode* end;  ///< NULL terminator for easy freeing of entire structure
} Ensembles_LV2_HostNodes;

typedef enum {
	JALV_RUNNING,
	JALV_PAUSE_REQUESTED,
	JALV_PAUSED
} Ensembles_LV2_HostPlayState;

typedef struct {
	Ensembles_LV2_Host*                       lv2_host;       ///< Pointer back to Ensembles_LV2_Host
	ZixRing*                    requests;   ///< Requests to the worker
	ZixRing*                    responses;  ///< Responses from the worker
	void*                       response;   ///< Worker response buffer
	ZixSem                      sem;        ///< Worker semaphore
	ZixThread                   thread;     ///< Worker thread
	const LV2_Worker_Interface* iface;      ///< Plugin worker interface
	bool                        threaded;   ///< Run work in another thread
} Ensembles_LV2_HostWorker;

typedef struct {
	LV2_Feature                map_feature;
	LV2_Feature                unmap_feature;
	LV2_State_Make_Path        make_path;
	LV2_Feature                make_path_feature;
	LV2_Worker_Schedule        sched;
	LV2_Feature                sched_feature;
	LV2_Worker_Schedule        ssched;
	LV2_Feature                state_sched_feature;
	LV2_Log_Log                llog;
	LV2_Feature                log_feature;
	LV2_Options_Option         options[6];
	LV2_Feature                options_feature;
	LV2_Feature                safe_restore_feature;
	LV2UI_Request_Value        request_value;
	LV2_Feature                request_value_feature;
	LV2_Extension_Data_Feature ext_data;
} Ensembles_LV2_HostFeatures;

struct Ensembles_LV2_Host {
	Ensembles_LV2_HostOptions        opts;           ///< Command-line options
	Ensembles_LV2_HostURIDs          urids;          ///< URIDs
	Ensembles_LV2_HostNodes          nodes;          ///< Nodes
	LV2_Atom_Forge     forge;          ///< Atom forge
	const char*        prog_name;      ///< Program name (argv[0])
	LilvWorld*         world;          ///< Lilv World
	LV2_URID_Map       map;            ///< URI => Int map
	LV2_URID_Unmap     unmap;          ///< Int => URI map
	SerdEnv*           env;            ///< Environment for RDF printing
	Sratom*            sratom;         ///< Atom serialiser
	Sratom*            ui_sratom;      ///< Atom serialiser for UI thread
	Symap*             symap;          ///< URI map
	ZixSem             symap_lock;     ///< Lock for URI map
	Ensembles_LV2_HostBackend*       backend;        ///< Audio system backend
	ZixRing*           ui_events;      ///< Port events from UI
	ZixRing*           plugin_events;  ///< Port events from plugin
	void*              ui_event_buf;   ///< Buffer for reading UI port events
	Ensembles_LV2_HostWorker         worker;         ///< Worker thread implementation
	Ensembles_LV2_HostWorker         state_worker;   ///< Synchronous worker for state restore
	ZixSem             work_lock;      ///< Lock for plugin work() method
	ZixSem             done;           ///< Exit semaphore
	ZixSem             paused;         ///< Paused signal from process thread
	Ensembles_LV2_HostPlayState      play_state;     ///< Current play state
	char*              temp_dir;       ///< Temporary plugin state directory
	char*              save_dir;       ///< Plugin save directory
	const LilvPlugin*  plugin;         ///< Plugin class (RDF data)
	LilvState*         preset;         ///< Current preset
	LilvUIs*           uis;            ///< All plugin UIs (RDF data)
	const LilvUI*      ui;             ///< Plugin UI (RDF data)
	const LilvNode*    ui_type;        ///< Plugin UI type (unwrapped)
	LilvInstance*      instance;       ///< Plugin instance (shared library)
	SuilHost*          ui_host;        ///< Plugin UI host support
	SuilInstance*      ui_instance;    ///< Plugin UI instance (shared library)
	void*              window;         ///< Window (if applicable)
	struct Port*       ports;          ///< Port array of size num_ports
	Controls           controls;       ///< Available plugin controls
	uint32_t           block_length;   ///< Audio buffer size (block length)
	size_t             midi_buf_size;  ///< Size of MIDI port buffers
	uint32_t           control_in;     ///< Index of control input port
	uint32_t           num_ports;      ///< Size of the two following arrays:
	uint32_t           plugin_latency; ///< Latency reported by plugin (if any)
	float              ui_update_hz;   ///< Frequency of UI updates
	float              sample_rate;    ///< Sample rate
	uint32_t           event_delta_t;  ///< Frames since last update sent to UI
	uint32_t           position;       ///< Transport position in frames
	float              bpm;            ///< Transport tempo in beats per minute
	bool               rolling;        ///< Transport speed (0=stop, 1=play)
	bool               buf_size_set;   ///< True iff buffer size callback fired
	bool               exit;           ///< True iff execution is finished
	bool               has_ui;         ///< True iff a control UI is present
	bool               request_update; ///< True iff a plugin update is needed
	bool               safe_restore;   ///< Plugin restore() is thread-safe
	Ensembles_LV2_HostFeatures       features;
	const LV2_Feature** feature_list;
};

int
jalv_open(Ensembles_LV2_Host* lv2_host, int* argc, char*** argv);

int
jalv_init(int* argc, char*** argv, Ensembles_LV2_HostOptions* opts);

int
jalv_close(Ensembles_LV2_Host* lv2_host);

Ensembles_LV2_HostBackend*
jalv_backend_init(Ensembles_LV2_Host* lv2_host);

void
jalv_backend_activate(Ensembles_LV2_Host* lv2_host);

void
jalv_backend_deactivate(Ensembles_LV2_Host* lv2_host);

void
jalv_backend_close(Ensembles_LV2_Host* lv2_host);

/** Expose a port to the system (if applicable) and connect it to its buffer. */
void
jalv_backend_activate_port(Ensembles_LV2_Host* lv2_host, uint32_t port_index);

void
jalv_create_ports(Ensembles_LV2_Host* lv2_host);

void
jalv_allocate_port_buffers(Ensembles_LV2_Host* lv2_host);

struct Port*
jalv_port_by_symbol(Ensembles_LV2_Host* lv2_host, const char* sym);

void
jalv_create_controls(Ensembles_LV2_Host* lv2_host, bool writable);

ControlID*
jalv_control_by_symbol(Ensembles_LV2_Host* lv2_host, const char* sym);

void
jalv_set_control(const ControlID* control,
                 uint32_t         size,
                 LV2_URID         type,
                 const void*      body);

const char*
jalv_native_ui_type(void);

bool
jalv_discover_ui(Ensembles_LV2_Host* lv2_host);

float
jalv_ui_refresh_rate(Ensembles_LV2_Host* lv2_host);

int
jalv_open_ui(Ensembles_LV2_Host* lv2_host);

void
jalv_init_ui(Ensembles_LV2_Host* lv2_host);

int
jalv_close_ui(Ensembles_LV2_Host* lv2_host);

void
jalv_ui_instantiate(Ensembles_LV2_Host*       lv2_host,
                    const char* native_ui_type,
                    void*       parent);

bool
jalv_ui_is_resizable(Ensembles_LV2_Host* lv2_host);

void
jalv_ui_write(void*       jalv_handle,
              uint32_t    port_index,
              uint32_t    buffer_size,
              uint32_t    protocol,
              const void* buffer);

void
jalv_apply_ui_events(Ensembles_LV2_Host* lv2_host, uint32_t nframes);

uint32_t
jalv_ui_port_index(void* controller, const char* symbol);

void
jalv_ui_port_event(Ensembles_LV2_Host*       lv2_host,
                   uint32_t    port_index,
                   uint32_t    buffer_size,
                   uint32_t    protocol,
                   const void* buffer);

bool
jalv_send_to_ui(Ensembles_LV2_Host*       lv2_host,
                uint32_t    port_index,
                uint32_t    type,
                uint32_t    size,
                const void* body);
bool
jalv_run(Ensembles_LV2_Host* lv2_host, uint32_t nframes);

int
jalv_update(Ensembles_LV2_Host* lv2_host);

typedef int (*PresetSink)(Ensembles_LV2_Host*           lv2_host,
                          const LilvNode* node,
                          const LilvNode* title,
                          void*           data);

int
jalv_load_presets(Ensembles_LV2_Host* lv2_host, PresetSink sink, void* data);

int
jalv_unload_presets(Ensembles_LV2_Host* lv2_host);

int
jalv_apply_preset(Ensembles_LV2_Host* lv2_host, const LilvNode* preset);

int
jalv_delete_current_preset(Ensembles_LV2_Host* lv2_host);

int
jalv_save_preset(Ensembles_LV2_Host*       lv2_host,
                 const char* dir,
                 const char* uri,
                 const char* label,
                 const char* filename);

void
jalv_save(Ensembles_LV2_Host* lv2_host, const char* dir);

void
jalv_save_port_values(Ensembles_LV2_Host*           lv2_host,
                      SerdWriter*     writer,
                      const SerdNode* subject);
char*
jalv_make_path(LV2_State_Make_Path_Handle handle,
               const char*                path);

void
jalv_apply_state(Ensembles_LV2_Host* lv2_host, LilvState* state);

char*
atom_to_turtle(LV2_URID_Unmap* unmap,
               const SerdNode* subject,
               const SerdNode* predicate,
               const LV2_Atom* atom);

static inline void
jalv_print_control(Ensembles_LV2_Host* lv2_host, const struct Port* port, float value)
{
	const LilvNode* sym = lilv_port_get_symbol(lv2_host->plugin, port->lilv_port);
	printf("%s = %f\n", lilv_node_as_string(sym), value);
}

static inline char*
jalv_strdup(const char* str)
{
	const size_t len  = strlen(str);
	char*        copy = (char*)malloc(len + 1);
	memcpy(copy, str, len + 1);
	return copy;
}

static inline char*
jalv_strjoin(const char* a, const char* b)
{
	const size_t a_len = strlen(a);
	const size_t b_len = strlen(b);
	char* const  out   = (char*)malloc(a_len + b_len + 1);

	memcpy(out,         a, a_len);
	memcpy(out + a_len, b, b_len);
	out[a_len + b_len] = '\0';

	return out;
}

JALV_LOG_FUNC(3, 4)
int
jalv_printf(LV2_Log_Handle handle,
            LV2_URID       type,
            const char*    fmt, ...);

JALV_LOG_FUNC(3, 0)
int
jalv_vprintf(LV2_Log_Handle handle,
             LV2_URID       type,
             const char*    fmt,
             va_list        ap);

static inline bool
jalv_ansi_start(FILE* stream, int color)
{
#if defined(HAVE_ISATTY) && defined(HAVE_FILENO)
	if (isatty(fileno(stream))) {
		return fprintf(stream, "\033[0;%dm", color);
	}
#endif
	return 0;
}

static inline void
jalv_ansi_reset(FILE* stream)
{
#ifdef HAVE_ISATTY
	if (isatty(fileno(stream))) {
		fprintf(stream, "\033[0m");
		fflush(stream);
	}
#endif
}

#ifdef __cplusplus
}  // extern "C"
#endif

#endif  // LV2_HOST_H
