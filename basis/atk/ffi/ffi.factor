! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs.loader ;
IN: atk.ffi

<<
"gobject.ffi" require
>>

LIBRARY: atk

<<
"atk" {
    { [ os winnt? ] [ "libatk-1.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libatk-1.0.so" cdecl add-library ] }
} cond
>>

GIR: vocab:atk/Atk-1.0.gir
