! Copyright (C) 2024 knottio.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.syntax gobject-introspection system vocabs ;
IN: gsk4.ffi

<<
"gdk4.ffi" require
"graphene.ffi" require
>>

LIBRARY: gsk4

C-LIBRARY: gsk4 {
    { unix "libgtk-4.so" }
}

GIR: vocab:gir/Gsk-4.0.gir
