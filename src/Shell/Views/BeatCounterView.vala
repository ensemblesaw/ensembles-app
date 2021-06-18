namespace Ensembles.Shell { 
    public class BeatCounterView : Gtk.Overlay {
        Gtk.Image beat_counter_0;
        Gtk.Image beat_counter_1;
        Gtk.Image beat_counter_2;
        Gtk.Image beat_counter_3;

        Gtk.Image beat_counter_active_0;
        Gtk.Image beat_counter_active_1;
        Gtk.Image beat_counter_active_2;
        Gtk.Image beat_counter_active_3;

        Gtk.Button tap_button;

        int tempo = 10;

        bool halt_ack = false;


        public BeatCounterView() {
            var main_grid = new Gtk.Grid ();
            beat_counter_0 = new Gtk.Image.from_resource ("/com/github/subhadeepjasu/ensembles/images/beat_counter/beat_counter_1_0.svg");
            beat_counter_1 = new Gtk.Image.from_resource ("/com/github/subhadeepjasu/ensembles/images/beat_counter/beat_counter_2_0.svg");
            beat_counter_2 = new Gtk.Image.from_resource ("/com/github/subhadeepjasu/ensembles/images/beat_counter/beat_counter_2_0.svg");
            beat_counter_3 = new Gtk.Image.from_resource ("/com/github/subhadeepjasu/ensembles/images/beat_counter/beat_counter_2_0.svg");
            beat_counter_1.margin_top = 3;
            beat_counter_2.margin_top = 3;
            beat_counter_3.margin_top = 3;



            tap_button = new Gtk.Button.with_label ("Tempo");
            tap_button.margin = 4;
            tap_button.margin_start = 8;
            main_grid.attach (beat_counter_0, 0, 0, 1, 1);
            main_grid.attach (beat_counter_1, 1, 0, 1, 1);
            main_grid.attach (beat_counter_2, 2, 0, 1, 1);
            main_grid.attach (beat_counter_3, 3, 0, 1, 1);
            main_grid.attach (tap_button, 4, 0, 1, 1);



            var overlay_grid = new Gtk.Grid ();
            beat_counter_active_0 = new Gtk.Image.from_resource ("/com/github/subhadeepjasu/ensembles/images/beat_counter/beat_counter_1_1.svg");
            beat_counter_active_1 = new Gtk.Image.from_resource ("/com/github/subhadeepjasu/ensembles/images/beat_counter/beat_counter_2_1.svg");
            beat_counter_active_2 = new Gtk.Image.from_resource ("/com/github/subhadeepjasu/ensembles/images/beat_counter/beat_counter_2_1.svg");
            beat_counter_active_3 = new Gtk.Image.from_resource ("/com/github/subhadeepjasu/ensembles/images/beat_counter/beat_counter_2_1.svg");
            beat_counter_active_1.margin_top = 3;
            beat_counter_active_2.margin_top = 3;
            beat_counter_active_3.margin_top = 3;
            beat_counter_active_0.opacity = 0;
            beat_counter_active_1.opacity = 0;
            beat_counter_active_2.opacity = 0;
            beat_counter_active_3.opacity = 0;

            overlay_grid.attach (beat_counter_active_0, 0, 0, 1, 1);
            overlay_grid.attach (beat_counter_active_1, 1, 0, 1, 1);
            overlay_grid.attach (beat_counter_active_2, 2, 0, 1, 1);
            overlay_grid.attach (beat_counter_active_3, 3, 0, 1, 1);
            overlay_grid.margin_top = 5;

            this.add_overlay (main_grid);
            this.add_overlay (overlay_grid);
            this.show_all ();
            this.set_overlay_pass_through (overlay_grid, true);
            this.width_request = 170;
            this.height_request = 34;
        }

        public void change_tempo (int tempo) {
            if (tempo > 0) {
                this.tempo = tempo;
            }
        }

        public void sync () {
            pulse_0 ();
            if (halt_ack) {
                halt_ack = false;
            } else {
                Timeout.add ((uint)(60000/tempo), () => {
                    if (halt_ack) {
                        halt_ack = false;
                    } else {
                        pulse_1 ();
                        Timeout.add ((uint)(60000/tempo), () => {
                            pulse_2 ();
                            Timeout.add ((uint)(60000/tempo), () => {
                                pulse_3 ();
                                return false;
                            });
                            yield;
                            return false;
                        });
                        yield;
                    }
                    return false;
                });
                yield;
            }
        }

        public async void halt () {
            halt_ack = true;
            Timeout.add (60000/(tempo * 2), () => {
                halt_ack = false;
                return false;
            });
            yield;
        }

        void pulse_0 () {
            beat_counter_active_0.set_opacity (1);
            Timeout.add (60000/(tempo * 2), () => {
                beat_counter_active_0.set_opacity (0);
                return false;
            });
        }
        void pulse_1 () {
            beat_counter_active_1.set_opacity (1);
            Timeout.add (60000/(tempo * 2), () => {
                beat_counter_active_1.set_opacity (0);
                return false;
            });
        }
        void pulse_2 () {
            beat_counter_active_2.set_opacity (1);
            Timeout.add (60000/(tempo * 2), () => {
                beat_counter_active_2.set_opacity (0);
                return false;
            });
        }
        void pulse_3 () {
            beat_counter_active_3.set_opacity (1);
            Timeout.add (60000/(tempo * 2), () => {
                beat_counter_active_3.set_opacity (0);
                return false;
            });
        }
    }
}