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

// This is a vala gobject port of LV2 evbuf.c code written by David Robillard.

using LV2;
using LV2.URID;

namespace Ensembles.Core.Plugins.AudioPlugins.LADSPAV2 {
    public class LV2EvBuf : Object {
        public uint32 capacity { get; protected set; }
        private Urid atom_chunk;
        private Urid atom_sequence;
        private Atom.Sequence buf;

        public uint32 size {
            get {
                if (buf.atom.type != atom_sequence) {
                    return 0;
                }

                return buf.atom.size - (uint32) sizeof (Atom.SequenceBody);
            }
        }

        public LV2EvBuf (uint32 capacity, Urid atom_chunk, Urid atom_sequence) {
            return_if_fail (capacity > 0);

            Object (
                capacity: capacity
            );

            this.atom_chunk = atom_chunk;
            this.atom_sequence = atom_sequence;
            buf = Atom.Sequence ();

            reset (true);
        }

        public void reset (bool input) {
            if (input) {
                buf.atom.size = (uint32) sizeof (Atom.SequenceBody);
                buf.atom.type = (uint32) atom_sequence;
            } else {
                buf.atom.size = (uint32) capacity;
                buf.atom.type = (uint32) atom_chunk;
            }
        }

        public Atom.Sequence* get_buffer () {
            return &buf;
        }

        public struct Iter {
            public unowned LV2EvBuf? evbuf;
            public uint32 offset;

            public Iter begin (LV2EvBuf evbuf) {
                return Iter () {
                    evbuf = evbuf,
                    offset = 0
                };
            }

            public Iter end (LV2EvBuf evbuf) {
                return Iter () {
                    evbuf = evbuf,
                    offset = pad_size (evbuf.size)
                };
            }

            public bool is_valid () {
                return offset < evbuf.size;
            }

            public Iter next () {
                if (!is_valid ()) {
                    return this;
                }

                Atom.Event? aev = (
                    (Atom.Event?)
                    ((char*) atom_contents (evbuf.buf) + offset)
                );

                return Iter () {
                    evbuf = evbuf,
                    offset = offset + pad_size (
                        (uint32) sizeof (Atom.Event) + aev.body.size
                    )
                };
            }

            public bool get (
                out uint32 frames,
                out uint32 subframes,
                out uint32 type,
                out uint32 size,
                out uint8* data
            ) {
                frames = subframes = type = size = 0;
                data = null;

                if (!is_valid ()) {
                    return false;
                }

                unowned Atom.Event? aev = (
                    (Atom.Event?)
                    ((char*) atom_contents (evbuf.buf) + offset
                ));

                frames = (uint32) aev.time_frames;
                subframes = 0;
                type = aev.body.type;
                size = aev.body.size;
                return true;
            }

            public bool write (
                uint32 frames,
                uint32 subframes,
                uint32 type,
                uint32 size,
                uint8* data
            ) {
                if (
                    (evbuf.capacity - sizeof (Atom.Atom) - evbuf.buf.atom.size)
                    < (sizeof (Atom.Event) + size)
                ) {
                    return false;
                }

                Atom.Event? aev = (
                    (Atom.Event?)
                    ((char*) atom_contents (evbuf.buf) + offset)
                );
                aev.time_frames = frames;
                aev.body.type = type;
                aev.body.size = size;

                Memory.copy (atom_body (aev.body), data, size);

                var _size = pad_size ((uint32) sizeof (Atom.Event) + size);
                evbuf.buf.atom.size += _size;
                offset += _size;

                return true;
            }
        }

        /**
         * Round up the value of "size" to the nearest multiple of 8.
         */
        public static uint32 pad_size (uint32 size) {
            return (size + 7) & (~7);
        }

        /**
         * Extract the contents of an atom.
         */
        public static void* atom_contents (Atom.Sequence? atom) {
            return (void*) ((uint8*) (atom) + sizeof (Atom.Sequence));
        }

        /**
         * Extract the body of an atom.
         */
        public static void* atom_body (Atom.Atom? atom) {
            return (void*) ((uint8*) (atom) + sizeof (Atom.Atom));
        }
    }
}
