! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection system vocabs ;
IN: atk.ffi

<< "gobject.ffi" require >>

LIBRARY: atk

<< "atk" {
    { [ os windows? ] [ "libatk-1.0-0.dll" ] }
    { [ os macos? ] [ "libatk-1.0.dylib" ] }
    { [ os unix? ] [ "libatk-1.0.so" ] }
} cond cdecl add-library >>

GIR: vocab:gir/Atk-1.0.gir
