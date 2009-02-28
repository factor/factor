! Copyright (C) 2008 Matthew Willis.
! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license
USING: alien alien.syntax alien.destructors combinators system ;
IN: glib

<<

"glib" {
    { [ os winnt? ] [ "glib2.dll" ] }
    { [ os macosx? ] [ "/opt/local/lib/libglib-2.0.0.dylib" ] }
    { [ os unix? ] [ "libglib-2.0.0.so" ] }
} cond "cdecl" add-library

"gobject" {
    { [ os winnt? ] [ "gobject2.dll" ] }
    { [ os macosx? ] [ "/opt/local/lib/libgobject-2.0.0.dylib" ] }
    { [ os unix? ] [ "libgobject-2.0.0.so" ] }
} cond "cdecl" add-library

>>

LIBRARY: glib

TYPEDEF: void* gpointer
TYPEDEF: int gint
TYPEDEF: bool gboolean

FUNCTION: void
g_free ( gpointer mem ) ;

LIBRARY: gobject

FUNCTION: void
g_object_unref ( gpointer object ) ;

DESTRUCTOR: g_object_unref
