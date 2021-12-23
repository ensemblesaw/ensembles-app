/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
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
