! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.destructors alien.libraries
alien.strings alien.syntax combinators gobject-introspection
gobject-introspection.standard-types io.encodings.utf8 kernel
system ;
IN: glib.ffi

LIBRARY: glib

<< "glib" {
    { [ os windows? ] [ "glib-2.0-0.dll" ] }
    { [ os macosx? ] [ "libglib-2.0.dylib" ] }
    { [ os unix? ] [ "libglib-2.0.so" ] }
} cond cdecl add-library >>

IMPLEMENT-STRUCTS: GError GPollFD GSource GSourceFuncs ;

CONSTANT: G_MININT8   -0x80
CONSTANT: G_MAXINT8   0x7f
CONSTANT: G_MAXUINT8  0xff
CONSTANT: G_MININT16  -0x8000
CONSTANT: G_MAXINT16  0x7fff
CONSTANT: G_MAXUINT16 0xffff
CONSTANT: G_MININT32  -0x80000000
CONSTANT: G_MAXINT32  0x7fffffff
CONSTANT: G_MAXUINT32 0xffffffff
CONSTANT: G_MININT64  -0x8000000000000000
CONSTANT: G_MAXINT64  0x7fffffffffffffff
CONSTANT: G_MAXUINT64 0xffffffffffffffff

GIR: vocab:gir/GLib-2.0.gir

DESTRUCTOR: g_source_unref
DESTRUCTOR: g_free

CALLBACK: gboolean GSourceFuncsPrepareFunc ( GSource* source, gint* timeout_ )
CALLBACK: gboolean GSourceFuncsCheckFunc ( GSource* source )
CALLBACK: gboolean GSourceFuncsDispatchFunc ( GSource* source, GSourceFunc callback, gpointer user_data )

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
