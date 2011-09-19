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
    { [ os windows? ] [ "libatk-1.0-0.dll" cdecl add-library ] }
    { [ os unix? ] [ drop ] }
} cond
>>

GIR: vocab:atk/Atk-1.0.gir
