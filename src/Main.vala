/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public static int main (string[] args) {
    Environment.set_application_name (Constants.APP_NAME);
    Environment.set_prgname (Constants.APP_NAME);

    var application = new Ensembles.Application ();
    application.init (args);

    return application.run (args);
}
