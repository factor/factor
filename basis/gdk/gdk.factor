! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax cairo.ffi
gir glib gobject gio gmodule gdk.pixbuf glib.ffi ;

IN: gdk.ffi

TYPEDEF: guint32 GdkNativeWindow
TYPEDEF: guint32 GdkWChar

IN-GIR: gdk vocab:gdk/Gdk-2.0.gir

