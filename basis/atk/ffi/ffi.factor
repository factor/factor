! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection system vocabs ;
IN: atk.ffi

<< "gobject.ffi" require >>

LIBRARY: atk

C-LIBRARY: atk {
    { windows "libatk-1.0-0.dll" }
    { macos "libatk-1.0.dylib" }
    { unix "libatk-1.0.so" }
}

GIR: vocab:gir/Atk-1.0.gir
