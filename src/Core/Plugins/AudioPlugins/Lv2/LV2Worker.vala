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
  Copyright 2008-2016 David Robillard <http://drobilla.net>

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
 *
 * ---
 */

// This is a vala gobject port of Jalv worker.c code written by David Robillard.

using LV2;

namespace Ensembles.Core.Plugins.AudioPlugins.Lv2 {
    public class LV2Worker : Object {
        private Zix.Ring requests;                          ///< Requests to the worker
        private Zix.Ring responses;                         ///< Responses from the worker
        private void* response;
        private Zix.Sem lock;
        private bool exit;
        private Zix.Sem sem;
        private GLib.Thread thread;
        private LV2.Handle handle;
        private LV2.Worker.Interface? iface;
        private bool threaded;

        private static Worker.Status write_packet (Zix.Ring target, [CCode (type="const uint32_t")] uint32 size, [CCode (type="const void*")] void* data) {
            Zix.Ring.Transaction tx = target.begin_write ();
            if (target.amend_write (tx, &size, (uint32) sizeof(uint32)) != Zix.Status.SUCCESS ||
                target.amend_write (tx, data, size) != Zix.Status.SUCCESS) {
                return Worker.Status.ERR_NO_SPACE;
            }

            target.commit_write (tx);
            return Worker.Status.SUCCESS;
        }

        private static Worker.Status respond (Worker.RespondHandle handle, [CCode (type="const uint32_t")] uint32 size, [CCode (type="const void*")] void* data) {
            return write_packet (((LV2Worker) handle).responses, size, data);
        }

        public static void* func ([CCode (type="void* const")] void* data) {
            LV2Worker worker = (LV2Worker) data;
            void* buf = null;

            while (true) {
                // Wait for a request
                worker.sem.wait ();
                if (worker.exit) {
                    break;
                }

                // Read the size header of request
                uint32 size = 0;
                worker.requests.read (&size, (uint32) sizeof(uint32));

                // Reallocate buffer to allocate request if necessary
                void* new_buf = realloc (buf, size);
                if (new_buf != null) {
                    // Read request into buffer
                    buf = new_buf;
                    worker.requests.read (buf, size);

                    // Lock and dispatch request to plugin's work handler
                    worker.lock.wait ();
                    worker.iface.work (
                        worker.handle,
                        respond,
                        (LV2.Worker.RespondHandle) worker,
                        size, buf
                    );
                    worker.lock.post ();
                } else {
                    // Reallocation failed, skip request to avoid corrupting ring
                    worker.requests.skip (size);
                }
            }

            free (buf);
            return null;
        }
    }
}

// This is required as the library zix doesn't yet have typedefs for this function pointer
[CCode (cname = " interface_work_t", has_target = false)]
public extern delegate LV2.Worker.Status interface_work_t (LV2.Handle instance, LV2.Worker.respond_func_t respond, LV2.Worker.RespondHandle handle, uint32 size, void* data);
