! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.syntax alien.destructors alien.libraries
classes.struct combinators kernel literals math system
gobject-introspection glib.ffi ;
EXCLUDE: alien.c-types => pointer ;
IN: gobject.ffi

<<
"gobject" {
    { [ os winnt? ] [ "libobject-2.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ "/opt/local/lib/libgobject-2.0.0.dylib" cdecl add-library ] }
    { [ os unix? ] [ "libgobject-2.0.so" cdecl add-library ] }
} cond
>>

TYPEDEF: void* GSignalCMarshaller
TYPEDEF: gchar** GStrv
TYPEDEF: gchar* gchararray

GIR: vocab:gobject/GObject-2.0.gir

IN: gobject.ffi

FORGET: GValue
STRUCT: GValue { g_type GType } { data guint64[2] } ;

FORGET: GIOCondition
FORGET: G_IO_IN
FORGET: G_IO_OUT
FORGET: G_IO_PRI
FORGET: G_IO_ERR
FORGET: G_IO_HUP
FORGET: G_IO_NVAL

FUNCTION: void g_object_unref ( GObject* self ) ;

DESTRUCTOR: g_object_unref

TYPEDEF: GParamSpec GParam

CONSTANT: G_TYPE_INVALID $[ 0 2 shift ]
CONSTANT: G_TYPE_NONE $[ 1 2 shift ]
CONSTANT: G_TYPE_INTERFACE $[ 2 2 shift ]
CONSTANT: G_TYPE_CHAR $[ 3 2 shift ]
CONSTANT: G_TYPE_UCHAR $[ 4 2 shift ]
CONSTANT: G_TYPE_BOOLEAN $[ 5 2 shift ]
CONSTANT: G_TYPE_INT $[ 6 2 shift ]
CONSTANT: G_TYPE_UINT $[ 7 2 shift ]
CONSTANT: G_TYPE_LONG $[ 8 2 shift ]
CONSTANT: G_TYPE_ULONG $[ 9 2 shift ]
CONSTANT: G_TYPE_INT64 $[ 10 2 shift ]
CONSTANT: G_TYPE_UINT64 $[ 11 2 shift ]
CONSTANT: G_TYPE_ENUM $[ 12 2 shift ]
CONSTANT: G_TYPE_FLAGS $[ 13 2 shift ]
CONSTANT: G_TYPE_FLOAT $[ 14 2 shift ]
CONSTANT: G_TYPE_DOUBLE $[ 15 2 shift ]
CONSTANT: G_TYPE_STRING $[ 16 2 shift ]
CONSTANT: G_TYPE_POINTER $[ 17 2 shift ]
CONSTANT: G_TYPE_BOXED $[ 18 2 shift ]
CONSTANT: G_TYPE_PARAM $[ 19 2 shift ]
CONSTANT: G_TYPE_OBJECT $[ 20 2 shift ]

! Macros

: g_signal_connect ( instance detailed_signal c_handler data -- result )
    f 0 g_signal_connect_data ;

: g_signal_connect_after ( instance detailed_signal c_handler data -- result )
    f G_CONNECT_AFTER g_signal_connect_data ;

: g_signal_connect_swapped ( instance detailed_signal c_handler data -- result )
    f G_CONNECT_SWAPPED g_signal_connect_data ;

