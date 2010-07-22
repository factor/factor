! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries combinators kernel system
gobject-introspection gdk.ffi gdk.pixbuf.ffi gdk.gl.ffi gio.ffi
glib.ffi gmodule.ffi gobject.ffi gtk.ffi ;
EXCLUDE: alien.c-types => pointer ;
IN: gtk.gl.ffi

<<
"gtk.gl" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgtkglext-x11-1.0.so" cdecl add-library ] }
} cond
>>

GIR: vocab:gtk/gl/GtkGL-1.0.gir

