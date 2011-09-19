! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs.loader ;
IN: gmodule.ffi

<<
"glib.ffi" require
>>

LIBRARY: gmodule

<<
"gmodule" {
    { [ os windows? ] [ "libgmodule-2.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgmodule-2.0.so" cdecl add-library ] }
} cond
>>

GIR: vocab:gmodule/GModule-2.0.gir
