namespace Ensembles.Utils {
    public class Console {
        private const string RED =  "\x1B[31m";
        private const string GRN =  "\x1B[32m";
        private const string YEL =  "\x1B[33m";
        private const string BLU =  "\x1B[34m";
        private const string MAG =  "\x1B[35m";
        private const string CYN =  "\x1B[36m";
        private const string WHT =  "\x1B[37m";
        private const string BOLD = "\x1B[1m";
        private const string RESET =  "\x1B[0m";

        public static void get_console_header () {
            print (MAG);
            print ("███████ ███    ██ ███████ ███████ ███    ███ ██████  ██      ███████ ███████\n");
            print ("██      ████   ██ ██      ██      ████  ████ ██   ██ ██      ██      ██\n");
            print ("█████   ██ ██  ██ ███████ █████   ██ ████ ██ ██████  ██      █████   ███████\n");
            print ("██      ██  ██ ██      ██ ██      ██  ██  ██ ██   ██ ██      ██           ██\n");
            print ("███████ ██   ████ ███████ ███████ ██      ██ ██████  ███████ ███████ ███████\n");
            print (RED);
            print ("============================================================================\n");
            print (YEL);
            print (_("VERSION: %s, DISPLAY VERSION: %s   |   (c) SUBHADEEP JASU 2020 - 2023\n"),
             Constants.VERSION, Constants.DISPLAYVER);
            print (RED);
            print ("----------------------------------------------------------------------------\n");
            print (RESET);
        }

        public enum LogLevel {
            SUCCESS,
            TRACE,
            WARNING,
            ERROR,
        }

        public static void log (string message, LogLevel log_level) {
            DateTime date_time = new DateTime.now_utc ();
            switch (log_level) {
                case SUCCESS:
                if (Application.verbose) {
                    print ("%s▎%s%sSUCCESS %s[%s%s%s]: %s\n", GRN, WHT, BOLD, RESET, BLU, date_time.to_string (), RESET, message);
                }
                GLib.log (Constants.APP_NAME, LogLevelFlags.LEVEL_INFO, message);
                break;
                case TRACE:
                if (Application.verbose) {
                    print ("%s▎%s%sTRACE %s[%s%s%s]: %s\n", CYN, WHT, BOLD, RESET, BLU, date_time.to_string (), RESET, message);
                }
                break;
                case WARNING:
                if (Application.verbose) {
                    print ("%s▎%s%WARNING %s[%s%s%s]: %s%s%s\n", YEL, WHT, BOLD, RESET, BLU, date_time.to_string (), RESET, YEL, message, RESET);
                }
                GLib.log (Constants.APP_NAME, LogLevelFlags.LEVEL_WARNING, message);
                break;
                case ERROR:
                if (Application.verbose) {
                    print ("%s▎%s%sERROR %s[%s%s%s]: %s%s%s\n", RED, WHT, BOLD, RESET, BLU, date_time.to_string (), RESET, RED, message, RESET);
                }
                GLib.log (Constants.APP_NAME, LogLevelFlags.LEVEL_ERROR, message);
                break;
            }
        }
    }
}
