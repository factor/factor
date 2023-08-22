! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax
classes.struct gobject-introspection.types kernel parser ;
IN: gobject-introspection.standard-types

<<
TYPEDEF: char gchar
TYPEDEF: uchar guchar
TYPEDEF: short gshort
TYPEDEF: ushort gushort
TYPEDEF: long glong
TYPEDEF: ulong gulong
TYPEDEF: int gint
TYPEDEF: uint guint

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

TYPEDEF: size_t gsize
TYPEDEF: long gssize

TYPEDEF: gulong GType
TYPEDEF: void* gpointer
TYPEDEF: guint32 gunichar
TYPEDEF: void* va_list

int lookup-c-type clone
    [ >c-bool ] >>unboxer-quot
    [ c-bool> ] >>boxer-quot
    object >>boxed-class
"gboolean" create-word-in typedef

STRUCT: longdouble { data char[10] } ;
>>

gchar "gchar" register-standard-type
guchar "guchar" register-standard-type
gshort "gshort" register-standard-type
gushort "gushort" register-standard-type
glong "glong" register-standard-type
gulong "gulong" register-standard-type
gint "gint" register-standard-type
guint "guint" register-standard-type

gint8 "gint8" register-standard-type
guint8 "guint8" register-standard-type
gint16 "gint16" register-standard-type
guint16 "guint16" register-standard-type
gint32 "gint32" register-standard-type
guint32 "guint32" register-standard-type
gint64 "gint64" register-standard-type
guint64 "guint64" register-standard-type

gfloat "gfloat" register-standard-type
gdouble "gdouble" register-standard-type

gsize "gsize" register-standard-type
gssize "gssize" register-standard-type

GType "GType" register-standard-type
gpointer "gpointer" register-standard-type
gunichar "gunichar" register-standard-type
va_list "va_list" register-standard-type

gboolean "gboolean" register-standard-type
pointer: gchar "utf8" register-standard-type
longdouble "long double" register-standard-type
