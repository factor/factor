! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.syntax alien.destructors 
alien.libraries combinators kernel literals math system
gir glib glib.ffi ;
EXCLUDE: alien.c-types => pointer ;

<<
"gobject" {
    { [ os winnt? ] [ "libobject-2.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ "/opt/local/lib/libgobject-2.0.0.dylib" cdecl add-library ] }
    { [ os unix? ] [ "libgobject-2.0.so" cdecl add-library ] }
} cond
>>

IN: gobject.ffi

TYPEDEF: void* GSignalCMarshaller
TYPEDEF: void GStrv
! есть alias
TYPEDEF: gchar* gchararray

IMPLEMENT-STRUCTS: GValue ;

IN-GIR: gobject vocab:gobject/GObject-2.0.gir

IN: gobject.ffi

FORGET: GIOCondition

FUNCTION: void g_object_unref ( GObject* self ) ;

DESTRUCTOR: g_object_unref

! Исправление неправильного типа параметра для GtkWidget-child-notify
! (разобраться)
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

