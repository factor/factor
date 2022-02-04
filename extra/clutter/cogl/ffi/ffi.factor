! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel opengl.gl system vocabs ;
IN: clutter.cogl.ffi

<<
"gobject.ffi" require
>>

LIBRARY: clutter.cogl

LIBRARY-UNIX: clutter.cogl cdecl "libclutter-glx-1.0.so"

FOREIGN-ATOMIC-TYPE: GL.uint GLuint
FOREIGN-ATOMIC-TYPE: GL.enum GLenum

GIR: Cogl-1.0.gir
