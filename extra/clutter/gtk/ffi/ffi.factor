! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs ;
IN: clutter.gtk.ffi

<<
"clutter.ffi" require
"gtk.ffi" require
>>

LIBRARY: clutter.gtk

LIBRARY-UNIX: clutter.gtk cdecl "libclutter-gtk-1.0.so"

GIR: GtkClutter-1.0.gir
