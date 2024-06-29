! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs ;
IN: gtk2.gl.ffi

<<
"gtk2.ffi" require
"gdk2.gl.ffi" require
>>

LIBRARY: gtk2.gl

<<
"gtk2.gl" {
    { [ os windows? ] [ drop ] }
    { [ os macos? ] [ drop ] }
    { [ os unix? ] [ "libgtkglext-x11-1.0.so" cdecl add-library ] }
} cond
>>

GIR: vocab:gir/GtkGLExt-1.0.gir
