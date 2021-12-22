/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


#ifndef STYLE_ANALYSER_H
#define STYLE_ANALYSER_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "../../ChoppingBlock/central_bus.h"

/** This function is audit styles and fill the style specification buffers
 * for use with style player and analysis
 */
int style_analyser_analyze (char* mid_file);

#endif /* STYLE_ANALYSER_H */
