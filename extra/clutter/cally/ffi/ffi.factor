! Copyright (C) 2011 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs ;
IN: clutter.cally.ffi

<<
"atk.ffi" require
"clutter.ffi" require
>>

LIBRARY: clutter.cally

LIBRARY-UNIX: clutter.cally cdecl "libclutter-glx-1.0.so"

GIR: Cally-1.0.gir
