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

#ifndef __ENSEMBLESAPPWIN_H
#define __ENSEMBLESAPPWIN_H

#include <gtk/gtk.h>
#include "application.h"


#define ENSEMBLES_APP_WINDOW_TYPE (ensembles_app_window_get_type ())
G_DECLARE_FINAL_TYPE (EnsemblesAppWindow, ensembles_app_window, ENSEMBLES, APP_WINDOW, GtkApplicationWindow)


EnsemblesAppWindow       *ensembles_app_window_new          (EnsemblesApp *app);
void                    ensembles_app_window_open         (EnsemblesAppWindow *win,
                                                         GFile            *file);


#endif /* __ENSEMBLESAPPWIN_H */
