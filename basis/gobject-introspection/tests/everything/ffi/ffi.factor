! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries combinators kernel
system
gobject-introspection cairo.ffi gio.ffi glib.ffi gobject.ffi ;
IN: gobject-introspection.tests.everything.ffi

<<
"gobject-introspection.tests.everything" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgirepository-everything-1.0.so" cdecl add-library ] }
} cond
>>

IMPLEMENT-STRUCTS: TestBoxed ;

GIR: vocab:gobject-introspection/tests/everything/Everything-1.0.gir

