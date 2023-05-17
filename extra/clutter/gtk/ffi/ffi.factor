! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs ;
IN: clutter.gtk.ffi

<<
"clutter.ffi" require
"gtk2.ffi" require
>>

LIBRARY: clutter.gtk

<<
"clutter.gtk" {
    { [ os windows? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libclutter-gtk-1.0.so" cdecl add-library ] }
} cond
>>

GIR: GtkClutter-1.0.gir
