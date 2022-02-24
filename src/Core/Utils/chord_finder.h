/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


#ifndef CHORD_FINDER_H
#define CHORD_FINDER_H

/** Chord Type Index
 * 0 - Major
 * 1 - minor
 * 2 - diminished
 * 3 - suspended 2
 * 4 - suspended 4
 * 5 - augmented
 * 6 - Dominant Sixth
 * 7 - Dominant Seventh
 * 8 - Major Seventh
 * 9 - minor seventh
 * 10 - add9
 * 11 - Dominant Ninth
 */


/** This function returns an inferred chord based on subsequent
 * invocations of note-on and note-off events
 */
int chord_finder_infer (int key, int on, int* type);

#endif /* CHORD_FINDER_H */
