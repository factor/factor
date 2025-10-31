! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.libraries alien.syntax gobject-introspection system
vocabs ;
IN: pango.cairo.ffi

<<
"pango.ffi" require
"cairo.gobject.ffi" require
>>

LIBRARY: pango.cairo

C-LIBRARY: pango.cairo {
    { windows "libpangocairo-1.0-0.dll" }
    { macos "libpangocairo-1.0.dylib" }
    { unix "libpangocairo-1.0.so" }
}

GIR: vocab:gir/PangoCairo-1.0.gir
