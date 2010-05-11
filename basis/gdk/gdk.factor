! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax alien.libraries cairo.ffi
combinators kernel system
gir glib gobject gio gmodule gdk.pixbuf glib.ffi ;
EXCLUDE: alien.c-types => pointer ;

<<
"gdk" {
    { [ os winnt? ] [ "libgdk-win32-2.0-0.dll" "cdecl" add-library ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgdk-x11-2.0.so" "cdecl" add-library ] }
} cond
>>

IN: gdk.ffi

TYPEDEF: guint32 GdkNativeWindow
TYPEDEF: guint32 GdkWChar

IMPLEMENT-STRUCTS: GdkEventAny GdkEventKey GdkEventButton
GdkEventScroll GdkEventMotion GdkEventExpose GdkEventVisibility
GdkEventCrossing GdkEventFocus GdkEventConfigure GdkEventProperty
GdkEventSelection GdkEventDND GdkEventProximity GdkEventClient
GdkEventNoExpose GdkEventWindowState GdkEventSetting
GdkEventOwnerChange GdkEventGrabBroken ;

IN-GIR: gdk vocab:gdk/Gdk-2.0.gir

