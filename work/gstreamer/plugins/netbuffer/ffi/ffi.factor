! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries combinators kernel system
gobject-introspection glib.ffi ;
IN: gstreamer.netbuffer.ffi

<<
"gstreamer.netbuffer" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgstnetbuffer-0.10.so" cdecl add-library ] }
} cond
>>

GIR: vocab:gstreamer/netbuffer/GstNetbuffer-0.10.gir

