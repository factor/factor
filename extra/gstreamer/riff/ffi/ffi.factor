! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.syntax alien.libraries combinators kernel
system
gobject-introspection glib.ffi gmodule.ffi gobject.ffi ;
EXCLUDE: alien.c-types => pointer ;
IN: gstreamer.ffi

<<
"gstreamer" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgstreamer-0.10.so" cdecl add-library ] }
} cond
>>

TYPEDEF: gpointer GstClockID
TYPEDEF: guint64 GstClockTime
TYPEDEF: gint64 GstClockTimeDiff

! types from libxml2
TYPEDEF: void* xmlNodePtr
TYPEDEF: void* xmlDocPtr
TYPEDEF: void* xmlNsPtr

GIR: vocab:gstreamer/Gst-0.10.gir

