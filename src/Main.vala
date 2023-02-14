/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public static int main (string[] args) {
    Environment.set_application_name (Constants.APP_NAME);
    Environment.set_prgname (Constants.APP_NAME);

    var application = new Ensembles.Application ();
    application.init ();

    return application.run (args);
}
