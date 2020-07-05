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
#ifndef _ENSEMBLESAPP_H
#define _ENSEMBLESAPP_H

#include <gtk/gtk.h>

struct _Ensembles
{
  GtkApplication parent;
};

#define ENSEMBLES_APP_TYPE (ensembles_app_get_type ())
G_DECLARE_FINAL_TYPE (EnsemblesApp, ensembles_app, ENSEMBLES, APP, GtkApplication)


EnsemblesApp     *ensembles_app_new         (void);

#endif /* _ENSEMBLEAPP_H */