/*-
 * Copyright (c) 2021-2022 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu
 */

namespace Ensembles.Shell.Dialogs {
    public class ErrorDialog : Granite.MessageDialog {
        public string error_message { get; construct; }
        public bool fatal { get; construct; }
        private const int EXIT_RESPONSE_ID = 1;
        public ErrorDialog (string brief, string description, string error_message, bool fatal) {
            Object (
                title: "",
                primary_text: brief,
                secondary_text: description,
                image_icon: new ThemedIcon ("dialog-error"),
                buttons: Gtk.ButtonsType.NONE,
                modal: true,
                error_message: error_message,
                fatal: fatal
            );
        }

        construct {
            if (fatal) {
                add_button (_("Close Ensembles"), Gtk.ResponseType.CLOSE);
                add_button (_("Ignore"), Gtk.ResponseType.CLOSE);
            } else {
                add_button (_("Ignore"), Gtk.ResponseType.CLOSE);
            }
            show_error_details (error_message);

            response.connect ((response_id) => {
                if (response_id == EXIT_RESPONSE_ID) {
                    Ensembles.Application.instance.main_window.close ();
                }
                destroy ();
            });
        }
    }
}
