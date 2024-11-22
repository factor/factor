! Copyright (C) 2024 knottio.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.syntax gobject-introspection system vocabs ;
IN: gdk4.ffi

<<
"gdk2.pixbuf.ffi" require
"pango.ffi" require
"pango.cairo.ffi" require
>>

C-LIBRARY: gdk4 {
    { unix "libgtk-4.so" }
}

LIBRARY: gdk4

GIR: vocab:gir/Gdk-4.0.gir
