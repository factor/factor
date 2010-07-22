! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.destructors alien.syntax
alien.libraries cairo.ffi combinators kernel system
gobject-introspection gdk.pixbuf.ffi gio.ffi glib.ffi gmodule.ffi
gobject.ffi pango.ffi ;
IN: gdk.ffi

<<
"gdk" {
    { [ os winnt? ] [ "libgdk-win32-2.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgdk-x11-2.0.so" cdecl add-library ] }
} cond
>>

TYPEDEF: guint32 GdkNativeWindow
TYPEDEF: guint32 GdkWChar
C-TYPE: GdkXEvent

IMPLEMENT-STRUCTS: GdkEventAny GdkEventKey GdkEventButton
GdkEventScroll GdkEventMotion GdkEventExpose GdkEventVisibility
GdkEventCrossing GdkEventFocus GdkEventConfigure GdkEventProperty
GdkEventSelection GdkEventDND GdkEventProximity GdkEventClient
GdkEventNoExpose GdkEventWindowState GdkEventSetting
GdkEventOwnerChange GdkEventGrabBroken GdkRectangle ;

GIR: vocab:gdk/Gdk-2.0.gir

DESTRUCTOR: gdk_cursor_unref

