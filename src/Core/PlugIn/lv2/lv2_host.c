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

#define _POSIX_C_SOURCE 200809L /* for mkdtemp */
#define _DARWIN_C_SOURCE        /* for mkdtemp on OSX */

#include "lv2_host.h"
#include "lv2_evbuf.h"
#include "worker.h"

#include <lilv/lilv.h>
#include <lv2/atom/atom.h>
#include <lv2/atom/forge.h>
#include <lv2/atom/util.h>
#include <lv2/buf-size/buf-size.h>
#include <lv2/core/lv2.h>
#include <lv2/data-access/data-access.h>
#include <lv2/log/log.h>
#include <lv2/midi/midi.h>
#include <lv2/options/options.h>
#include <lv2/parameters/parameters.h>
#include <lv2/patch/patch.h>
#include <lv2/port-groups/port-groups.h>
#include <lv2/port-props/port-props.h>
#include <lv2/presets/presets.h>
#include <lv2/resize-port/resize-port.h>
#include <lv2/state/state.h>
#include <lv2/time/time.h>
#include <lv2/ui/ui.h>
#include <lv2/urid/urid.h>
#include <lv2/worker/worker.h>
#include <serd/serd.h>
#include <sratom/sratom.h>
#include "symap.h"
#include "zix/common.h"
#include "zix/ring.h"
#include "zix/sem.h"

#include "suil/suil.h"

#include <assert.h>
#include <math.h>
#include <signal.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#define NS_RDF "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
#define NS_XSD "http://www.w3.org/2001/XMLSchema#"

#ifndef MIN
#    define MIN(a, b) (((a) < (b)) ? (a) : (b))
#endif

#ifndef MAX
#    define MAX(a, b) (((a) > (b)) ? (a) : (b))
#endif

#ifndef ARRAY_SIZE
#    define ARRAY_SIZE(arr) (sizeof(arr) / sizeof(arr[0]))
#endif

/* Size factor for UI ring buffers.  The ring size is a few times the size of
   an event output to give the UI a chance to keep up.  Experiments with Ingen,
   which can highly saturate its event output, led me to this value.  It
   really ought to be enough for anybody(TM).
*/
#define N_BUFFER_CYCLES 16

static ZixSem* exit_sem = NULL;  /**< Exit semaphore used by signal handler*/

static LV2_URID
map_uri(LV2_URID_Map_Handle handle,
        const char*         uri)
{
	Ensembles_LV2_Host* lv2_host = (Ensembles_LV2_Host*)handle;
	zix_sem_wait(&lv2_host->symap_lock);
	const LV2_URID id = symap_map(lv2_host->symap, uri);
	zix_sem_post(&lv2_host->symap_lock);
	return id;
}

static const char*
unmap_uri(LV2_URID_Unmap_Handle handle,
          LV2_URID              urid)
{
	Ensembles_LV2_Host* lv2_host = (Ensembles_LV2_Host*)handle;
	zix_sem_wait(&lv2_host->symap_lock);
	const char* uri = symap_unmap(lv2_host->symap, urid);
	zix_sem_post(&lv2_host->symap_lock);
	return uri;
}

#define NS_EXT "http://lv2plug.in/ns/ext/"

/** These features have no data */
static const LV2_Feature static_features[] = {
	{ LV2_STATE__loadDefaultState, NULL },
	{ LV2_BUF_SIZE__powerOf2BlockLength, NULL },
	{ LV2_BUF_SIZE__fixedBlockLength, NULL },
	{ LV2_BUF_SIZE__boundedBlockLength, NULL } };

/** Return true iff Ensembles_LV2_Host supports the given feature. */
static bool
feature_is_supported(Ensembles_LV2_Host* lv2_host, const char* uri)
{
	if (!strcmp(uri, "http://lv2plug.in/ns/lv2core#isLive") ||
	    !strcmp(uri, "http://lv2plug.in/ns/lv2core#inPlaceBroken")) {
		return true;
	}

	for (const LV2_Feature*const* f = lv2_host->feature_list; *f; ++f) {
		if (!strcmp(uri, (*f)->URI)) {
			return true;
		}
	}
	return false;
}

/** Abort and exit on error */
static void
die(const char* msg)
{
	fprintf(stderr, "%s\n", msg);
	exit(EXIT_FAILURE);
}

/**
   Create a port structure from data description.  This is called before plugin
   and Jack instantiation.  The remaining instance-specific setup
   (e.g. buffers) is done later in activate_port().
*/
static void
create_port(Ensembles_LV2_Host*    lv2_host,
            uint32_t port_index,
            float    default_value)
{
	struct Port* const port = &lv2_host->ports[port_index];

	port->lilv_port = lilv_plugin_get_port_by_index(lv2_host->plugin, port_index);
	port->sys_port  = NULL;
	port->evbuf     = NULL;
	port->buf_size  = 0;
	port->index     = port_index;
	port->control   = 0.0f;
	port->flow      = FLOW_UNKNOWN;

	const bool optional = lilv_port_has_property(
		lv2_host->plugin, port->lilv_port, lv2_host->nodes.lv2_connectionOptional);

	/* Set the port flow (input or output) */
	if (lilv_port_is_a(lv2_host->plugin, port->lilv_port, lv2_host->nodes.lv2_InputPort)) {
		port->flow = FLOW_INPUT;
	} else if (lilv_port_is_a(lv2_host->plugin, port->lilv_port,
	                          lv2_host->nodes.lv2_OutputPort)) {
		port->flow = FLOW_OUTPUT;
	} else if (!optional) {
		die("Mandatory port has unknown type (neither input nor output)");
	}

	const bool hidden = !lv2_host->opts.show_hidden &&
	                    lilv_port_has_property(lv2_host->plugin,
	                                           port->lilv_port,
	                                           lv2_host->nodes.pprops_notOnGUI);

	/* Set control values */
	if (lilv_port_is_a(lv2_host->plugin, port->lilv_port, lv2_host->nodes.lv2_ControlPort)) {
		port->type    = TYPE_CONTROL;
		port->control = isnan(default_value) ? 0.0f : default_value;
		if (!hidden) {
			add_control(&lv2_host->controls, new_port_control(lv2_host, port->index));
		}
	} else if (lilv_port_is_a(lv2_host->plugin, port->lilv_port,
	                          lv2_host->nodes.lv2_AudioPort)) {
		port->type = TYPE_AUDIO;
#ifdef HAVE_JACK_METADATA
	} else if (lilv_port_is_a(lv2_host->plugin, port->lilv_port,
	                          lv2_host->nodes.lv2_CVPort)) {
		port->type = TYPE_CV;
#endif
	} else if (lilv_port_is_a(lv2_host->plugin, port->lilv_port,
	                          lv2_host->nodes.atom_AtomPort)) {
		port->type = TYPE_EVENT;
	} else if (!optional) {
		die("Mandatory port has unknown data type");
	}

	LilvNode* min_size = lilv_port_get(
		lv2_host->plugin, port->lilv_port, lv2_host->nodes.rsz_minimumSize);
	if (min_size && lilv_node_is_int(min_size)) {
		port->buf_size = lilv_node_as_int(min_size);
		lv2_host->opts.buffer_size = MAX(
			lv2_host->opts.buffer_size, port->buf_size * N_BUFFER_CYCLES);
	}
	lilv_node_free(min_size);
}

/**
   Create port structures from data (via create_port()) for all ports.
*/
void
lv2_host_create_ports(Ensembles_LV2_Host* lv2_host)
{
	lv2_host->num_ports = lilv_plugin_get_num_ports(lv2_host->plugin);
	lv2_host->ports     = (struct Port*)calloc(lv2_host->num_ports, sizeof(struct Port));
	float* default_values = (float*)calloc(
		lilv_plugin_get_num_ports(lv2_host->plugin), sizeof(float));
	lilv_plugin_get_port_ranges_float(lv2_host->plugin, NULL, NULL, default_values);

	for (uint32_t i = 0; i < lv2_host->num_ports; ++i) {
		create_port(lv2_host, i, default_values[i]);
	}

	const LilvPort* control_input = lilv_plugin_get_port_by_designation(
		lv2_host->plugin, lv2_host->nodes.lv2_InputPort, lv2_host->nodes.lv2_control);
	if (control_input) {
		const uint32_t index = lilv_port_get_index(lv2_host->plugin, control_input);
		if (lv2_host->ports[index].type == TYPE_EVENT) {
			lv2_host->control_in = index;
		} else {
			fprintf(stderr,
			        "warning: Non-event port %u has lv2:control designation, "
			        "ignored\n",
			        index);
		}
	}

	free(default_values);
}

/**
   Allocate port buffers (only necessary for MIDI).
*/
void
lv2_host_allocate_port_buffers(Ensembles_LV2_Host* lv2_host)
{
	for (uint32_t i = 0; i < lv2_host->num_ports; ++i) {
		struct Port* const port     = &lv2_host->ports[i];
		switch (port->type) {
		case TYPE_EVENT: {
			lv2_evbuf_free(port->evbuf);
			const size_t buf_size = (port->buf_size > 0)
				? port->buf_size
				: lv2_host->midi_buf_size;
			port->evbuf = lv2_evbuf_new(
				buf_size,
				lv2_host->map.map(lv2_host->map.handle,
				              lilv_node_as_string(lv2_host->nodes.atom_Chunk)),
				lv2_host->map.map(lv2_host->map.handle,
				              lilv_node_as_string(lv2_host->nodes.atom_Sequence)));
			lilv_instance_connect_port(
				lv2_host->instance, i, lv2_evbuf_get_buffer(port->evbuf));
		}
		default: break;
		}
	}
}

/**
   Get a port structure by symbol.

   TODO: Build an index to make this faster, currently O(n) which may be
   a problem when restoring the state of plugins with many ports.
*/
struct Port*
lv2_host_port_by_symbol(Ensembles_LV2_Host* lv2_host, const char* sym)
{
	for (uint32_t i = 0; i < lv2_host->num_ports; ++i) {
		struct Port* const port     = &lv2_host->ports[i];
		const LilvNode*    port_sym = lilv_port_get_symbol(lv2_host->plugin,
		                                                   port->lilv_port);

		if (!strcmp(lilv_node_as_string(port_sym), sym)) {
			return port;
		}
	}

	return NULL;
}

ControlID*
lv2_host_control_by_symbol(Ensembles_LV2_Host* lv2_host, const char* sym)
{
	for (size_t i = 0; i < lv2_host->controls.n_controls; ++i) {
		if (!strcmp(lilv_node_as_string(lv2_host->controls.controls[i]->symbol),
		            sym)) {
			return lv2_host->controls.controls[i];
		}
	}
	return NULL;
}

void
lv2_host_create_controls(Ensembles_LV2_Host* lv2_host, bool writable)
{
	const LilvPlugin* plugin         = lv2_host->plugin;
	LilvWorld*        world          = lv2_host->world;
	LilvNode*         patch_writable = lilv_new_uri(world, LV2_PATCH__writable);
	LilvNode*         patch_readable = lilv_new_uri(world, LV2_PATCH__readable);

	LilvNodes* properties = lilv_world_find_nodes(
		world,
		lilv_plugin_get_uri(plugin),
		writable ? patch_writable : patch_readable,
		NULL);
	LILV_FOREACH(nodes, p, properties) {
		const LilvNode* property = lilv_nodes_get(properties, p);
		ControlID*      record   = NULL;

		if (!writable && lilv_world_ask(world,
		                                lilv_plugin_get_uri(plugin),
		                                patch_writable,
		                                property)) {
			// Find existing writable control
			for (size_t i = 0; i < lv2_host->controls.n_controls; ++i) {
				if (lilv_node_equals(lv2_host->controls.controls[i]->node, property)) {
					record              = lv2_host->controls.controls[i];
					record->is_readable = true;
					break;
				}
			}

			if (record) {
				continue;
			}
		}

		record = new_property_control(lv2_host, property);
		if (writable) {
			record->is_writable = true;
		} else {
			record->is_readable = true;
		}

		if (record->value_type) {
			add_control(&lv2_host->controls, record);
		} else {
			fprintf(stderr, "Parameter <%s> has unknown value type, ignored\n",
			        lilv_node_as_string(record->node));
			free(record);
		}
	}
	lilv_nodes_free(properties);

	lilv_node_free(patch_readable);
	lilv_node_free(patch_writable);
}

void
lv2_host_set_control(const ControlID* control,
                 uint32_t         size,
                 LV2_URID         type,
                 const void*      body)
{
	Ensembles_LV2_Host* lv2_host = control->lv2_host;
	if (control->type == PORT && type == lv2_host->forge.Float) {
		struct Port* port = &control->lv2_host->ports[control->index];
		port->control = *(const float*)body;
	} else if (control->type == PROPERTY) {
		// Copy forge since it is used by process thread
		LV2_Atom_Forge       forge = lv2_host->forge;
		LV2_Atom_Forge_Frame frame;
		uint8_t              buf[1024];
		lv2_atom_forge_set_buffer(&forge, buf, sizeof(buf));

		lv2_atom_forge_object(&forge, &frame, 0, lv2_host->urids.patch_Set);
		lv2_atom_forge_key(&forge, lv2_host->urids.patch_property);
		lv2_atom_forge_urid(&forge, control->property);
		lv2_atom_forge_key(&forge, lv2_host->urids.patch_value);
		lv2_atom_forge_atom(&forge, size, type);
		lv2_atom_forge_write(&forge, body, size);

		const LV2_Atom* atom = lv2_atom_forge_deref(&forge, frame.ref);
		lv2_host_ui_write(lv2_host,
		              lv2_host->control_in,
		              lv2_atom_total_size(atom),
		              lv2_host->urids.atom_eventTransfer,
		              atom);
	}
}

void
lv2_host_ui_instantiate(Ensembles_LV2_Host* lv2_host, const char* native_ui_type, void* parent)
{
	lv2_host->ui_host = suil_host_new(lv2_host_ui_write, lv2_host_ui_port_index, NULL, NULL);

	const LV2_Feature parent_feature = {
		LV2_UI__parent, parent
	};
	const LV2_Feature instance_feature = {
		NS_EXT "instance-access", lilv_instance_get_handle(lv2_host->instance)
	};
	const LV2_Feature data_feature = {
		LV2_DATA_ACCESS_URI, &lv2_host->features.ext_data
	};
	const LV2_Feature idle_feature = {
		LV2_UI__idleInterface, NULL
	};
	const LV2_Feature* ui_features[] = {
		&lv2_host->features.map_feature,
		&lv2_host->features.unmap_feature,
		&instance_feature,
		&data_feature,
		&lv2_host->features.log_feature,
		&parent_feature,
		&lv2_host->features.options_feature,
		&idle_feature,
		&lv2_host->features.request_value_feature,
		NULL
	};

	const char* bundle_uri  = lilv_node_as_uri(lilv_ui_get_bundle_uri(lv2_host->ui));
	const char* binary_uri  = lilv_node_as_uri(lilv_ui_get_binary_uri(lv2_host->ui));
	char*       bundle_path = lilv_file_uri_parse(bundle_uri, NULL);
	char*       binary_path = lilv_file_uri_parse(binary_uri, NULL);

	lv2_host->ui_instance = suil_instance_new(
		lv2_host->ui_host,
		lv2_host,
		native_ui_type,
		lilv_node_as_uri(lilv_plugin_get_uri(lv2_host->plugin)),
		lilv_node_as_uri(lilv_ui_get_uri(lv2_host->ui)),
		lilv_node_as_uri(lv2_host->ui_type),
		bundle_path,
		binary_path,
		ui_features);

	lilv_free(binary_path);
	lilv_free(bundle_path);
}

bool
lv2_host_ui_is_resizable(Ensembles_LV2_Host* lv2_host)
{
	if (!lv2_host->ui) {
		return false;
	}

	const LilvNode* s   = lilv_ui_get_uri(lv2_host->ui);
	LilvNode*       p   = lilv_new_uri(lv2_host->world, LV2_CORE__optionalFeature);
	LilvNode*       fs  = lilv_new_uri(lv2_host->world, LV2_UI__fixedSize);
	LilvNode*       nrs = lilv_new_uri(lv2_host->world, LV2_UI__noUserResize);

	LilvNodes* fs_matches = lilv_world_find_nodes(lv2_host->world, s, p, fs);
	LilvNodes* nrs_matches = lilv_world_find_nodes(lv2_host->world, s, p, nrs);

	lilv_nodes_free(nrs_matches);
	lilv_nodes_free(fs_matches);
	lilv_node_free(nrs);
	lilv_node_free(fs);
	lilv_node_free(p);

	return !fs_matches && !nrs_matches;
}

void
lv2_host_ui_write(void* const    lv2_host_handle,
              uint32_t       port_index,
              uint32_t       buffer_size,
              uint32_t       protocol,
              const void*    buffer)
{
	Ensembles_LV2_Host* const lv2_host = (Ensembles_LV2_Host*)lv2_host_handle;

	if (protocol != 0 && protocol != lv2_host->urids.atom_eventTransfer) {
		fprintf(stderr, "UI write with unsupported protocol %u (%s)\n",
		        protocol, unmap_uri(lv2_host, protocol));
		return;
	}

	if (port_index >= lv2_host->num_ports) {
		fprintf(stderr, "UI write to out of range port index %u\n",
		        port_index);
		return;
	}

	if (lv2_host->opts.dump && protocol == lv2_host->urids.atom_eventTransfer) {
		const LV2_Atom* atom = (const LV2_Atom*)buffer;
		char*           str  = sratom_to_turtle(
			lv2_host->sratom, &lv2_host->unmap, "lv2_host:", NULL, NULL,
			atom->type, atom->size, LV2_ATOM_BODY_CONST(atom));
		lv2_host_ansi_start(stdout, 36);
		printf("\n## UI => Plugin (%u bytes) ##\n%s\n", atom->size, str);
		lv2_host_ansi_reset(stdout);
		free(str);
	}

	char buf[sizeof(ControlChange) + buffer_size];
	ControlChange* ev = (ControlChange*)buf;
	ev->index    = port_index;
	ev->protocol = protocol;
	ev->size     = buffer_size;
	memcpy(ev->body, buffer, buffer_size);
	zix_ring_write(lv2_host->ui_events, buf, sizeof(buf));
}

void
lv2_host_apply_ui_events(Ensembles_LV2_Host* lv2_host, uint32_t nframes)
{
	if (!lv2_host->has_ui) {
		return;
	}

	ControlChange ev;
	const size_t  space = zix_ring_read_space(lv2_host->ui_events);
	for (size_t i = 0; i < space; i += sizeof(ev) + ev.size) {
		zix_ring_read(lv2_host->ui_events, (char*)&ev, sizeof(ev));
		char body[ev.size];
		if (zix_ring_read(lv2_host->ui_events, body, ev.size) != ev.size) {
			fprintf(stderr, "error: Error reading from UI ring buffer\n");
			break;
		}
		assert(ev.index < lv2_host->num_ports);
		struct Port* const port = &lv2_host->ports[ev.index];
		if (ev.protocol == 0) {
			assert(ev.size == sizeof(float));
			port->control = *(float*)body;
		} else if (ev.protocol == lv2_host->urids.atom_eventTransfer) {
			LV2_Evbuf_Iterator    e    = lv2_evbuf_end(port->evbuf);
			const LV2_Atom* const atom = (const LV2_Atom*)body;
			lv2_evbuf_write(&e, nframes, 0, atom->type, atom->size,
			                (const uint8_t*)LV2_ATOM_BODY_CONST(atom));
		} else {
			fprintf(stderr, "error: Unknown control change protocol %u\n",
			        ev.protocol);
		}
	}
}

uint32_t
lv2_host_ui_port_index(void* const controller, const char* symbol)
{
	Ensembles_LV2_Host* const  lv2_host = (Ensembles_LV2_Host*)controller;
	struct Port* port = lv2_host_port_by_symbol(lv2_host, symbol);

	return port ? port->index : LV2UI_INVALID_PORT_INDEX;
}

void
lv2_host_init_ui(Ensembles_LV2_Host* lv2_host)
{
	// Set initial control port values
	for (uint32_t i = 0; i < lv2_host->num_ports; ++i) {
		if (lv2_host->ports[i].type == TYPE_CONTROL) {
			lv2_host_ui_port_event(lv2_host, i,
			                   sizeof(float), 0,
			                   &lv2_host->ports[i].control);
		}
	}

	if (lv2_host->control_in != (uint32_t)-1) {
		// Send patch:Get message for initial parameters/etc
		LV2_Atom_Forge       forge = lv2_host->forge;
		LV2_Atom_Forge_Frame frame;
		uint8_t              buf[1024];
		lv2_atom_forge_set_buffer(&forge, buf, sizeof(buf));
		lv2_atom_forge_object(&forge, &frame, 0, lv2_host->urids.patch_Get);

		const LV2_Atom* atom = lv2_atom_forge_deref(&forge, frame.ref);
		lv2_host_ui_write(lv2_host,
		              lv2_host->control_in,
		              lv2_atom_total_size(atom),
		              lv2_host->urids.atom_eventTransfer,
		              atom);
		lv2_atom_forge_pop(&forge, &frame);
	}
}

bool
lv2_host_send_to_ui(Ensembles_LV2_Host*       lv2_host,
                uint32_t    port_index,
                uint32_t    type,
                uint32_t    size,
                const void* body)
{
	/* TODO: Be more disciminate about what to send */
	char evbuf[sizeof(ControlChange) + sizeof(LV2_Atom)];
	ControlChange* ev = (ControlChange*)evbuf;
	ev->index    = port_index;
	ev->protocol = lv2_host->urids.atom_eventTransfer;
	ev->size     = sizeof(LV2_Atom) + size;

	LV2_Atom* atom = (LV2_Atom*)ev->body;
	atom->type = type;
	atom->size = size;

	if (zix_ring_write_space(lv2_host->plugin_events) >= sizeof(evbuf) + size) {
		zix_ring_write(lv2_host->plugin_events, evbuf, sizeof(evbuf));
		zix_ring_write(lv2_host->plugin_events, (const char*)body, size);
		return true;
	} else {
		fprintf(stderr, "Plugin => UI buffer overflow!\n");
		return false;
	}
}

bool
lv2_host_run(Ensembles_LV2_Host* lv2_host, uint32_t nframes)
{
	/* Read and apply control change events from UI */
	lv2_host_apply_ui_events(lv2_host, nframes);

	/* Run plugin for this cycle */
	lilv_instance_run(lv2_host->instance, nframes);

	/* Process any worker replies. */
	lv2_host_worker_emit_responses(&lv2_host->state_worker, lv2_host->instance);
	lv2_host_worker_emit_responses(&lv2_host->worker, lv2_host->instance);

	/* Notify the plugin the run() cycle is finished */
	if (lv2_host->worker.iface && lv2_host->worker.iface->end_run) {
		lv2_host->worker.iface->end_run(lv2_host->instance->lv2_handle);
	}

	/* Check if it's time to send updates to the UI */
	lv2_host->event_delta_t += nframes;
	bool  send_ui_updates = false;
	float update_frames   = lv2_host->sample_rate / lv2_host->ui_update_hz;
	if (lv2_host->has_ui && (lv2_host->event_delta_t > update_frames)) {
		send_ui_updates = true;
		lv2_host->event_delta_t = 0;
	}

	return send_ui_updates;
}

int
lv2_host_update(Ensembles_LV2_Host* lv2_host)
{
	/* Check quit flag and close if set. */
	if (zix_sem_try_wait(&lv2_host->done)) {
		lv2_host_close_ui(lv2_host);
		return 0;
	}

	/* Emit UI events. */
	ControlChange ev;
	const size_t  space = zix_ring_read_space(lv2_host->plugin_events);
	for (size_t i = 0;
	     i + sizeof(ev) < space;
	     i += sizeof(ev) + ev.size) {
		/* Read event header to get the size */
		zix_ring_read(lv2_host->plugin_events, (char*)&ev, sizeof(ev));

		/* Resize read buffer if necessary */
		lv2_host->ui_event_buf = realloc(lv2_host->ui_event_buf, ev.size);
		void* const buf = lv2_host->ui_event_buf;

		/* Read event body */
		zix_ring_read(lv2_host->plugin_events, (char*)buf, ev.size);

		if (lv2_host->opts.dump && ev.protocol == lv2_host->urids.atom_eventTransfer) {
			/* Dump event in Turtle to the console */
			LV2_Atom* atom = (LV2_Atom*)buf;
			char*     str  = sratom_to_turtle(
				lv2_host->ui_sratom, &lv2_host->unmap, "lv2_host:", NULL, NULL,
				atom->type, atom->size, LV2_ATOM_BODY(atom));
			lv2_host_ansi_start(stdout, 35);
			printf("\n## Plugin => UI (%u bytes) ##\n%s\n", atom->size, str);
			lv2_host_ansi_reset(stdout);
			free(str);
		}

		lv2_host_ui_port_event(lv2_host, ev.index, ev.size, ev.protocol, buf);

		if (ev.protocol == 0 && lv2_host->opts.print_controls) {
			lv2_host_print_control(lv2_host, &lv2_host->ports[ev.index], *(float*)buf);
		}
	}

	return 1;
}

static bool
lv2_host_apply_control_arg(Ensembles_LV2_Host* lv2_host, const char* s)
{
	char  sym[256];
	float val = 0.0f;
	if (sscanf(s, "%[^=]=%f", sym, &val) != 2) {
		fprintf(stderr, "warning: Ignoring invalid value `%s'\n", s);
		return false;
	}

	ControlID* control = lv2_host_control_by_symbol(lv2_host, sym);
	if (!control) {
		fprintf(stderr, "warning: Ignoring value for unknown control `%s'\n", sym);
		return false;
	}

	lv2_host_set_control(control, sizeof(float), lv2_host->urids.atom_Float, &val);
	printf("%s = %f\n", sym, val);

	return true;
}

static void
signal_handler(int ZIX_UNUSED(sig))
{
	zix_sem_post(exit_sem);
}

static void
init_feature(LV2_Feature* const dest, const char* const URI, void* data)
{
	dest->URI = URI;
	dest->data = data;
}

static void
setup_signals(Ensembles_LV2_Host* const lv2_host)
{
	exit_sem = &lv2_host->done;

#ifdef HAVE_SIGACTION
	struct sigaction action;
	sigemptyset(&action.sa_mask);
	action.sa_flags   = 0;
	action.sa_handler = signal_handler;
	sigaction(SIGINT, &action, NULL);
	sigaction(SIGTERM, &action, NULL);
#else
	/* May not work in combination with fgets in the console interface */
	signal(SIGINT, signal_handler);
	signal(SIGTERM, signal_handler);
#endif
}

static const LilvUI*
lv2_host_select_custom_ui(const Ensembles_LV2_Host* const lv2_host)
{
	const char* const native_ui_type_uri = lv2_host_native_ui_type();

	if (lv2_host->opts.ui_uri) {
		// Specific UI explicitly requested by user
		LilvNode*       uri  = lilv_new_uri(lv2_host->world, lv2_host->opts.ui_uri);
		const LilvUI*   ui   = lilv_uis_get_by_uri(lv2_host->uis, uri);

		lilv_node_free(uri);
		return ui;
	}

	if (native_ui_type_uri) {
		// Try to find an embeddable UI
		LilvNode* native_type = lilv_new_uri(lv2_host->world, native_ui_type_uri);

		LILV_FOREACH (uis, u, lv2_host->uis) {
			const LilvUI*   ui        = lilv_uis_get(lv2_host->uis, u);
			const LilvNode* type      = NULL;
			const bool      supported = lilv_ui_is_supported(
                    ui, suil_ui_supported, native_type, &type);

			if (supported) {
				lilv_node_free(native_type);
				return ui;
			}
		}

		lilv_node_free(native_type);
	}

	if (!native_ui_type_uri && lv2_host->opts.show_ui) {
		// Try to find a UI with ui:showInterface
		LILV_FOREACH (uis, u, lv2_host->uis) {
			const LilvUI*   ui      = lilv_uis_get(lv2_host->uis, u);
			const LilvNode* ui_node = lilv_ui_get_uri(ui);

			lilv_world_load_resource(lv2_host->world, ui_node);

			const bool supported = lilv_world_ask(lv2_host->world,
			                                      ui_node,
			                                      lv2_host->nodes.lv2_extensionData,
			                                      lv2_host->nodes.ui_showInterface);

			lilv_world_unload_resource(lv2_host->world, ui_node);

			if (supported) {
				return ui;
			}
		}
	}

	return NULL;
}

int
lv2_host_open(Ensembles_LV2_Host* const lv2_host, int* argc, char*** argv)
{
	lv2_host->prog_name     = (*argv)[0];
	lv2_host->block_length  = 4096;  /* Should be set by backend */
	lv2_host->midi_buf_size = 1024;  /* Should be set by backend */
	lv2_host->play_state    = JALV_PAUSED;
	lv2_host->bpm           = 120.0f;
	lv2_host->control_in    = (uint32_t)-1;

	suil_init(argc, argv, SUIL_ARG_NONE);

	if (lv2_host_init(argc, argv, &lv2_host->opts)) {
		lv2_host_close(lv2_host);
		return -1;
	}

	lv2_host->symap = symap_new();
	zix_sem_init(&lv2_host->symap_lock, 1);
	zix_sem_init(&lv2_host->work_lock, 1);

	lv2_host->map.handle  = lv2_host;
	lv2_host->map.map     = map_uri;
	init_feature(&lv2_host->features.map_feature, LV2_URID__map, &lv2_host->map);

	lv2_host->worker.lv2_host       = lv2_host;
	lv2_host->state_worker.lv2_host = lv2_host;

	lv2_host->unmap.handle  = lv2_host;
	lv2_host->unmap.unmap   = unmap_uri;
	init_feature(&lv2_host->features.unmap_feature, LV2_URID__unmap, &lv2_host->unmap);

	lv2_atom_forge_init(&lv2_host->forge, &lv2_host->map);

	lv2_host->env = serd_env_new(NULL);
	serd_env_set_prefix_from_strings(
		lv2_host->env, (const uint8_t*)"patch", (const uint8_t*)LV2_PATCH_PREFIX);
	serd_env_set_prefix_from_strings(
		lv2_host->env, (const uint8_t*)"time", (const uint8_t*)LV2_TIME_PREFIX);
	serd_env_set_prefix_from_strings(
		lv2_host->env, (const uint8_t*)"xsd", (const uint8_t*)NS_XSD);

	lv2_host->sratom    = sratom_new(&lv2_host->map);
	lv2_host->ui_sratom = sratom_new(&lv2_host->map);
	sratom_set_env(lv2_host->sratom, lv2_host->env);
	sratom_set_env(lv2_host->ui_sratom, lv2_host->env);

	lv2_host->urids.atom_Float           = symap_map(lv2_host->symap, LV2_ATOM__Float);
	lv2_host->urids.atom_Int             = symap_map(lv2_host->symap, LV2_ATOM__Int);
	lv2_host->urids.atom_Object          = symap_map(lv2_host->symap, LV2_ATOM__Object);
	lv2_host->urids.atom_Path            = symap_map(lv2_host->symap, LV2_ATOM__Path);
	lv2_host->urids.atom_String          = symap_map(lv2_host->symap, LV2_ATOM__String);
	lv2_host->urids.atom_eventTransfer   = symap_map(lv2_host->symap, LV2_ATOM__eventTransfer);
	lv2_host->urids.bufsz_maxBlockLength = symap_map(lv2_host->symap, LV2_BUF_SIZE__maxBlockLength);
	lv2_host->urids.bufsz_minBlockLength = symap_map(lv2_host->symap, LV2_BUF_SIZE__minBlockLength);
	lv2_host->urids.bufsz_sequenceSize   = symap_map(lv2_host->symap, LV2_BUF_SIZE__sequenceSize);
	lv2_host->urids.log_Error            = symap_map(lv2_host->symap, LV2_LOG__Error);
	lv2_host->urids.log_Trace            = symap_map(lv2_host->symap, LV2_LOG__Trace);
	lv2_host->urids.log_Warning          = symap_map(lv2_host->symap, LV2_LOG__Warning);
	lv2_host->urids.midi_MidiEvent       = symap_map(lv2_host->symap, LV2_MIDI__MidiEvent);
	lv2_host->urids.param_sampleRate     = symap_map(lv2_host->symap, LV2_PARAMETERS__sampleRate);
	lv2_host->urids.patch_Get            = symap_map(lv2_host->symap, LV2_PATCH__Get);
	lv2_host->urids.patch_Put            = symap_map(lv2_host->symap, LV2_PATCH__Put);
	lv2_host->urids.patch_Set            = symap_map(lv2_host->symap, LV2_PATCH__Set);
	lv2_host->urids.patch_body           = symap_map(lv2_host->symap, LV2_PATCH__body);
	lv2_host->urids.patch_property       = symap_map(lv2_host->symap, LV2_PATCH__property);
	lv2_host->urids.patch_value          = symap_map(lv2_host->symap, LV2_PATCH__value);
	lv2_host->urids.time_Position        = symap_map(lv2_host->symap, LV2_TIME__Position);
	lv2_host->urids.time_bar             = symap_map(lv2_host->symap, LV2_TIME__bar);
	lv2_host->urids.time_barBeat         = symap_map(lv2_host->symap, LV2_TIME__barBeat);
	lv2_host->urids.time_beatUnit        = symap_map(lv2_host->symap, LV2_TIME__beatUnit);
	lv2_host->urids.time_beatsPerBar     = symap_map(lv2_host->symap, LV2_TIME__beatsPerBar);
	lv2_host->urids.time_beatsPerMinute  = symap_map(lv2_host->symap, LV2_TIME__beatsPerMinute);
	lv2_host->urids.time_frame           = symap_map(lv2_host->symap, LV2_TIME__frame);
	lv2_host->urids.time_speed           = symap_map(lv2_host->symap, LV2_TIME__speed);
	lv2_host->urids.ui_updateRate        = symap_map(lv2_host->symap, LV2_UI__updateRate);

#ifdef _WIN32
	lv2_host->temp_dir = lv2_host_strdup("lv2_hostXXXXXX");
	_mktemp(lv2_host->temp_dir);
#else
	char* templ = lv2_host_strdup("/tmp/lv2_host-XXXXXX");
	lv2_host->temp_dir = lv2_host_strjoin(mkdtemp(templ), "/");
	free(templ);
#endif

	lv2_host->features.make_path.handle = lv2_host;
	lv2_host->features.make_path.path = lv2_host_make_path;
	init_feature(&lv2_host->features.make_path_feature,
	             LV2_STATE__makePath, &lv2_host->features.make_path);

	lv2_host->features.sched.handle = &lv2_host->worker;
	lv2_host->features.sched.schedule_work = lv2_host_worker_schedule;
	init_feature(&lv2_host->features.sched_feature,
	             LV2_WORKER__schedule, &lv2_host->features.sched);

	lv2_host->features.ssched.handle = &lv2_host->state_worker;
	lv2_host->features.ssched.schedule_work = lv2_host_worker_schedule;
	init_feature(&lv2_host->features.state_sched_feature,
	             LV2_WORKER__schedule, &lv2_host->features.ssched);

	lv2_host->features.llog.handle  = lv2_host;
	lv2_host->features.llog.printf  = lv2_host_printf;
	lv2_host->features.llog.vprintf = lv2_host_vprintf;
	init_feature(&lv2_host->features.log_feature,
	             LV2_LOG__log, &lv2_host->features.llog);

	lv2_host->features.request_value.handle = lv2_host;
	init_feature(&lv2_host->features.request_value_feature,
	             LV2_UI__requestValue, &lv2_host->features.request_value);

	zix_sem_init(&lv2_host->done, 0);

	zix_sem_init(&lv2_host->paused, 0);
	zix_sem_init(&lv2_host->worker.sem, 0);

	/* Find all installed plugins */
	LilvWorld* world = lilv_world_new();
	lilv_world_load_all(world);
	lv2_host->world = world;
	const LilvPlugins* plugins = lilv_world_get_all_plugins(world);

	/* Cache URIs for concepts we'll use */
	lv2_host->nodes.atom_AtomPort          = lilv_new_uri(world, LV2_ATOM__AtomPort);
	lv2_host->nodes.atom_Chunk             = lilv_new_uri(world, LV2_ATOM__Chunk);
	lv2_host->nodes.atom_Float             = lilv_new_uri(world, LV2_ATOM__Float);
	lv2_host->nodes.atom_Path              = lilv_new_uri(world, LV2_ATOM__Path);
	lv2_host->nodes.atom_Sequence          = lilv_new_uri(world, LV2_ATOM__Sequence);
	lv2_host->nodes.lv2_AudioPort          = lilv_new_uri(world, LV2_CORE__AudioPort);
	lv2_host->nodes.lv2_CVPort             = lilv_new_uri(world, LV2_CORE__CVPort);
	lv2_host->nodes.lv2_ControlPort        = lilv_new_uri(world, LV2_CORE__ControlPort);
	lv2_host->nodes.lv2_InputPort          = lilv_new_uri(world, LV2_CORE__InputPort);
	lv2_host->nodes.lv2_OutputPort         = lilv_new_uri(world, LV2_CORE__OutputPort);
	lv2_host->nodes.lv2_connectionOptional = lilv_new_uri(world, LV2_CORE__connectionOptional);
	lv2_host->nodes.lv2_control            = lilv_new_uri(world, LV2_CORE__control);
	lv2_host->nodes.lv2_default            = lilv_new_uri(world, LV2_CORE__default);
	lv2_host->nodes.lv2_enumeration        = lilv_new_uri(world, LV2_CORE__enumeration);
	lv2_host->nodes.lv2_extensionData      = lilv_new_uri(world, LV2_CORE__extensionData);
	lv2_host->nodes.lv2_integer            = lilv_new_uri(world, LV2_CORE__integer);
	lv2_host->nodes.lv2_maximum            = lilv_new_uri(world, LV2_CORE__maximum);
	lv2_host->nodes.lv2_minimum            = lilv_new_uri(world, LV2_CORE__minimum);
	lv2_host->nodes.lv2_name               = lilv_new_uri(world, LV2_CORE__name);
	lv2_host->nodes.lv2_reportsLatency     = lilv_new_uri(world, LV2_CORE__reportsLatency);
	lv2_host->nodes.lv2_sampleRate         = lilv_new_uri(world, LV2_CORE__sampleRate);
	lv2_host->nodes.lv2_symbol             = lilv_new_uri(world, LV2_CORE__symbol);
	lv2_host->nodes.lv2_toggled            = lilv_new_uri(world, LV2_CORE__toggled);
	lv2_host->nodes.midi_MidiEvent         = lilv_new_uri(world, LV2_MIDI__MidiEvent);
	lv2_host->nodes.pg_group               = lilv_new_uri(world, LV2_PORT_GROUPS__group);
	lv2_host->nodes.pprops_logarithmic     = lilv_new_uri(world, LV2_PORT_PROPS__logarithmic);
	lv2_host->nodes.pprops_notOnGUI        = lilv_new_uri(world, LV2_PORT_PROPS__notOnGUI);
	lv2_host->nodes.pprops_rangeSteps      = lilv_new_uri(world, LV2_PORT_PROPS__rangeSteps);
	lv2_host->nodes.pset_Preset            = lilv_new_uri(world, LV2_PRESETS__Preset);
	lv2_host->nodes.pset_bank              = lilv_new_uri(world, LV2_PRESETS__bank);
	lv2_host->nodes.rdfs_comment           = lilv_new_uri(world, LILV_NS_RDFS "comment");
	lv2_host->nodes.rdfs_label             = lilv_new_uri(world, LILV_NS_RDFS "label");
	lv2_host->nodes.rdfs_range             = lilv_new_uri(world, LILV_NS_RDFS "range");
	lv2_host->nodes.rsz_minimumSize        = lilv_new_uri(world, LV2_RESIZE_PORT__minimumSize);
	lv2_host->nodes.ui_showInterface       = lilv_new_uri(world, LV2_UI__showInterface);
	lv2_host->nodes.work_interface         = lilv_new_uri(world, LV2_WORKER__interface);
	lv2_host->nodes.work_schedule          = lilv_new_uri(world, LV2_WORKER__schedule);
	lv2_host->nodes.end                    = NULL;

	/* Get plugin URI from loaded state or command line */
	LilvState* state      = NULL;
	LilvNode*  plugin_uri = NULL;
	if (lv2_host->opts.load) {
		struct stat info;
		stat(lv2_host->opts.load, &info);
		if (S_ISDIR(info.st_mode)) {
			char* path = lv2_host_strjoin(lv2_host->opts.load, "/state.ttl");
			state = lilv_state_new_from_file(lv2_host->world, &lv2_host->map, NULL, path);
			free(path);
		} else {
			state = lilv_state_new_from_file(lv2_host->world, &lv2_host->map, NULL,
			                                 lv2_host->opts.load);
		}
		if (!state) {
			fprintf(stderr, "Failed to load state from %s\n", lv2_host->opts.load);
			lv2_host_close(lv2_host);
			return -2;
		}
		plugin_uri = lilv_node_duplicate(lilv_state_get_plugin_uri(state));
	} else if (*argc > 1) {
		plugin_uri = lilv_new_uri(world, (*argv)[*argc - 1]);
	}

	if (!plugin_uri) {
		fprintf(stderr, "Missing plugin URI, try lv2ls to list plugins\n");
		lv2_host_close(lv2_host);
		return -3;
	}

	/* Find plugin */
	printf("Plugin:       %s\n", lilv_node_as_string(plugin_uri));
	lv2_host->plugin = lilv_plugins_get_by_uri(plugins, plugin_uri);
	lilv_node_free(plugin_uri);
	if (!lv2_host->plugin) {
		fprintf(stderr, "Failed to find plugin\n");
		lv2_host_close(lv2_host);
		return -4;
	}

	/* Load preset, if specified */
	if (lv2_host->opts.preset) {
		LilvNode* preset = lilv_new_uri(lv2_host->world, lv2_host->opts.preset);

		lv2_host_load_presets(lv2_host, NULL, NULL);
		state = lilv_state_new_from_world(lv2_host->world, &lv2_host->map, preset);
		lv2_host->preset = state;
		lilv_node_free(preset);
		if (!state) {
			fprintf(stderr, "Failed to find preset <%s>\n", lv2_host->opts.preset);
			lv2_host_close(lv2_host);
			return -5;
		}
	}

	/* Check for thread-safe state restore() method. */
	LilvNode* state_threadSafeRestore = lilv_new_uri(
		lv2_host->world, LV2_STATE__threadSafeRestore);
	if (lilv_plugin_has_feature(lv2_host->plugin, state_threadSafeRestore)) {
		lv2_host->safe_restore = true;
	}
	lilv_node_free(state_threadSafeRestore);

	if (!state) {
		/* Not restoring state, load the plugin as a preset to get default */
		state = lilv_state_new_from_world(
			lv2_host->world, &lv2_host->map, lilv_plugin_get_uri(lv2_host->plugin));
	}

	/* Get a plugin UI */
	lv2_host->uis = lilv_plugin_get_uis(lv2_host->plugin);
	if (!lv2_host->opts.generic_ui) {
		if ((lv2_host->ui = lv2_host_select_custom_ui(lv2_host))) {
			const char* host_type_uri = lv2_host_native_ui_type();
			if (host_type_uri) {
				LilvNode* host_type = lilv_new_uri(lv2_host->world, host_type_uri);

				if (!lilv_ui_is_supported(lv2_host->ui,
				                          suil_ui_supported,
				                          host_type,
				                          &lv2_host->ui_type)) {
					lv2_host->ui = NULL;
				}

				lilv_node_free(host_type);
			}
		}
	}

	/* Create ringbuffers for UI if necessary */
	if (lv2_host->ui) {
		fprintf(stderr, "UI:           %s\n",
		        lilv_node_as_uri(lilv_ui_get_uri(lv2_host->ui)));
	} else {
		fprintf(stderr, "UI:           None\n");
	}

	/* Create port and control structures */
	lv2_host_create_ports(lv2_host);
	lv2_host_create_controls(lv2_host, true);
	lv2_host_create_controls(lv2_host, false);

	if (!(lv2_host->backend = lv2_host_backend_init(lv2_host))) {
		fprintf(stderr, "Failed to connect to audio system\n");
		lv2_host_close(lv2_host);
		return -6;
	}

	printf("Sample rate:  %u Hz\n", (uint32_t)lv2_host->sample_rate);
	printf("Block length: %u frames\n", lv2_host->block_length);
	printf("MIDI buffers: %zu bytes\n", lv2_host->midi_buf_size);

	if (lv2_host->opts.buffer_size == 0) {
		/* The UI ring is fed by plugin output ports (usually one), and the UI
		   updates roughly once per cycle.  The ring size is a few times the
		   size of the MIDI output to give the UI a chance to keep up.  The UI
		   should be able to keep up with 4 cycles, and tests show this works
		   for me, but this value might need increasing to avoid overflows.
		*/
		lv2_host->opts.buffer_size = lv2_host->midi_buf_size * N_BUFFER_CYCLES;
	}

	if (lv2_host->opts.update_rate == 0.0) {
		/* Calculate a reasonable UI update frequency. */
		lv2_host->ui_update_hz = lv2_host_ui_refresh_rate(lv2_host);
	} else {
		/* Use user-specified UI update rate. */
		lv2_host->ui_update_hz = lv2_host->opts.update_rate;
		lv2_host->ui_update_hz = MAX(1.0f, lv2_host->ui_update_hz);
	}

	/* The UI can only go so fast, clamp to reasonable limits */
	lv2_host->ui_update_hz     = MIN(60, lv2_host->ui_update_hz);
	lv2_host->opts.buffer_size = MAX(4096, lv2_host->opts.buffer_size);
	fprintf(stderr, "Comm buffers: %u bytes\n", lv2_host->opts.buffer_size);
	fprintf(stderr, "Update rate:  %.01f Hz\n", lv2_host->ui_update_hz);

	/* Build options array to pass to plugin */
	const LV2_Options_Option options[ARRAY_SIZE(lv2_host->features.options)] = {
		{ LV2_OPTIONS_INSTANCE, 0, lv2_host->urids.param_sampleRate,
		  sizeof(float), lv2_host->urids.atom_Float, &lv2_host->sample_rate },
		{ LV2_OPTIONS_INSTANCE, 0, lv2_host->urids.bufsz_minBlockLength,
		  sizeof(int32_t), lv2_host->urids.atom_Int, &lv2_host->block_length },
		{ LV2_OPTIONS_INSTANCE, 0, lv2_host->urids.bufsz_maxBlockLength,
		  sizeof(int32_t), lv2_host->urids.atom_Int, &lv2_host->block_length },
		{ LV2_OPTIONS_INSTANCE, 0, lv2_host->urids.bufsz_sequenceSize,
		  sizeof(int32_t), lv2_host->urids.atom_Int, &lv2_host->midi_buf_size },
		{ LV2_OPTIONS_INSTANCE, 0, lv2_host->urids.ui_updateRate,
		  sizeof(float), lv2_host->urids.atom_Float, &lv2_host->ui_update_hz },
		{ LV2_OPTIONS_INSTANCE, 0, 0, 0, 0, NULL }
	};
	memcpy(lv2_host->features.options, options, sizeof(lv2_host->features.options));

	init_feature(&lv2_host->features.options_feature,
	             LV2_OPTIONS__options,
	             (void*)lv2_host->features.options);

	init_feature(&lv2_host->features.safe_restore_feature,
	             LV2_STATE__threadSafeRestore,
	             NULL);

	/* Create Plugin <=> UI communication buffers */
	lv2_host->ui_events     = zix_ring_new(lv2_host->opts.buffer_size);
	lv2_host->plugin_events = zix_ring_new(lv2_host->opts.buffer_size);
	zix_ring_mlock(lv2_host->ui_events);
	zix_ring_mlock(lv2_host->plugin_events);

	/* Build feature list for passing to plugins */
	const LV2_Feature* const features[] = {
		&lv2_host->features.map_feature,
		&lv2_host->features.unmap_feature,
		&lv2_host->features.sched_feature,
		&lv2_host->features.log_feature,
		&lv2_host->features.options_feature,
		&static_features[0],
		&static_features[1],
		&static_features[2],
		&static_features[3],
		NULL
	};
	lv2_host->feature_list = calloc(1, sizeof(features));
	if (!lv2_host->feature_list) {
		fprintf(stderr, "Failed to allocate feature list\n");
		lv2_host_close(lv2_host);
		return -7;
	}
	memcpy(lv2_host->feature_list, features, sizeof(features));

	/* Check that any required features are supported */
	LilvNodes* req_feats = lilv_plugin_get_required_features(lv2_host->plugin);
	LILV_FOREACH(nodes, f, req_feats) {
		const char* uri = lilv_node_as_uri(lilv_nodes_get(req_feats, f));
		if (!feature_is_supported(lv2_host, uri)) {
			fprintf(stderr, "Feature %s is not supported\n", uri);
			lv2_host_close(lv2_host);
			return -8;
		}
	}
	lilv_nodes_free(req_feats);

	/* Instantiate the plugin */
	lv2_host->instance = lilv_plugin_instantiate(
		lv2_host->plugin, lv2_host->sample_rate, lv2_host->feature_list);
	if (!lv2_host->instance) {
		fprintf(stderr, "Failed to instantiate plugin.\n");
		lv2_host_close(lv2_host);
		return -9;
	}

	lv2_host->features.ext_data.data_access =
		lilv_instance_get_descriptor(lv2_host->instance)->extension_data;

	fprintf(stderr, "\n");
	if (!lv2_host->buf_size_set) {
		lv2_host_allocate_port_buffers(lv2_host);
	}

	/* Create workers if necessary */
	if (lilv_plugin_has_extension_data(lv2_host->plugin, lv2_host->nodes.work_interface)) {
		const LV2_Worker_Interface* iface = (const LV2_Worker_Interface*)
			lilv_instance_get_extension_data(lv2_host->instance, LV2_WORKER__interface);

		lv2_host_worker_init(lv2_host, &lv2_host->worker, iface, true);
		if (lv2_host->safe_restore) {
			lv2_host_worker_init(lv2_host, &lv2_host->state_worker, iface, false);
		}
	}

	/* Apply loaded state to plugin instance if necessary */
	if (state) {
		lv2_host_apply_state(lv2_host, state);
	}

	if (lv2_host->opts.controls) {
		for (char** c = lv2_host->opts.controls; *c; ++c) {
			lv2_host_apply_control_arg(lv2_host, *c);
		}
	}

	/* Create Jack ports and connect plugin ports to buffers */
	for (uint32_t i = 0; i < lv2_host->num_ports; ++i) {
		lv2_host_backend_activate_port(lv2_host, i);
	}

	/* Print initial control values */
	for (size_t i = 0; i < lv2_host->controls.n_controls; ++i) {
		ControlID* control = lv2_host->controls.controls[i];
		if (control->type == PORT && control->is_writable) {
			struct Port* port = &lv2_host->ports[control->index];
			lv2_host_print_control(lv2_host, port, port->control);
		}
	}

	/* Activate plugin */
	lilv_instance_activate(lv2_host->instance);

	/* Discover UI */
	lv2_host->has_ui = lv2_host_discover_ui(lv2_host);

	/* Activate Jack */
	lv2_host_backend_activate(lv2_host);
	lv2_host->play_state = JALV_RUNNING;

	return 0;
}

int
lv2_host_close(Ensembles_LV2_Host* const lv2_host)
{
	lv2_host->exit = true;

	fprintf(stderr, "Exiting...\n");

	/* Terminate the worker */
	lv2_host_worker_finish(&lv2_host->worker);

	/* Deactivate audio */
	lv2_host_backend_deactivate(lv2_host);
	for (uint32_t i = 0; i < lv2_host->num_ports; ++i) {
		if (lv2_host->ports[i].evbuf) {
			lv2_evbuf_free(lv2_host->ports[i].evbuf);
		}
	}
	lv2_host_backend_close(lv2_host);

	/* Destroy the worker */
	lv2_host_worker_destroy(&lv2_host->worker);

	/* Deactivate plugin */
	suil_instance_free(lv2_host->ui_instance);
	if (lv2_host->instance) {
		lilv_instance_deactivate(lv2_host->instance);
		lilv_instance_free(lv2_host->instance);
	}

	/* Clean up */
	free(lv2_host->ports);
	zix_ring_free(lv2_host->ui_events);
	zix_ring_free(lv2_host->plugin_events);
	for (LilvNode** n = (LilvNode**)&lv2_host->nodes; *n; ++n) {
		lilv_node_free(*n);
	}
	symap_free(lv2_host->symap);
	zix_sem_destroy(&lv2_host->symap_lock);
	suil_host_free(lv2_host->ui_host);

	for (unsigned i = 0; i < lv2_host->controls.n_controls; ++i) {
		ControlID* const control = lv2_host->controls.controls[i];
		lilv_node_free(control->node);
		lilv_node_free(control->symbol);
		lilv_node_free(control->label);
		lilv_node_free(control->group);
		lilv_node_free(control->min);
		lilv_node_free(control->max);
		lilv_node_free(control->def);
		free(control);
	}
	free(lv2_host->controls.controls);

	if (lv2_host->sratom) {
		sratom_free(lv2_host->sratom);
	}
	if (lv2_host->ui_sratom) {
		sratom_free(lv2_host->ui_sratom);
	}
	lilv_uis_free(lv2_host->uis);
	lilv_world_free(lv2_host->world);

	zix_sem_destroy(&lv2_host->done);

	remove(lv2_host->temp_dir);
	free(lv2_host->temp_dir);
	free(lv2_host->ui_event_buf);
	free(lv2_host->feature_list);

	free(lv2_host->opts.name);
	free(lv2_host->opts.load);
	free(lv2_host->opts.controls);

	return 0;
}

int
elv2_main(int argc, char** argv)
{
	Ensembles_LV2_Host lv2_host;
	memset(&lv2_host, '\0', sizeof(Ensembles_LV2_Host));

	if (lv2_host_open(&lv2_host, &argc, &argv)) {
		return EXIT_FAILURE;
	}

	/* Set up signal handlers */
	setup_signals(&lv2_host);

	/* Run UI (or prompt at console) */
	lv2_host_open_ui(&lv2_host);

	/* Wait for finish signal from UI or signal handler */
	zix_sem_wait(&lv2_host.done);

	return lv2_host_close(&lv2_host);
}
