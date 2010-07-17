! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.destructors
alien.libraries alien.syntax combinators compiler.units
gobject-introspection kernel system vocabs.parser words ;
IN: glib.ffi

<<
"glib" {
    { [ os winnt? ] [ "libglib-2.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ "/opt/local/lib/libglib-2.0.0.dylib" cdecl add-library ] }
    { [ os unix? ] [ "libglib-2.0.so" cdecl add-library ] }
} cond
>>

<< double "long double" current-vocab create typedef >>

TYPEDEF: char gchar
TYPEDEF: uchar guchar
TYPEDEF: short gshort
TYPEDEF: ushort gushort
TYPEDEF: long glong
TYPEDEF: ulong gulong
TYPEDEF: int gint
TYPEDEF: uint guint

<<
int c-type clone
    [ >c-bool ] >>unboxer-quot
    [ c-bool> ] >>boxer-quot
    object >>boxed-class
"gboolean" current-vocab create typedef
>>

TYPEDEF: char gint8
TYPEDEF: uchar guint8
TYPEDEF: short gint16
TYPEDEF: ushort guint16
TYPEDEF: int gint32
TYPEDEF: uint guint32
TYPEDEF: longlong gint64
TYPEDEF: ulonglong guint64

TYPEDEF: float gfloat
TYPEDEF: double gdouble

TYPEDEF: long ssize_t
TYPEDEF: long time_t
TYPEDEF: size_t gsize
TYPEDEF: ssize_t gssize
TYPEDEF: size_t GType

TYPEDEF: void* gpointer
TYPEDEF: void* gconstpointer

TYPEDEF: guint8 GDateDay
TYPEDEF: guint16 GDateYear
TYPEDEF: gint GPid
TYPEDEF: guint32 GQuark
TYPEDEF: gint32 GTime
TYPEDEF: glong gintptr
TYPEDEF: gint64 goffset
TYPEDEF: gulong guintptr
TYPEDEF: guint32 gunichar
TYPEDEF: guint16 gunichar2

TYPEDEF: gpointer pointer
TYPEDEF: gpointer any

IMPLEMENT-STRUCTS: GPollFD GSource GSourceFuncs ;

GIR: vocab:glib/GLib-2.0.gir

DESTRUCTOR: g_source_unref
DESTRUCTOR: g_free

CALLBACK: gboolean GSourceFuncsPrepareFunc ( GSource* source, gint* timeout_ ) ;
CALLBACK: gboolean GSourceFuncsCheckFunc ( GSource* source ) ;
CALLBACK: gboolean GSourceFuncsDispatchFunc ( GSource* source, GSourceFunc callback, gpointer user_data ) ;

