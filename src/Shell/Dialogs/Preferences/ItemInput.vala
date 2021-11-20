/*/
*- Copyright © 2021 Subhadeep Jasu
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
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Subhadeep Jasu <subhajasu@gmail.com>
*/

public class Ensembles.Shell.Dialogs.Preferences.ItemInput : Gtk.ListBoxRow {
    Gtk.Label note_label;
    Gtk.Label key_label;
    public KeyboardConstants.KeyMap assigned_key;
    public string note;
    public uint note_index;
    public ItemInput (uint note_index, string note, KeyboardConstants.KeyMap key, bool black_key) {
        this.note_index = note_index;
        this.note = note;
        tooltip_text = _("Click to edit binding");
        assigned_key = key;
        var key_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
        note_label = new Gtk.Label (note);
        note_label.margin = 4;
        note_label.halign = Gtk.Align.START;
        key_label = new Gtk.Label (KeyboardConstants.keycode_to_string (assigned_key));
        key_label.width_request = 72;
        key_label.halign = Gtk.Align.END;
        key_label.margin = 8;
        key_label.get_style_context ().add_class ("keycap");

        key_box.pack_start (note_label);
        key_box.pack_end (key_label);

        if (black_key) {
            get_style_context ().add_class ("setings-input-item-black");
        } else {
            get_style_context ().add_class ("setings-input-item-white");
        }

        add (key_box);
    }

    public void update_labels (KeyboardConstants.KeyMap key) {
        key_label.set_text (KeyboardConstants.keycode_to_string (key));
    }
}
