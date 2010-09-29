! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.destructors alien.libraries
alien.syntax cairo.ffi classes.struct combinators
gobject-introspection kernel system vocabs.loader ;
IN: gdk.ffi

<<
"pango.ffi" require
"gdk.pixbuf.ffi" require
>>

LIBRARY: gdk

<<
"gdk" {
    { [ os winnt? ] [ "libgdk-win32-2.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgdk-x11-2.0.so" cdecl add-library ] }
} cond
>>

IMPLEMENT-STRUCTS: GdkEventAny GdkEventKey GdkEventButton
GdkEventScroll GdkEventMotion GdkEventExpose GdkEventVisibility
GdkEventCrossing GdkEventFocus GdkEventConfigure GdkEventProperty
GdkEventSelection GdkEventDND GdkEventProximity GdkEventClient
GdkEventNoExpose GdkEventWindowState GdkEventSetting
GdkEventOwnerChange GdkEventGrabBroken GdkRectangle ;

! <workaround these types are from cairo 1.10
STRUCT: cairo_rectangle_int_t
    { x int } { y int } { width int } { height int } ;

C-TYPE: cairo_region_t
! workaround>

FOREIGN-RECORD-TYPE: cairo.RectangleInt cairo_rectangle_int_t
FOREIGN-RECORD-TYPE: cairo.Region cairo_region_t
FOREIGN-RECORD-TYPE: cairo.FontOptions cairo_font_options_t
FOREIGN-RECORD-TYPE: cairo.Surface cairo_surface_t
FOREIGN-RECORD-TYPE: cairo.Pattern cairo_pattern_t
FOREIGN-RECORD-TYPE: cairo.Context cairo_t
FOREIGN-ENUM-TYPE: cairo.Content cairo_content_t

GIR: vocab:gdk/Gdk-3.0.gir

DESTRUCTOR: gdk_cursor_unref
