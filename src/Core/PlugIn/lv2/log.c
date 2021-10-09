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

#include "lv2/log/log.h"
#include "lv2/urid/urid.h"

#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>

int
lv2_host_printf(LV2_Log_Handle handle,
            LV2_URID       type,
            const char*    fmt, ...)
{
	va_list args;
	va_start(args, fmt);
	const int ret = lv2_host_vprintf(handle, type, fmt, args);
	va_end(args);
	return ret;
}

int
lv2_host_vprintf(LV2_Log_Handle handle,
             LV2_URID       type,
             const char*    fmt,
             va_list        ap)
{
	// TODO: Lock
	Ensembles_LV2_Host* lv2_host  = (Ensembles_LV2_Host*)handle;
	bool  fancy = true;
	if (type == lv2_host->urids.log_Trace && lv2_host->opts.trace) {
		lv2_host_ansi_start(stderr, 32);
		fprintf(stderr, "trace: ");
	} else if (type == lv2_host->urids.log_Error) {
		lv2_host_ansi_start(stderr, 31);
		fprintf(stderr, "error: ");
	} else if (type == lv2_host->urids.log_Warning) {
		lv2_host_ansi_start(stderr, 33);
		fprintf(stderr, "warning: ");
	} else {
		fancy = false;
	}

	const int st = vfprintf(stderr, fmt, ap);

	if (fancy) {
		lv2_host_ansi_reset(stderr);
	}

	return st;
}
