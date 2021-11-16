namespace Ensembles.Shell {
    public class RecorderTrackItem : Gtk.ListBoxRow {
        unowned List<Core.MidiEvent> _events;
        public int track;
        private uint cardinality;
        private Gtk.DrawingArea area;
        private Gtk.Grid track_grid;
        private Gtk.Image recording_icon;
        private Gtk.Label track_label;

        public RecorderTrackItem (List<Core.MidiEvent> events, int track) {
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

            var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
            track_grid.attach (separator, 2, 0);

            area = new Gtk.DrawingArea ();
            area.height_request = 32;
            area.width_request = 0;
            area.draw.connect (on_draw);
            track_grid.attach (area, 3, 0);

            this.get_style_context ().add_class ("recorder-track");
            this.get_style_context ().add_class ("track-" + track.to_string ());
            add (track_grid);
            _events = events;

            height_request = 32;
            width_request = 10;
            cardinality = _events.length ();
            area.queue_draw ();
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
                            draw_note_on_event (context,
                                2,
                                (int)(((_events.nth_data (i).value1 - 76) / max_height) * get_allocated_height ()),
                                (int)(total_width),
                                baseline,
                                ((double)_events.nth_data (i).velocity / 130.0));
                        } else if (_events.nth_data (i).value2 == 128) {
                            draw_note_off_event (context,
                                2,
                                (int)(((_events.nth_data (i).value1 - 76) / max_height) * get_allocated_height ()),
                                (int)(total_width),
                                baseline);
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

        private void draw_note_on_event (Cairo.Context ctx, int width, int height, int x_offset, int y_offset, double alpha) {
            ctx.set_source_rgba (1, 1, 1, alpha);
            ctx.set_line_width (width);
            ctx.stroke ();
            ctx.move_to (x_offset, 2 + get_allocated_height () - (height + y_offset));
        }

        private void draw_note_off_event (Cairo.Context ctx, int width, int height, int x_offset, int y_offset) {
            ctx.line_to (x_offset + 2, 2 + get_allocated_height () - (height + y_offset));
            ctx.stroke ();
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
                    ctx.show_text ("INTRO 1");
                    break;
                    case 2:
                    ctx.show_text ("INTRO 2");
                    break;
                    case 3:
                    ctx.show_text ("VAR A");
                    break;
                    case 5:
                    ctx.show_text ("VAR B");
                    break;
                    case 7:
                    ctx.show_text ("VAR C");
                    break;
                    case 9:
                    ctx.show_text ("VAR D");
                    break;
                    case 11:
                    ctx.show_text ("END A");
                    break;
                    case 13:
                    ctx.show_text ("END B");
                    break;
                }
                ctx.set_source_rgba (0,0,0,0);
            }
        }

        private double lowest_point () {
            double x = 0;
            for (int i = 0; i < _events.length (); i++) {
                if (_events.nth_data (i).value1 - 76 < x) {
                    x = _events.nth_data (i).value1 - 76;
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
