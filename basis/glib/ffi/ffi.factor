! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.destructors alien.libraries
alien.strings alien.syntax combinators gobject-introspection
gobject-introspection.standard-types io.encodings.utf8 kernel
system ;
IN: glib.ffi

LIBRARY: glib

C-LIBRARY: glib {
    { windows "glib-2.0-0.dll" }
    { macos "libglib-2.0.dylib" }
    { unix "libglib-2.0.so" }
}

IMPLEMENT-STRUCTS: GError GPollFD GSource GSourceFuncs ;

GIR: vocab:gir/GLib-2.0.gir

DESTRUCTOR: g_source_unref
DESTRUCTOR: g_free

ERROR: g-error domain code message ;

: GError>g-error ( GError -- g-error )
    [ domain>> g_quark_to_string utf8 alien>string ]
    [ code>> ]
    [ message>> utf8 alien>string ] tri
    \ g-error boa ;

: handle-GError ( GError/f -- )
    [
        [ GError>g-error ]
        [ g_error_free ] bi
        throw
    ] when* ;
