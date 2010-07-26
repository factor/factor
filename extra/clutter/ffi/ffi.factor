! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries cairo.ffi
combinators kernel system
gobject-introspection clutter.cogl.ffi clutter.json.ffi
glib.ffi gobject.ffi pango.ffi ;
IN: clutter.ffi

<<
"clutter" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libclutter-glx-1.0.so" cdecl add-library ] }
} cond
>>

IMPLEMENT-STRUCTS: ClutterVertex ;

GIR: vocab:clutter/Clutter-1.0.gir

