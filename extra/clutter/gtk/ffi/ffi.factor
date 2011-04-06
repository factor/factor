! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs.loader ;
IN: clutter.gtk.ffi

<<
"clutter.ffi" require
"gtk.ffi" require
>>

LIBRARY: clutter.gtk

<<
"clutter.gtk" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libclutter-gtk-0.10.so" cdecl add-library ] }
} cond
>>

GIR: GtkClutter-0.10.gir

