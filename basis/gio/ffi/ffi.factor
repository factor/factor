! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs ;
IN: gio.ffi

<< "gobject.ffi" require >>

LIBRARY: gio

<< "gio" {
    { [ os windows? ] [ "libgio-2.0-0.dll" ] }
    { [ os macosx? ] [ "libgio-2.0.dylib" ] }
    { [ os unix? ] [ "libgio-2.0.so" ] }
} cond cdecl add-library >>

GIR: vocab:gio/Gio-2.0.gir
