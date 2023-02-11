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
        note_label = new Gtk.Label (note) {
            margin_top = 4,
            margin_end = 4,
            margin_start = 4,
            margin_bottom = 4,
            halign = Gtk.Align.START
        };
        key_label = new Gtk.Label (KeyboardConstants.keycode_to_string (assigned_key)) {
            width_request = 72,
            halign = Gtk.Align.END,
            margin_top = 8,
            margin_bottom = 8,
            margin_start = 8,
            margin_end = 8
        };
        key_label.get_style_context ().add_class ("keycap");

        key_box.append (note_label);
        key_box.append (key_label);

        if (black_key) {
            get_style_context ().add_class ("setings-input-item-black");
        } else {
            get_style_context ().add_class ("setings-input-item-white");
        }

        set_child (key_box);
    }

    public void update_labels (KeyboardConstants.KeyMap key) {
        key_label.set_text (KeyboardConstants.keycode_to_string (key));
    }
}
