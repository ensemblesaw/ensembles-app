/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/*
 * This file is part of Ensembles
 */

public static int main (string[] args) {
    X.init_threads ();                                                          // Required for better multi-threaded process handling
    Gst.init (ref args);                                                   // Initialise G-Streamer (Required for Sampling Pads)
    int argc = args.length;
    Suil.init (&argc, args, Suil.SuilArgs.NONE);                 // Required for LV2 Plug-in UI
    var app = new Ensembles.Application ();                                     // Get instance of app
    var ret = app.run (args);                                         // Run the app
    return ret;
}
