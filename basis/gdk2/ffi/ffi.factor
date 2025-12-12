! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.destructors alien.libraries
alien.syntax cairo.ffi classes.struct combinators
gobject-introspection gobject-introspection.standard-types
kernel system vocabs ;
IN: gdk2.ffi

<<
"pango.ffi" require
"cairo.gobject.ffi" require
"gdk-pixbuf.ffi" require
>>

LIBRARY: gdk2

<<
"gdk2" {
    { [ os windows? ] [ "libgdk-win32-2.0-0.dll" cdecl add-library ] }
    { [ os macos? ] [ drop ] }
    { [ os unix? ] [ "libgdk-x11-2.0.so" cdecl add-library ] }
} cond
>>

GIR: vocab:gir/Gdk-2.0.gir

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

