/*
 * Copyright 2023-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
/*
 * This file incorporates work covered by the following copyright and
 * permission notice:
 *
 * ---
 *
    Copyright 2011-2022 David Robillard <d@drobilla.net>

    Permission to use, copy, modify, and/or distribute this software for any
    purpose with or without fee is hereby granted, provided that the above
    copyright notice and this permission notice appear in all copies.

    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
    REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
    FITNESS.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
    INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
    LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
    OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
    PERFORMANCE OF THIS SOFTWARE.
 *
 * ---
 */

[CCode (cprefix="ZIX_", lower_case_cprefix="zix_")]
namespace Zix {
    /** A status code returned by functions. */
    [CCode (cname = "ZixStatus", has_type_id = false, cprefix = "ZIX_STATUS_")]
    public enum Status {
        /** Success. */
        SUCCESS,
        /** Unknown Error. */
        ERROR,
        /** Out of memory. */
        NO_MEM,
        /** Not found. */
        NOT_FOUND,
        /** Exists. */
        EXISTS,
        /** Bad Argument. */
        BAD_ARG,
        /** Bad Permissions. */
        BAD_PERMS,
        /** Reached end. */
        REACHED_END,
        /** Timeout. */
        TIMEOUT,
        /** Overflow. */
        OVERFLOW,
        /** Not Supported. */
        NOT_SUPPORTED,
        /** Resource unavailable. */
        UNAVAILABLE,
        /** Out of storage space. */
        NO_SPACE,
        /** Too many links. */
        MAX_LINKS
    }

    [Compact]
    [CCode (cheader_filename = "zix/allocator.h", cname = "ZixAllocator", cprefix = "zix_", free_function = "zix_free", has_type_id = false)]
    public class Allocator {

    }

    [Compact]
    [CCode (cheader_filename = "zix/ring.h", cname = "ZixRing", cprefix = "zix_ring_", free_function = "zix_ring_free", has_type_id = false)]
    public class Ring {
        // Setup
        /**
         * Creates a new `Ring` instance.
         *
         * At most size - 1 bytes may be stored in the ring at once.
         *
         * @param allocator allocator for the ring object and its array
         * @param size size of the ring in bytes (note this may be rounded up)
         */
        public Ring (Allocator? allocator, uint32 size);
        /**
         * Lock the ring data into physical memory.
         *
         * This function is NOT thread safe or real-time safe, but it should be
         * called after zix_ring_new() to lock all ring memory to avoid page
         * faults while using the ring.
         */
        public Status mlock ();
        public void reset ();
        public uint32 capacity ();

        // Reading
        public uint32 read_space ();
        public uint32 peak (void* dst, uint32 size);
        public uint32 read (void* dst, uint32 size);
        public uint32 skip (uint32 size);

        // Writing
        [SimpleType]
        [CCode (cname = "ZixRingTransaction", cprefix = "", free_function = "", destroy_function = "", has_type_id = false)]
        public struct Transaction {
            uint32 read_head;
            uint32 write_head;
        }

        public uint32 write_space ();
        public uint32 write ([CCode (type="const void*")] void* src, uint32 size);
        public Transaction begin_write ();
        public Status amend_write (Transaction? tx, [CCode (type="const void*")] void* src, uint32 size);
        public Status commit_write (Transaction? tx);

    }

    [CCode (cheader_filename = "zix/sem.h", cname = "ZixSem", cprefix = "zix_sem_", destroy_function = "", has_type_id = false)]
    public struct Sem {
        public static Status init (out Sem sem, uint initial);
        public Status destroy ();
        public Status post ();
        public Status wait ();
        public Status try_wait ();
        public Status timed_wait (uint32 seconds, uint32 nanoseconds);
    }

    [SimpleType]
    [CCode (cheader_filename = "zix/thread.h", cname = "ZixThread", cprefix = "zix_thread_", destroy_function = "", has_type_id = false)]
    public struct Thread {
        public static Status create (out Thread thread, size_t stack_size, ThreadFunc function);
        public Status join ();
    }

    [SimpleType]
    [CCode (cheader_filename = "zix/thread.h", cname = "ZixThreadResult")]
    public struct ThreadResult {
    }

    public delegate ThreadResult ThreadFunc ();
}
