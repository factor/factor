! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries combinators kernel
system
gobject-introspection glib.ffi gobject.ffi ;
IN: gobject-introspection.tests.g-i-marshalling-tests.ffi

<<
"gobject-introspection.tests.g-i-marshalling-tests" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgirepository-gimarshallingtests-1.0.so" cdecl add-library ] }
} cond
>>

IMPLEMENT-STRUCTS: GIMarshallingTestsSimpleStruct ;

GIR: vocab:gobject-introspection/tests/g-i-marshalling-tests/GIMarshallingTests-1.0.gir

