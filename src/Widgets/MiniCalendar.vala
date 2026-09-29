/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 elementary, Inc.
 */

public class Calendar.Widgets.MiniCalendar : Gtk.Box {

    private Gtk.Label month_label;
    private Gtk.Grid days_grid;

    construct {
        orientation = VERTICAL;
        spacing = 6;

        month_label = new Gtk.Label ("") {
            halign = Gtk.Align.CENTER
        };

        days_grid = new Gtk.Grid () {
            column_homogeneous = true,
            row_homogeneous = true,
            column_spacing = 0,
            row_spacing = 0
        };

        add (month_label);
        add (days_grid);

        var calmodel = Calendar.EventStore.get_default ();
        calmodel.parameters_changed.connect (update_calendar);

        unowned var time_manager = Calendar.TimeManager.get_default ();
        time_manager.on_update_today.connect (update_calendar);

        update_calendar ();
        show_all ();
    }

    private void update_calendar () {
        var calmodel = Calendar.EventStore.get_default ();

        var month_text = calmodel.month_start.format ("%B %Y");
        month_text = month_text.substring (0, 1).up () + month_text.substring (1);
        month_label.label = month_text;

        foreach (unowned var child in days_grid.get_children ()) {
            child.destroy ();
        }

        var first_date = calmodel.data_range.first_dt;
        var today = new DateTime.now_local ();

        for (int i = 0; i < 7; i++) {
            var weekday = first_date.add_days (i);
            var label = new Gtk.Label (weekday.format ("%a")) {
                halign = Gtk.Align.CENTER
            };

            days_grid.attach (label, i, 0, 1, 1);
        }

        int position = 0;

        foreach (var current_date in calmodel.data_range) {
            var day_box = new Gtk.Box (VERTICAL, 0) {
                halign = Gtk.Align.CENTER
            };

            var label = new Gtk.Label (current_date.get_day_of_month ().to_string ()) {
                halign = Gtk.Align.CENTER,
                name = "date"
            };

            day_box.add (label);

            if (current_date.get_month () != calmodel.month_start.get_month ()) {
                label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
            }

            if (current_date.get_year () == today.get_year () &&
                current_date.get_month () == today.get_month () &&
                current_date.get_day_of_month () == today.get_day_of_month ()) {
                day_box.name = "today";
            }

            int column = position % 7;
            int row = (position / 7) + 1;

            days_grid.attach (day_box, column, row, 1, 1);
            position++;
        }

        show_all ();
    }
}
