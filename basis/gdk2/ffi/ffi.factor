! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.destructors alien.libraries
alien.syntax cairo.ffi classes.struct combinators
gobject-introspection gobject-introspection.standard-types
kernel system vocabs ;
IN: gdk2.ffi

<<
"pango.ffi" require
"gdk2.pixbuf.ffi" require
>>

LIBRARY: gdk2

<<
"gdk2" {
    { [ os windows? ] [ "libgdk-win32-2.0-0.dll" cdecl add-library ] }
    { [ os macos? ] [ drop ] }
    { [ os unix? ] [ "libgdk-x11-2.0.so" cdecl add-library ] }
} cond
>>

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

GIR: vocab:gir/Gdk-3.0.gir

DESTRUCTOR: gdk_cursor_unref

STRUCT: GdkEventButton
    { type GdkEventType }
    { window GdkWindow* }
    { send_event gint8 }
    { time guint32 }
    { x gdouble }
    { y gdouble }
    { axes gdouble* }
    { state guint }
    { button guint }
    { device GdkDevice* }
    { x_root gdouble }
    { y_root gdouble } ;

STRUCT: GdkEventConfigure
    { type GdkEventType }
    { window GdkWindow* }
    { send_event gint8 }
    { x gint }
    { y gint }
    { width gint }
    { height gint } ;

STRUCT: GdkEventKey
    { type GdkEventType }
    { window GdkWindow* }
    { send_event gint8 }
    { time guint32 }
    { state guint }
    { keyval guint }
    { length gint }
    { string gchar* }
    { hardware_keycode guint16 }
    { group guint8 }
    { is_modifier uint bits: 1 } ;

STRUCT: GdkEventMotion
    { type GdkEventType }
    { window GdkWindow* }
    { send_event gint8 }
    { time guint32 }
    { x gdouble }
    { y gdouble }
    { axes gdouble* }
    { state guint }
    { is_hint gint16 }
    { device GdkDevice* }
    { x_root gdouble }
    { y_root gdouble } ;

STRUCT: GdkEventScroll
    { type GdkEventType }
    { window GdkWindow* }
    { send_event gint8 }
    { time guint32 }
    { x gdouble }
    { y gdouble }
    { state guint }
    { direction GdkScrollDirection }
    { device GdkDevice* }
    { x_root gdouble }
    { y_root gdouble } ;
