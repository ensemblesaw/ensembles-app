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
using URID;

namespace Ensembles.Core.Plugins.AudioPlugins.LADSPAV2 {
    public class EvBuf : Object {
        public struct Iter {
            public EvBuf evbuf;
            uint32 offset;
        }

        public uint32 capacity;
        public Urid atom_chunk;
        public Urid atom_sequence;
        public Atom.Sequence atom;

        /**
         * Creates a new `EvBuf` instance.
         */
        public EvBuf (uint32 capacity, Urid atom_chunk, Urid atom_sequence) {
            return_if_fail (capacity > 0);

            this.capacity = capacity;
            this.atom_chunk = atom_chunk;
            this.atom_sequence = atom_sequence;

            reset (true);
        }

        public void reset (bool input) {
            if (input) {
                atom.atom.size = (uint32) sizeof (Atom.SequenceBody);
                atom.atom.type = (uint32) atom_sequence;
            } else {
                atom.atom.size = capacity;
                atom.atom.type = (uint32) atom_chunk;
            }
        }

        public uint32 get_size () {
            return_val_if_fail (
                atom.atom.type != (uint32) atom_sequence ||
                atom.atom.size >= sizeof (Atom.SequenceBody),
                0
            );

            return atom.atom.type == (uint32) atom_sequence
                ? atom.atom.size - (uint32) sizeof (Atom.SequenceBody)
                : 0;
        }

        public unowned LV2.Atom.Sequence get_buffer () {
            return atom;
        }

        public Iter begin () {
            Iter evbuf_iter = Iter () {
                evbuf = this,
                offset = 0
            };

            return evbuf_iter;
        }

        public Iter end () {
            var size = get_size ();
            var iter = Iter () {
                evbuf = this,
                offset = pad_size (size)
            };
            return iter;
        }

        public Iter next (Iter iter) {
            if (!is_valid (iter)) {
                return iter;
            }

            EvBuf evbuf = iter.evbuf;
            uint32 offset = iter.offset;
            uint32 size = 0;

            size = ((Atom.Event?)
            ((char*)LV2.Atom.contents<Atom.Sequence?>(evbuf.atom)
            + offset)).body.size;
            offset += pad_size ((uint32) sizeof (Atom.Event) + size);

            var next = Iter () {
                evbuf = evbuf,
                offset = offset
            };
            return next;
        }

        private static uint32 pad_size (uint32 size) {
            return (size + 7) & (~7);
        }

        public bool is_valid (Iter iter) {
            return iter.offset < iter.evbuf.get_size ();
        }
    }
}
