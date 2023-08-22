! Copyright (C) 2011 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs ;
IN: clutter.cally.ffi

<<
"atk.ffi" require
"clutter.ffi" require
>>

LIBRARY: clutter.cally

<<
"clutter.cally" {
    { [ os windows? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libclutter-glx-1.0.so" cdecl add-library ] }
} cond
>>

GIR: Cally-1.0.gir
