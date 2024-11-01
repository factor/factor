! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection system vocabs ;
IN: gio.ffi

<< "gobject.ffi" require >>

LIBRARY: gio

C-LIBRARY: gio cdecl {
    { windows "libgio-2.0-0.dll" }
    { macos "libgio-2.0.dylib" }
    { unix "libgio-2.0.so" }
}

GIR: vocab:gir/Gio-2.0.gir
