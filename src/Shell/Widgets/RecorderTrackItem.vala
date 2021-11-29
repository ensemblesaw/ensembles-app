/*
 * Copyright 2020-2022 Subhadeep Jasu <subhajasu@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.Shell {
    public class RecorderTrackItem : Gtk.ListBoxRow {
        unowned List<Core.MidiEvent> _events;
        public int track;
        private uint cardinality;
        private Gtk.DrawingArea area;
        private Gtk.Grid track_grid;
        private Gtk.Image recording_icon;
        private Gtk.Label track_label;
        private Gtk.MenuButton options_button;
        private Gtk.MenuItem mute_button;
        private Gtk.MenuItem solo_button;
        private Gtk.MenuItem record_button;
        private Gtk.MenuItem delete_button;

        private double[] active_keys;

        public delegate void OptionsHandler (int track, uint option);

        unowned OptionsHandler options_handle;

        public RecorderTrackItem (List<Core.MidiEvent> events, int track, OptionsHandler options_handle) {
            this.options_handle = options_handle;
            active_keys = new double[60];
            this.track = track;
            this.tooltip_text = _("Click to select track %d for recording").printf (track + 1);
            this.halign = Gtk.Align.START;
            track_grid = new Gtk.Grid ();


            track_label = new Gtk.Label (_("Track ") + (track + 1).to_string ());
            track_label.ellipsize = Pango.EllipsizeMode.MIDDLE;
            track_label.width_request = 72;
            track_grid.attach (track_label, 0, 0);

            recording_icon = new Gtk.Image.from_icon_name ("media-record", Gtk.IconSize.BUTTON);
            recording_icon.margin_end = 8;
            track_grid.attach (recording_icon, 1, 0);

            var separator_a = new Gtk.Separator (Gtk.Orientation.VERTICAL);
            track_grid.attach (separator_a, 2, 0);

            area = new Gtk.DrawingArea ();
            area.height_request = 32;
            area.width_request = 0;
            area.draw.connect (on_draw);
            track_grid.attach (area, 3, 0);

            var separator_b = new Gtk.Separator (Gtk.Orientation.VERTICAL);
            track_grid.attach (separator_b, 4, 0);

            var context_menu = new Gtk.Menu ();
            mute_button = new Gtk.MenuItem.with_label (_("Mute"));
            solo_button = new Gtk.MenuItem.with_label (_("Solo"));
            record_button = new Gtk.MenuItem.with_label (_("Record"));
            delete_button = new Gtk.MenuItem.with_label (_("Delete"));

            context_menu.append (mute_button);
            context_menu.append (solo_button);
            context_menu.append (record_button);
            context_menu.append (delete_button);

            options_button = new Gtk.MenuButton ();
            options_button.image = new Gtk.Image.from_icon_name ("view-more-symbolic", Gtk.IconSize.BUTTON);
            options_button.popup = context_menu;
            track_grid.attach (options_button, 5, 0);

            this.get_style_context ().add_class ("recorder-track");
            this.get_style_context ().add_class ("track-" + track.to_string ());
            add (track_grid);
            _events = events;

            height_request = 32;
            width_request = 10;
            cardinality = _events.length ();
            area.queue_draw ();
            context_menu.show_all ();

            mute_button.activate.connect (() => {
                this.options_handle (track, 0);
            });
            solo_button.activate.connect (() => {
                this.options_handle (track, 1);
            });
            record_button.activate.connect (() => {
                this.options_handle (track, 2);
            });
            delete_button.activate.connect (() => {
                this.options_handle (track, 3);
            });
        }
        public void set_track_events (List<Core.MidiEvent> events) {
            _events = events;
            cardinality = _events.length ();
            double total_width = 0;
            for (int i = 0; i < cardinality; i++) {
                total_width += (double)_events.nth_data (i).time_stamp / 100000;
            }
            area.width_request = (int)total_width;
            area.queue_draw ();
        }
        bool on_draw (Gtk.Widget widget, Cairo.Context context) {
            if (cardinality != 0) {
                double max_point = highest_point ();
                double min_point = lowest_point ();
                double max_height = max_point - min_point;

                int baseline = (int)(-get_allocated_height () * (min_point / max_height));

                double total_width = 0;
                // Draw bars as per data points
                for (int i = 0; i < cardinality; i++) {
                    total_width += (double)_events.nth_data (i).time_stamp / 100000;
                    if (_events.nth_data (i).event_type == Core.MidiEvent.EventType.NOTE) {

                        if (_events.nth_data (i).value2 == 144) {
                            double alpha;
                            set_note_on (_events.nth_data (i).value1, true, _events.nth_data (i).velocity, (int)total_width, out alpha);
                        } else if (_events.nth_data (i).value2 == 128) {
                            double alpha;
                            int prev_time = set_note_on (_events.nth_data (i).value1, false, _events.nth_data (i).velocity, (int)total_width, out alpha);
                            draw_note_event (context,
                                            1,
                                            (int)(((_events.nth_data (i).value1 - 37) / max_height) * get_allocated_height ()),
                                            prev_time,
                                            (int)total_width,
                                            baseline,
                                            alpha);
                        }
                    }
                    if (_events.nth_data (i).event_type == Core.MidiEvent.EventType.STYLECONTROLACTUAL) {
                        draw_style_section (context, _events.nth_data (i).value1, (int)(total_width));
                    }
                }
                widget.width_request = (int)total_width;
            }

            return true;
        }

        private int set_note_on (int note, bool on, int velocity, int time, out double alpha) {
            int time_out = 0;
            alpha = 0;
            if (!on) {
                time_out = (int)active_keys[note - 36];
                alpha = active_keys[note - 36] - (double)time_out;
            }
            active_keys[note - 36] = on ? (double)time + ((double)velocity / 130.0) : 0;
            return time_out;
        }

        private void draw_note_event (Cairo.Context ctx, int width, int height, int x_offset1, int x_offset2, int y_offset, double alpha) {
            if (alpha > 0) {
                ctx.set_source_rgba (1, 1, 1, alpha);
                ctx.set_line_width (width);
                ctx.move_to (x_offset1, 2 + get_allocated_height () - (height + y_offset));
                ctx.line_to (x_offset2, 2 + get_allocated_height () - (height + y_offset));
                ctx.stroke ();
            }
        }

        public void set_mute (bool mute) {
            if (mute) {
                this.get_style_context ().add_class ("recorder-track-mute");
                mute_button.label = _("Unmute");
            } else {
                this.get_style_context ().remove_class ("recorder-track-mute");
                mute_button.label = _("Mute");
            }
        }

        private void draw_style_section (Cairo.Context ctx, int section, int x_offset) {
            if (section > 0) {
                ctx.move_to (x_offset, 0);
                ctx.line_to (x_offset, 32);
                ctx.set_source_rgba (0, 0, 0, 0.3);
                ctx.stroke ();
                ctx.move_to (x_offset + 6, 16);
                ctx.set_font_size (10);
                ctx.set_source_rgba (1, 0.8, 0.3, 1);
                switch (section) {
                    case 1:
                    ctx.show_text (_("INTRO 1"));
                    break;
                    case 2:
                    ctx.show_text (_("INTRO 2"));
                    break;
                    case 3:
                    ctx.show_text (_("VAR A"));
                    break;
                    case 5:
                    ctx.show_text (_("VAR B"));
                    break;
                    case 7:
                    ctx.show_text (_("VAR C"));
                    break;
                    case 9:
                    ctx.show_text (_("VAR D"));
                    break;
                    case 11:
                    ctx.show_text (_("ENDING A"));
                    break;
                    case 13:
                    ctx.show_text (_("ENDING B"));
                    break;
                }
                ctx.set_source_rgba (0, 0, 0, 0);
            }
        }

        private double lowest_point () {
            double x = 0;
            for (int i = 0; i < _events.length (); i++) {
                if (_events.nth_data (i).value1 - 37 < x) {
                    x = _events.nth_data (i).value1 - 37;
                }
            }
            return x;
        }

        private double highest_point () {
            double x = 0;
            for (int i = 0; i < _events.length (); i++) {
                if (_events.nth_data (i).value1 - 36 > x) {
                    x = _events.nth_data (i).value1 - 36;
                }
            }
            return x;
        }
    }
}
