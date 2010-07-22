! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries combinators kernel system
gobject-introspection glib.ffi gobject.ffi ;
EXCLUDE: alien.c-types => pointer ;
IN: gio.ffi

<<
"gio" {
    { [ os winnt? ] [ "libgio-2.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgio-2.0.so" cdecl add-library ] }
} cond
>>

GIR: vocab:gio/Gio-2.0.gir

