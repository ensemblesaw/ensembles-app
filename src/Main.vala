/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles;

public static int main (string[] args) {
    Environment.set_application_name (Constants.APP_NAME);
    Environment.set_prgname (Constants.APP_NAME);

    Services.di_container = new Vinject.Injector ();

    try {
        Services.configure_gtkshell_service (
            Constants.APP_ID,
            Constants.VERSION,
            Constants.DISPLAYVER
        );

        Services.configure_aw_service ((aw_builder) => {
           aw_builder.use_driver (Ensembles.ArrangerWorkstation.AWCore.Driver.ALSA)
           .load_soundfont_with_name ("Ensembles")
           .load_soundfont_from_dir (Constants.SF2DATADIR)
           .add_style_search_path (StyleRepository.get_style_dir ())
           .add_style_search_path (Environment.get_user_special_dir (
               GLib.UserDirectory.DOCUMENTS) +
               "/ensembles" +
               "/styles"
           );
        });
    } catch (Vinject.VinjectErrors e) {
        Services.handle_di_error (e);
    }

    // GTK
    //  var application = new Ensembles.Application ();
    //  application.init (args);

    //  return application.run (args);
    return 0;
}
