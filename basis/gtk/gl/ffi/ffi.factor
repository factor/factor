! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs vocabs.platforms ;
IN: gtk.gl.ffi

<<
"gtk.ffi" require
"gdk.gl.ffi" require
>>

LIBRARY: gtk.gl

USE-UNIX: gtk.gl cdecl "libgtkglext-x11-1.0.so"

GIR: vocab:gtk/gl/GtkGLExt-1.0.gir
