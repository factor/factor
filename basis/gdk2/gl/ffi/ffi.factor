! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs ;
IN: gdk2.gl.ffi

<<
"gdk2.ffi" require
>>

LIBRARY: gdk2.gl

<<
"gdk2.gl" {
    { [ os windows? ] [ "libgdkglext-win32-1.0-0.dll" cdecl add-library ] }
    { [ os macos? ] [ drop ] }
    { [ os unix? ] [ "libgdkglext-x11-1.0.so" cdecl add-library ] }
} cond
>>

GIR: vocab:gir/GdkGLExt-1.0.gir
