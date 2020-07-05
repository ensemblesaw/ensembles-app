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

struct _EnsemblesApp
{
  GtkApplication parent;
};

G_DEFINE_TYPE(EnsemblesApp, ensembles_app, GTK_TYPE_APPLICATION);

static void
ensembles_app_init (EnsemblesApp *app)
{
}

static void
ensembles_app_activate (GApplication *app)
{
  EnsemblesAppWindow *win;

  win = ensembles_app_window_new (ENSEMBLES_APP (app));
  gtk_window_present (GTK_WINDOW (win));
}

static void
ensembles_app_open (GApplication  *app,
                  GFile        **files,
                  gint           n_files,
                  const gchar   *hint)
{
  GList *windows;
  EnsemblesAppWindow *win;
  int i;

  windows = gtk_application_get_windows (GTK_APPLICATION (app));
  if (windows)
    win = ENSEMBLES_APP_WINDOW (windows->data);
  else
    win = ensembles_app_window_new (ENSEMBLES_APP (app));

  for (i = 0; i < n_files; i++)
    ensembles_app_window_open (win, files[i]);

  gtk_window_present (GTK_WINDOW (win));
}

static void
ensembles_app_class_init (EnsemblesAppClass *class)
{
  G_APPLICATION_CLASS (class)->activate = ensembles_app_activate;
  G_APPLICATION_CLASS (class)->open = ensembles_app_open;
}

EnsemblesApp *
ensembles_app_new (void)
{
  return g_object_new (ENSEMBLES_APP_TYPE,
                       "application-id", "com.github.subhadeepjasu.ensembles",
                       "flags", G_APPLICATION_HANDLES_OPEN,
                       NULL);
}
