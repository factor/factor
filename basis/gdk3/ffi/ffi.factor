! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.destructors alien.libraries
alien.syntax cairo.ffi classes.struct combinators
gobject-introspection gobject-introspection.standard-types
kernel sequences system vocabs ;
IN: gdk3.ffi

<<
"pango.ffi" require
"cairo.ffi" require
"cairo.gobject.ffi" require
"gdk-pixbuf.ffi" require
>>

LIBRARY: gdk3

C-LIBRARY: gdk3 {
    { unix "libgdk-3.so" }
}

IMPLEMENT-STRUCTS: GdkEventButton GdkEventConfigure GdkEventKey GdkEventMotion GdkEventScroll ;

GIR: vocab:gir/Gdk-3.0.gir

DESTRUCTOR: gdk_cursor_unref

: gdk_gl_get_proc_address ( name -- address )
    "epoxy_" prepend DLL" libgdk-3.so" dlsym ;
