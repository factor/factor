! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs ;
IN: gmodule.ffi

<< "glib.ffi" require >>

LIBRARY: gmodule

<< "gmodule" {
    { [ os windows? ] [ "libgmodule-2.0-0.dll" ] }
    { [ os macosx? ] [ "libgmodule-2.0.dylib" ] }
    { [ os unix? ] [ "libgmodule-2.0.so" ] }
} cond cdecl add-library >>

GIR: vocab:gmodule/GModule-2.0.gir
