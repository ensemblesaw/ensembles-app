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

namespace Ensembles.Core.Plugins.AudioPlugins.Lv2 {
    public class LV2EvBuf : Object {
        public uint32 capacity { get; protected set; }
        private Urid atom_chunk;
        private Urid atom_sequence;
        // Unlike the original implementation, it was not possible to allocate
        // the EvBuf struct with a custom capacity in Vala. So using a pointer
        // to dynamically allocate just the buffer instead.
        private Atom.Sequence* buf;

        /**
         * Size of the atom event sequence
         */
        public uint32 size {
            get {
                if (buf.atom.type != atom_sequence) {
                    return 0;
                }

                return buf.atom.size - (uint32) sizeof (Atom.SequenceBody);
            }
        }

        /**
         * Creates a new event buffer instance.
         *
         * @param capacity maximum capacity of event buffer
         * @param atom_chunk URID of an atom chunk
         * @param atom_sequence URID of an atom sequence
         */
        public LV2EvBuf (uint32 capacity, Urid atom_chunk, Urid atom_sequence) {
            return_if_fail (capacity > 0);

            Object (
                capacity: capacity
            );

            this.atom_chunk = atom_chunk;
            this.atom_sequence = atom_sequence;
            buf = (Atom.Sequence*) Aligned.alloc0 (sizeof (Atom.Sequence) + capacity, 1, 64);

            reset (true);
        }

        /**
         * "Clears" the event buffer by resetting it's size.
         *
         * @param input whether the buffer is associated with an input port
         */
        public void reset (bool input) {
            if (input) {
                buf.atom.size = (uint32) sizeof (Atom.SequenceBody);
                buf.atom.type = (uint32) atom_sequence;
            } else {
                buf.atom.size = (uint32) capacity;
                buf.atom.type = (uint32) atom_chunk;
            }
        }

        /**
         * Returns a pointer to the event sequence.
         */
        public Atom.Sequence* get_buffer () {
            return buf;
        }

        /**
         * Returns an iterator which can be used to iterate through
         * the event sequence from the beginning.
         */
        public Iter begin () {
            return Iter () {
                evbuf = this,
                offset = 0
            };
        }

        /**
         * Returns an iterator which can be used to iterate through
         * the event sequence from the end.
         */
        public Iter end () {
            return Iter () {
                evbuf = this,
                offset = pad_size (this.size)
            };
        }

        /**
         * Iterator which allows iterating through the event sequence.
         */
        public struct Iter {
            /**
             * The event buffer which this iterator is associated with.
             */
            unowned LV2EvBuf evbuf;
            /**
             * Current position of the iterator.
             */
            uint32 offset;

            /**
             * If the iterator position is within the buffer size.
             */
            public bool is_valid () {
                return offset < evbuf.size;
            }

            /**
             * Get the iterator to the next event in the sequence.
             */
            public Iter next () {
                if (!is_valid ()) {
                    return this;
                }

                Atom.Event* aev = atom_sequence_contents (evbuf.buf, offset);

                return Iter () {
                    evbuf = evbuf,
                    offset = offset + pad_size (
                        (uint32) sizeof (Atom.Event) + aev->body.size
                    )
                };
            }

            /**
             * Retrieve event data from the current iterator position in the
             * sequence.
             *
             * @param frames MIDI clock times when the event is to be activated
             * @param subframes MIDI clock time subdivisions
             * @param size length of the event sequence
             * @param data pointer to the event sequence data
             */
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

                Atom.Event* aev = atom_sequence_contents (evbuf.buf, offset);

                frames = (uint32) aev->time_frames;
                subframes = 0;
                type = aev->body.type;
                size = aev->body.size;
                data = atom_body (&aev->body);
                return true;
            }

            /**
             * Wrties event data in the current iterator position in the
             * sequence.
             *
             * @param frames MIDI clock times when the event is to be activated
             * @param subframes MIDI clock time subdivisions
             * @param size length of the event sequence
             * @param data pointer to the event sequence data
             */
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

                Atom.Event* aev = atom_sequence_contents (evbuf.buf, offset);
                aev->time_frames = frames;
                aev->body.type = type;
                aev->body.size = size;

                //  print("writing: %ld\n", (long) aev.time_frames);

                Memory.copy (atom_body (&aev->body), data, size);

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
         * Extract the contents of an atom sequene.
         */
        public static Atom.Event* atom_sequence_contents (Atom.Sequence* atom, uint32 offset) {
            return (Atom.Event*) (((uint8*) atom) + sizeof (Atom.Sequence) + offset);
        }

        /**
         * Extract the body of an atom.
         */
        public static void* atom_body (Atom.Atom* atom) {
            return (void*) (((uint8*) atom) + sizeof (Atom.Atom));
        }
    }
}
