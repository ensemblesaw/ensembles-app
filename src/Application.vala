/*
 * Copyright 2020-2023 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles {
    public Services.Settings settings;

    public class Application : Gtk.Application {
        static Application _instance = null;

        public static Application instance {
            get {
                if (_instance == null) {
                    _instance = new Application ();
                }
                return _instance;
            }
        }

        private string[] ? arg_file = null;
        public static bool raw_midi_input = false;
        public static bool kiosk_mode = false;
        public static bool verbose = false;

        public static Shell.MainWindow main_window;
        public static Core.ArrangerWorkstation arranger_workstation;

        construct {
            flags |= ApplicationFlags.HANDLES_OPEN | ApplicationFlags.HANDLES_COMMAND_LINE;
            application_id = Constants.APP_ID;
            settings = new Services.Settings ();
        }

        protected override void activate () {
            Console.log ("Initializing Arranger Workstation");
            arranger_workstation = new Core.ArrangerWorkstation ();

            Console.log ("Initializing GUI Theme");
            Services.Theme.init_theme ();

            Console.log ("Initializing Main Window");
            main_window = new Shell.MainWindow (this);
            this.add_window (main_window);
            main_window.show_ui ();
            Console.log ("Initialization Complete!", Console.LogLevel.SUCCESS);

            if (settings.version != Constants.VERSION) {
                settings.version = Constants.VERSION;
            }

            if (Constants.PROFILE == "development") {

            }
        }

        protected override int command_line (ApplicationCommandLine cmd) {
            string[] args_cmd = cmd.get_arguments ();
            unowned string[] args = args_cmd;

            GLib.OptionEntry [] options = new OptionEntry [5];
            options [0] = { "", 0, 0, OptionArg.STRING_ARRAY, ref arg_file, null, "URI" };
            options [1] = { "raw", 0, 0, OptionArg.NONE, ref raw_midi_input, _("Enable Raw MIDI Input"), null };
            options [2] = { "kiosk", 0, 0, OptionArg.NONE, ref kiosk_mode, _("Only show the info display"), null };
            options [3] = { "verbose", 0, 0, OptionArg.NONE, ref verbose, _("Print debug messages to terminal"), null };
            options [4] = { null };

            var opt_context = new OptionContext ("actions");
            opt_context.add_main_entries (options, null);
            try {
                opt_context.parse (ref args);
            } catch (Error err) {
                warning (err.message);
                return -1;
            }

            if (verbose || raw_midi_input || kiosk_mode) {
                Console.get_console_header ();
            }

            if (raw_midi_input) {
                print ("Raw MIDI Input Enabled! You can now enable midi input and connect your DAW\n");
            }

            if (kiosk_mode) {
                print ("Starting Ensembles in Kiosk Mode\n");
            }

            if (arg_file != null && arg_file[0] != null) {
                if (GLib.FileUtils.test (arg_file[0], GLib.FileTest.EXISTS) &&
                    arg_file[0].down ().has_suffix (".mid")) {
                    File file = File.new_for_path (arg_file[0]);
                    open ({ file }, "");
                    return 0;
                }
            }

            activate ();
            return 0;
        }

        public void init (string[] args) {
            X.init_threads ();
        }
    }
}
