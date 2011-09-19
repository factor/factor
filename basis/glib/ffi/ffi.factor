! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.destructors alien.libraries
alien.strings alien.syntax combinators gobject-introspection
gobject-introspection.standard-types io.encodings.utf8 kernel
system ;
IN: glib.ffi

LIBRARY: glib

<<
"glib" {
    { [ os windows? ] [ "libglib-2.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ "/opt/local/lib/libglib-2.0.0.dylib" cdecl add-library ] }
    { [ os unix? ] [ drop ] }
} cond
>>

IMPLEMENT-STRUCTS: GError GPollFD GSource GSourceFuncs ;

CONSTANT: G_MININT8   HEX: -80
CONSTANT: G_MAXINT8   HEX:  7f
CONSTANT: G_MAXUINT8  HEX:  ff
CONSTANT: G_MININT16  HEX: -8000
CONSTANT: G_MAXINT16  HEX:  7fff
CONSTANT: G_MAXUINT16 HEX:  ffff
CONSTANT: G_MININT32  HEX: -80000000
CONSTANT: G_MAXINT32  HEX:  7fffffff
CONSTANT: G_MAXUINT32 HEX:  ffffffff
CONSTANT: G_MININT64  HEX: -8000000000000000
CONSTANT: G_MAXINT64  HEX:  7fffffffffffffff
CONSTANT: G_MAXUINT64 HEX:  ffffffffffffffff

GIR: vocab:glib/GLib-2.0.gir

DESTRUCTOR: g_source_unref
DESTRUCTOR: g_free

CALLBACK: gboolean GSourceFuncsPrepareFunc ( GSource* source, gint* timeout_ ) ;
CALLBACK: gboolean GSourceFuncsCheckFunc ( GSource* source ) ;
CALLBACK: gboolean GSourceFuncsDispatchFunc ( GSource* source, GSourceFunc callback, gpointer user_data ) ;

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
