! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license
USING: alien.syntax alien.destructors ;
IN: glib

TYPEDEF: void* gpointer

FUNCTION: void
g_object_unref ( gpointer object ) ;

DESTRUCTOR: g_object_unref

FUNCTION: void
g_free ( gpointer mem ) ;
