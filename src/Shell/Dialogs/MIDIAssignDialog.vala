/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

 namespace Ensembles.Shell.Dialogs {
     public class MIDIAssignDialog : Gtk.Dialog {
         public int control_type { get; construct; }
         Gtk.Revealer revealer;
         Gtk.Label subheading;
         int channel;
         int identifier;
         int signal_type;

         public signal void confirm_binding (int channel, int identifier, int signal_type, int control_type);
         public MIDIAssignDialog (int control_type) {
            Object (
                control_type: control_type,
                transient_for: Ensembles.Application.main_window,
                deletable: true,
                resizable: false,
                use_header_bar: 1,
                destroy_with_parent: true,
                window_position: Gtk.WindowPosition.CENTER_ON_PARENT,
                modal: true,
                title: _("Link MIDI Controller"),
                width_request: 560,
                height_request: 250
            );
         }

         construct {
            get_header_bar ().show_close_button = false;
            get_style_context ().add_class ("app");

            var main_grid = new Gtk.Grid ();

            var controller_icon = new Gtk.Image.from_resource ("/com/github/subhadeepjasu/ensembles/images/controller.svg") {
                halign = Gtk.Align.CENTER,
                margin_bottom = 26
            };

            controller_icon.get_style_context ().add_class ("controller-icon-box");
            controller_icon.get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
            controller_icon.get_style_context ().add_class (Granite.STYLE_CLASS_ROUNDED);
            main_grid.attach (controller_icon, 0, 0);

            var heading = new Gtk.Label (_("Link MIDI Controller"));
            heading.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
            main_grid.attach (heading, 0, 1);

            subheading = new Gtk.Label (_("Waiting for you to move a knob, fader or button on your MIDI Controller…")) {
                margin = 12,
                margin_bottom = 0,
            };

            subheading.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
            main_grid.attach (subheading, 0, 2);

            revealer = new Gtk.Revealer () {
                transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN
            };

            var confirm_button = new Gtk.Button.with_label (_("Confirm")) {
                hexpand = true,
                margin = 12,
                margin_bottom = 0
            };
            confirm_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            confirm_button.clicked.connect (confirm);
            revealer.add (confirm_button);
            main_grid.attach (revealer, 0, 3);

            var cancel_button = new Gtk.Button.with_label (_("Cancel")) {
                hexpand = true,
                margin = 12
            };

            cancel_button.clicked.connect (() => {
                Application.arranger_core.midi_input_host.midi_event_received.disconnect (midi_event_callback);
                this.close ();
            });

            main_grid.attach (cancel_button, 0, 4);

            get_content_area ().add (main_grid);

            Application.arranger_core.midi_input_host.midi_event_received.connect (midi_event_callback);
         }

         private bool midi_event_callback (int channel, int identifier, int type) {
             this.channel = channel;
             this.identifier = identifier;
             signal_type = type;
             subheading.set_text (_("#%d, Channel %d").printf (identifier, channel + 1));
             revealer.reveal_child = true;
             return true;
         }

        private void confirm () {
            confirm_binding (channel, identifier, signal_type, control_type);
            this.close ();
        }
     }
 }
