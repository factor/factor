! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs.loader ;
IN: gdk.gl.ffi

<<
"gdk.ffi" require
>>

LIBRARY: gdk.gl

<<
"gdk.gl" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgdkglext-x11-1.0.so" cdecl add-library ] }
} cond
>>

GIR: vocab:gdk/gl/GdkGLExt-1.0.gir
