! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries combinators kernel system
gir glib gobject gio gmodule gdk.pixbuf gdk gdk.gl gtk gtk.ffi ;
EXCLUDE: alien.c-types => pointer ;

<<
"gtk.gl" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgtkglext-x11-1.0.so" cdecl add-library ] }
} cond
>>

IN-GIR: gtk.gl vocab:gtk/gl/GtkGL-1.0.gir

