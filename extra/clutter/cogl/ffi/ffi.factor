! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
combinators kernel opengl.gl system
gobject-introspection glib.ffi ;
IN: clutter.cogl.ffi

<<
"clutter.cogl" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libclutter-glx-1.0.so" cdecl add-library ] }
} cond
>>

TYPEDEF: int CoglAngle
TYPEDEF: int CoglFixed
TYPEDEF: void* CoglHandle

REPLACE-C-TYPE: unsigned\schar uchar
REPLACE-C-TYPE: unsigned\sint uint
REPLACE-C-TYPE: unsigned\slong ulong

GIR: vocab:clutter/cogl/Cogl-1.0.gir

