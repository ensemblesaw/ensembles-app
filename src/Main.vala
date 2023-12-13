/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles;

public static int main (string[] args) {
    Environment.set_application_name (Constants.APP_NAME);
    Environment.set_prgname (Constants.APP_NAME);

    Console.greet (Constants.VERSION, Constants.DISPLAYVER);

    Services.di_container = new Vinject.Injector ();

    try {
        // Arranger Workstation Service
        Services.configure_aw_service ((aw_builder) => {
           aw_builder.use_driver (
            Ensembles.ArrangerWorkstation.AudioEngine.ISynthEngine.Driver.ALSA
            )
           .load_soundfont_with_name ("EnsemblesGM")
           .load_soundfont_from_dir (Constants.SF2DATADIR)
           .add_style_search_path (StyleRepository.get_style_dir ())
           .add_style_search_path (Environment.get_user_special_dir (
               GLib.UserDirectory.DOCUMENTS) +
               "/ensembles" +
               "/styles"
           );
        });

        // GTK 4
        Services.configure_gtkshell_service ((shell_builder) => {
            shell_builder.with_app_id (Constants.APP_ID)
            .with_name ("Ensembles")
            .with_icon_name ("com.github.ensemblesaw.ensembles")
            .has_version (Constants.VERSION, Constants.DISPLAYVER);
        });

        Console.log ("Starting application");
        return Services.di_container.obtain (Services.st_application).run (args);

        // Windows UI 3
    } catch (Vinject.VinjectErrors e) {
        error (e.message);
    }
}
