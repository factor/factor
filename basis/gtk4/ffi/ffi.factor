! Copyright (C) 2024 knottio.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.syntax gobject-introspection system vocabs ;
IN: gtk4.ffi

<<
"gdk4.ffi" require
"gsk4.ffi" require
>>

LIBRARY: gtk4

C-LIBRARY: gtk4 {
    { unix "libgtk-4.so" }
}

GIR: vocab:gir/Gtk-4.0.gir
