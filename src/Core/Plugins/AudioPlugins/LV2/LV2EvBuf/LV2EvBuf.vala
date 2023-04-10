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

// This is a vala port of LV2 evbuf.c code written by David Robillard.

using LV2;
using URID;

namespace Ensembles.Core.Plugins.AudioPlugins.LADSPAV2 {
    /**
     * LV2 Event Buffer typically used for MIDI.
     */
    [Compact]
    [CCode (
        cname = "LV2_Evbuf",
        cprefix = "lv2_evbuf_",
        free_function = "lv2_evbuf_free",
        has_type_id = false,
        cheader_filename = "lv2_evbuf.h"
    )]
    public class LV2EvBuf {
        [CCode (cname = "lv2_evbuf_new")]
        public LV2EvBuf (uint32 capacity, Urid atom_chunk, Urid atom_sequence);

        [SimpleType]
        [CCode (
            cname = "LV2_Evbuf_Iterator",
            has_type_id = false,
            has_destroy_function = false,
            has_copy_function = false)]
        public extern struct EvBufIter {
            unowned LV2EvBuf evbuf;
            uint32 offset;

            [CCode (cname = "lv2_evbuf_is_valid")]
            public extern bool is_valid ();
            [CCode (cname = "lv2_evbuf_next")]
            public extern EvBufIter next ();
            [CCode (cname = "lv2_evbuf_get")]
            public extern bool get (
                out uint32 frames,
                out uint32 subframes,
                out uint32 type,
                [CCode (
                    array_length_pos = 3.1,
                    array_length_cname = "size",
                    array_length_type = "uint32_t"
                )] out uint8[] data);
        }

        public extern void reset (bool input);
        public extern uint32 get_size ();
        public extern unowned Atom.Sequence? get_buffer ();
        public extern EvBufIter begin ();
        public extern EvBufIter end ();
        [CCode (cname = "lv2_evbuf_write")]
        public extern static bool iter_write (
            EvBufIter? iter,
            uint32 frames,
            uint32 subframes,
            uint32 type,
            [CCode (
                type = "const uint8_t *",
                array_length_pos = 3.1,
                array_length_cname = "size",
                array_length_type = "uint32_t"
            )] uint8[] data);
    }
}
