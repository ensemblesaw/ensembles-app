/*
 * Copyright © 2020 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * Licensed under the GNU General Public License Version 3
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#include <gtk/gtk.h>

#include "application.h"
#include "main_window.h"

struct _EnsemblesAppWindow
{
  GtkApplicationWindow parent;
};

G_DEFINE_TYPE(EnsemblesAppWindow, ensembles_app_window, GTK_TYPE_APPLICATION_WINDOW);

static void
ensembles_app_window_init (EnsemblesAppWindow *app)
{
}

static void
ensembles_app_window_class_init (EnsemblesAppWindowClass *class)
{
}

EnsemblesAppWindow *
ensembles_app_window_new (EnsemblesApp *app)
{
  return g_object_new (ENSEMBLES_APP_WINDOW_TYPE, "application", app, NULL);
}

void
ensembles_app_window_open (EnsemblesAppWindow *win,
                         GFile            *file)
{
}
