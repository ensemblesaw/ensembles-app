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
        private unowned Zix.Sem zix_lock;
        private bool queue_exit;
        private Zix.Sem sem;
        private Zix.Thread thread;
        public Handle handle;
        private unowned Worker.Interface? iface;
        public bool threaded { get; private set; }

        private const uint MAX_PACKET_SIZE = 4096U;

        public LV2Worker (Zix.Sem zix_lock, bool threaded) {
            this.threaded = threaded;
            responses = new Zix.Ring (null, MAX_PACKET_SIZE);;
            response = Posix.calloc (1, MAX_PACKET_SIZE);;
            this.zix_lock = zix_lock;
            queue_exit = false;

            responses.mlock ();

            if (threaded && launch () != SUCCESS) {
                free (response);
            }
        }

        ~LV2Worker () {
            exit ();
            free (response);
        }

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

        public Zix.Thread.Result func () {
            void* buf = null;

            while (true) {
                // Wait for a request
                sem.wait ();
                if (queue_exit) {
                    break;
                }

                // Read the size header of request
                uint32 size = 0;
                requests.read (&size, (uint32) sizeof(uint32));

                // Reallocate buffer to allocate request if necessary
                void* new_buf = realloc (buf, size);
                if (new_buf != null) {
                    // Read request into buffer
                    buf = new_buf;
                    requests.read (buf, size);

                    // Lock and dispatch request to plugin's work handler
                    zix_lock.wait ();
                    iface.work (
                        handle,
                        respond,
                        (LV2.Worker.RespondHandle) this,
                        size, buf
                    );
                    zix_lock.post ();
                } else {
                    // Reallocation failed, skip request to avoid corrupting ring
                    requests.skip (size);
                }
            }

            free (buf);
            return (Zix.Thread.Result) null;
        }

        public Zix.Status launch () {
            var st = Zix.Sem.init (out sem, 0);

            if (st != Zix.Status.SUCCESS) {
                return st;
            } else {
                st = Zix.Thread.create (out thread, MAX_PACKET_SIZE, func);

                if (st != Zix.Status.SUCCESS) {
                    return st;
                }
            }

            var _requests = new Zix.Ring (null, MAX_PACKET_SIZE);

            if (_requests == null) {
                thread.join ();
                sem.destroy ();
                st = Zix.Status.NO_MEM;
                return st;
            }

            _requests.mlock ();
            requests = (owned) _requests;
            return st;
        }

        public void start (Worker.Interface iface, Handle handle) {
            this.iface = iface;
            this.handle = handle;
        }

        public void exit () {
            if (threaded) {
                queue_exit = true;
                sem.post ();
                thread.join ();
                threaded = false;
            }
        }

        public Worker.Status schedule (uint32 size, void* data) {
            var st = Worker.Status.SUCCESS;

            if (size == 0) {
                st = Worker.Status.ERR_UNKNOWN;
            }

            if (threaded) {
                 // Schedule a request to be executed by the worker thread
                st = write_packet (requests, size, data);
                if (st == Worker.Status.SUCCESS) {
                    sem.post ();
                }
            } else {
                zix_lock.wait ();
                st = iface.work (
                    handle,
                    respond,
                    (LV2.Worker.RespondHandle) this,
                    size,
                    data
                );
                zix_lock.post ();
            }

            return st;
        }

        public void emit_responses (Handle lv2_handle) {
            const uint32 size_size = (uint32) sizeof(uint32);

            if (responses != null) {
                uint32 size = 0U;
                while (responses.read (&size, size_size) == size_size) {
                    if (responses.read (response, size) == size) {
                        iface.work_response (lv2_handle, size, response);
                    }
                }
            }
        }

        public void end_run () {
            if (iface != null && iface.end_run != null) {
                iface.end_run (handle);
            }
        }
    }
}

// These are required as the library Worker doesn't yet have typedefs for these function pointers in Interface
[CCode (cname = " interface_work_t", has_target = false)]
extern delegate Worker.Status InterfaceWorkFunc (Handle instance, Worker.RespondFunc respond, Worker.RespondHandle handle, uint32 size, void* data);
[CCode (cname = " interface_work_reponse_t", has_target = false)]
extern delegate Worker.Status InterfaceWorkResponseFunc (Handle instance, uint32 size, [CCode (type="const void*")] void* body);
[CCode (cname = " interface_end_run_t", has_target = false)]
extern delegate Worker.Status InterfaceEndRunFunc (Handle instance);
