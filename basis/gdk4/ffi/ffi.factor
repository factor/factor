! Copyright (C) 2024 knottio.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.libraries alien.syntax gobject-introspection
gobject-introspection.standard-types sequences system vocabs ;
IN: gdk4.ffi

<<
"gdk-pixbuf.ffi" require
"pango.ffi" require
"pango.cairo.ffi" require
>>

C-LIBRARY: gdk4 {
    { unix "libgtk-4.so" }
}

LIBRARY: gdk4

GIR: vocab:gir/Gdk-4.0.gir

: gdk_gl_get_proc_address ( name -- address )
    "epoxy_" prepend DLL" libgtk-4.so" dlsym ;
