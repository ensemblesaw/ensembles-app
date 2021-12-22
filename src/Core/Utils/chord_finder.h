/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


#ifndef CHORD_FINDER_H
#define CHORD_FINDER_H

/** This function returns an inferred chord based on subsequent
 * invocations of note-on and note-off events
 */
int chord_finder_infer (int key, int on, int* type);

#endif /* CHORD_FINDER_H */
