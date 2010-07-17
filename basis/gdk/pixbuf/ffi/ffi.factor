! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries combinators kernel system
gobject-introspection gio.ffi glib.ffi gmodule.ffi gobject.ffi ;
EXCLUDE: alien.c-types => pointer ;
IN: gdk.pixbuf.ffi

<<
"gdk.pixbuf" {
    { [ os winnt? ] [ "libgdk_pixbuf-2.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgdk_pixbuf-2.0.so" cdecl add-library ] }
} cond
>>

GIR: vocab:gdk/pixbuf/GdkPixbuf-2.0.gir

