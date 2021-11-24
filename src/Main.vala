/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


/**
 * Main method. Responsible for starting the {@code EnsemblesApp} class.
 *
 * @see Ensembls.Shell.EnsemblesApp
 * @return {@code int}
 * @since 0.0.1
 */
public static int main (string[] args) {
    X.init_threads ();
    Gst.init (ref args);
    int argc = args.length;
    Suil.init (&argc, args, Suil.SuilArgs.NONE);
    var app = new Ensembles.Shell.EnsemblesApp ();
    var ret = app.run (args);
    return ret;
}
