! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs ;
IN: gdk.gl.ffi

<<
"gdk.ffi" require
>>

LIBRARY: gdk.gl

LIBRARY-UNIX: gdk.gl cdecl "libgdkglext-x11-1.0.so"
LIBRARY-WINDOWS: gdk.gl cdecl "libgdkglext-win32-1.0-0.dll"

GIR: vocab:gdk/gl/GdkGLExt-1.0.gir
