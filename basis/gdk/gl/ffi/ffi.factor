! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs vocabs.loader ;
IN: gdk.gl.ffi

<<
"gdk.ffi" require
>>

LIBRARY: gdk.gl

GIR: vocab:gdk/gl/GdkGLExt-1.0.gir
