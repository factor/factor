! Copyright (C) 2008 Matthew Willis.
! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license
USING: alien alien.syntax alien.destructors combinators system
alien.libraries ;
IN: glib

<<

{
    { [ os winnt? ] [ "glib" "libglib-2.0-0.dll" "cdecl" add-library ] }
    { [ os macosx? ] [ "glib" "/opt/local/lib/libglib-2.0.0.dylib" "cdecl" add-library ] }
    { [ os unix? ] [ ] }
} cond

{
    { [ os winnt? ] [ "gobject" "libgobject-2.0-0.dll" "cdecl" add-library ] }
    { [ os macosx? ] [ "gobject" "/opt/local/lib/libgobject-2.0.0.dylib" "cdecl" add-library ] }
    { [ os unix? ] [ ] }
} cond

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
