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

#include "lv2_host.h"

#include <lilv/lilv.h>
#include <lv2/atom/forge.h>
#include <lv2/core/lv2.h>
#include <lv2/state/state.h>
#include <lv2/urid/urid.h>
#include "zix/common.h"
#include "zix/ring.h"
#include "zix/sem.h"

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

char*
lv2_host_make_path(LV2_State_Make_Path_Handle handle,
               const char*                path)
{
	Ensembles_LV2_Host* lv2_host = (Ensembles_LV2_Host*)handle;

	// Create in save directory if saving, otherwise use temp directory
	return lv2_host_strjoin(lv2_host->save_dir ? lv2_host->save_dir : lv2_host->temp_dir, path);
}

static const void*
get_port_value(const char* port_symbol,
               void*       user_data,
               uint32_t*   size,
               uint32_t*   type)
{
	Ensembles_LV2_Host*        lv2_host = (Ensembles_LV2_Host*)user_data;
	struct Port* port = lv2_host_port_by_symbol(lv2_host, port_symbol);
	if (port && port->flow == FLOW_INPUT && port->type == TYPE_CONTROL) {
		*size = sizeof(float);
		*type = lv2_host->forge.Float;
		return &port->control;
	}
	*size = *type = 0;
	return NULL;
}

void
lv2_host_save(Ensembles_LV2_Host* lv2_host, const char* dir)
{
	lv2_host->save_dir = lv2_host_strjoin(dir, "/");

	LilvState* const state = lilv_state_new_from_instance(
		lv2_host->plugin, lv2_host->instance, &lv2_host->map,
		lv2_host->temp_dir, dir, dir, dir,
		get_port_value, lv2_host,
		LV2_STATE_IS_POD|LV2_STATE_IS_PORTABLE, NULL);

	lilv_state_save(lv2_host->world, &lv2_host->map, &lv2_host->unmap, state, NULL,
	                dir, "state.ttl");

	lilv_state_free(state);

	free(lv2_host->save_dir);
	lv2_host->save_dir = NULL;
}

int
lv2_host_load_presets(Ensembles_LV2_Host* lv2_host, PresetSink sink, void* data)
{
	LilvNodes* presets = lilv_plugin_get_related(lv2_host->plugin,
	                                             lv2_host->nodes.pset_Preset);
	LILV_FOREACH(nodes, i, presets) {
		const LilvNode* preset = lilv_nodes_get(presets, i);
		lilv_world_load_resource(lv2_host->world, preset);
		if (!sink) {
			continue;
		}

		LilvNodes* labels = lilv_world_find_nodes(
			lv2_host->world, preset, lv2_host->nodes.rdfs_label, NULL);
		if (labels) {
			const LilvNode* label = lilv_nodes_get_first(labels);
			sink(lv2_host, preset, label, data);
			lilv_nodes_free(labels);
		} else {
			fprintf(stderr, "Preset <%s> has no rdfs:label\n",
			        lilv_node_as_string(lilv_nodes_get(presets, i)));
		}
	}
	lilv_nodes_free(presets);

	return 0;
}

int
lv2_host_unload_presets(Ensembles_LV2_Host* lv2_host)
{
	LilvNodes* presets = lilv_plugin_get_related(lv2_host->plugin,
	                                             lv2_host->nodes.pset_Preset);
	LILV_FOREACH(nodes, i, presets) {
		const LilvNode* preset = lilv_nodes_get(presets, i);
		lilv_world_unload_resource(lv2_host->world, preset);
	}
	lilv_nodes_free(presets);

	return 0;
}

static void
set_port_value(const char* port_symbol,
               void*       user_data,
               const void* value,
               uint32_t    ZIX_UNUSED(size),
               uint32_t    type)
{
	Ensembles_LV2_Host*        lv2_host = (Ensembles_LV2_Host*)user_data;
	struct Port* port = lv2_host_port_by_symbol(lv2_host, port_symbol);
	if (!port) {
		fprintf(stderr, "error: Preset port `%s' is missing\n", port_symbol);
		return;
	}

	float fvalue = 0.0f;
	if (type == lv2_host->forge.Float) {
		fvalue = *(const float*)value;
	} else if (type == lv2_host->forge.Double) {
		fvalue = *(const double*)value;
	} else if (type == lv2_host->forge.Int) {
		fvalue = *(const int32_t*)value;
	} else if (type == lv2_host->forge.Long) {
		fvalue = *(const int64_t*)value;
	} else {
		fprintf(stderr, "error: Preset `%s' value has bad type <%s>\n",
		        port_symbol, lv2_host->unmap.unmap(lv2_host->unmap.handle, type));
		return;
	}

	if (lv2_host->play_state != JALV_RUNNING) {
		// Set value on port struct directly
		port->control = fvalue;
	} else {
		// Send value to running plugin
		lv2_host_ui_write(lv2_host, port->index, sizeof(fvalue), 0, &fvalue);
	}

	if (lv2_host->has_ui) {
		// Update UI
		char buf[sizeof(ControlChange) + sizeof(fvalue)];
		ControlChange* ev = (ControlChange*)buf;
		ev->index    = port->index;
		ev->protocol = 0;
		ev->size     = sizeof(fvalue);
		*(float*)ev->body = fvalue;
		zix_ring_write(lv2_host->plugin_events, buf, sizeof(buf));
	}
}

void
lv2_host_apply_state(Ensembles_LV2_Host* lv2_host, LilvState* state)
{
	bool must_pause = !lv2_host->safe_restore && lv2_host->play_state == JALV_RUNNING;
	if (state) {
		if (must_pause) {
			lv2_host->play_state = JALV_PAUSE_REQUESTED;
			zix_sem_wait(&lv2_host->paused);
		}

		const LV2_Feature* state_features[9] = {
			&lv2_host->features.map_feature,
			&lv2_host->features.unmap_feature,
			&lv2_host->features.make_path_feature,
			&lv2_host->features.state_sched_feature,
			&lv2_host->features.safe_restore_feature,
			&lv2_host->features.log_feature,
			&lv2_host->features.options_feature,
			NULL
		};

		lilv_state_restore(
			state, lv2_host->instance, set_port_value, lv2_host, 0, state_features);

		if (must_pause) {
			lv2_host->request_update = true;
			lv2_host->play_state     = JALV_RUNNING;
		}
	}
}

int
lv2_host_apply_preset(Ensembles_LV2_Host* lv2_host, const LilvNode* preset)
{
	lilv_state_free(lv2_host->preset);
	lv2_host->preset = lilv_state_new_from_world(lv2_host->world, &lv2_host->map, preset);
	lv2_host_apply_state(lv2_host, lv2_host->preset);
	return 0;
}

int
lv2_host_save_preset(Ensembles_LV2_Host*       lv2_host,
                 const char* dir,
                 const char* uri,
                 const char* label,
                 const char* filename)
{
	LilvState* const state = lilv_state_new_from_instance(
		lv2_host->plugin, lv2_host->instance, &lv2_host->map,
		lv2_host->temp_dir, dir, dir, dir,
		get_port_value, lv2_host,
		LV2_STATE_IS_POD|LV2_STATE_IS_PORTABLE, NULL);

	if (label) {
		lilv_state_set_label(state, label);
	}

	int ret = lilv_state_save(
		lv2_host->world, &lv2_host->map, &lv2_host->unmap, state, uri, dir, filename);

	lilv_state_free(lv2_host->preset);
	lv2_host->preset = state;

	return ret;
}

int
lv2_host_delete_current_preset(Ensembles_LV2_Host* lv2_host)
{
	if (!lv2_host->preset) {
		return 1;
	}

	lilv_world_unload_resource(lv2_host->world, lilv_state_get_uri(lv2_host->preset));
	lilv_state_delete(lv2_host->world, lv2_host->preset);
	lilv_state_free(lv2_host->preset);
	lv2_host->preset = NULL;
	return 0;
}
