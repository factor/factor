! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection system vocabs ;
IN: gio.ffi

<< "gobject.ffi" require >>

LIBRARY: gio

<< "gio" {
    { [ os windows? ] [ "libgio-2.0-0.dll" ] }
    { [ os macos? ] [ "libgio-2.0.dylib" ] }
    { [ os unix? ] [ "libgio-2.0.so" ] }
} cond cdecl add-library >>

GIR: vocab:gir/Gio-2.0.gir
