! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries combinators kernel
system
gobject-introspection clutter.ffi gdk.pixbuf.ffi glib.ffi
gtk.ffi ;
IN: clutter.gtk.ffi

<<
"clutter.gtk" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libclutter-gtk-0.10.so" cdecl add-library ] }
} cond
>>

GIR: vocab:clutter/gtk/GtkClutter-0.10.gir

