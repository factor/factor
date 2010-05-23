! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.syntax alien.libraries combinators 
kernel system
gir glib glib.ffi gobject gmodule ;
EXCLUDE: alien.c-types => pointer ;

<<
"gst" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgstreamer-0.10.so" cdecl add-library ] }
} cond
>>

IN: gst.ffi

TYPEDEF: gpointer GstClockID
TYPEDEF: guint64 GstClockTime
TYPEDEF: gint64 GstClockTimeDiff

! Временное исправление отсутвующих типов libxml2
TYPEDEF: void* xmlNodePtr
TYPEDEF: void* xmlDocPtr
TYPEDEF: void* xmlNsPtr

IN-GIR: gst vocab:gst/Gst-0.10.gir

