// Copyright 2008-2022 David Robillard <d@drobilla.net>
// SPDX-License-Identifier: ISC

#ifndef LV2_EVBUF_H
#define LV2_EVBUF_H

#include <stdbool.h>
#include <stdint.h>

#include <lv2/atom/atom.h>
#include <lv2/urid/urid.h>

/// An abstract/opaque LV2 event buffer
typedef struct LV2_Evbuf_Impl LV2_Evbuf;

/// An iterator over an LV2_Evbuf
typedef struct {
  LV2_Evbuf* evbuf;
  uint32_t   offset;
} LV2_Evbuf_Iterator;

/**
   Allocate a new, empty event buffer.

   URIDs for atom:Chunk and atom:Sequence must be passed for LV2_EVBUF_ATOM.
*/
LV2_Evbuf*
lv2_evbuf_new(uint32_t capacity, uint32_t atom_Chunk, uint32_t atom_Sequence);

/**
   Clear and initialize an existing event buffer.

   The contents of buf are ignored entirely and overwritten, except capacity
   which is unmodified.  If input is false and this is an atom buffer, the
   buffer will be prepared for writing by the plugin.  This MUST be called
   before every run cycle.
*/
void
lv2_evbuf_reset(LV2_Evbuf* evbuf, bool input);

/// Return the total padded size of the events stored in the buffer
uint32_t
lv2_evbuf_get_size(LV2_Evbuf* evbuf);

/**
   Return the actual buffer implementation.

   The format of the buffer returned depends on the buffer type.
*/
LV2_Atom_Sequence *
lv2_evbuf_get_buffer(LV2_Evbuf* evbuf);

/// Return an iterator to the start of `evbuf`
LV2_Evbuf_Iterator
lv2_evbuf_begin(LV2_Evbuf* evbuf);

/// Return an iterator to the end of `evbuf`
LV2_Evbuf_Iterator
lv2_evbuf_end(LV2_Evbuf* evbuf);

/**
   Check if `iter` is valid.

   @return True if `iter` is valid, otherwise false (past end of buffer)
*/
bool
lv2_evbuf_is_valid(LV2_Evbuf_Iterator iter);

/**
   Advance `iter` forward one event.

   `iter` must be valid.

   @return True if `iter` is valid, otherwise false (reached end of buffer)
*/
LV2_Evbuf_Iterator
lv2_evbuf_next(LV2_Evbuf_Iterator iter);

/**
   Dereference an event iterator (i.e. get the event currently pointed to).

   `iter` must be valid.
   `type` Set to the type of the event.
   `size` Set to the size of the event.
   `data` Set to the contents of the event.
   @return True on success.
*/
bool
lv2_evbuf_get(LV2_Evbuf_Iterator iter,
              uint32_t*          frames,
              uint32_t*          subframes,
              uint32_t*          type,
              uint32_t*          size,
              uint8_t**          data);

/**
   Write an event at `iter`.

   The event (if any) pointed to by `iter` will be overwritten, and `iter`
   incremented to point to the following event (i.e. several calls to this
   function can be done in sequence without twiddling iter in-between).

   @return True if event was written, otherwise false (buffer is full).
*/
bool
lv2_evbuf_write(LV2_Evbuf_Iterator* iter,
                uint32_t            frames,
                uint32_t            subframes,
                uint32_t            type,
                uint32_t            size,
                const uint8_t *     data);

#endif // LV2_EVBUF_H
