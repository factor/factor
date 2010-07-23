! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries combinators kernel system
gobject-introspection glib.ffi ;
IN: gstreamer.sdp.ffi

<<
"gstreamer.sdp" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgstsdp-0.10.so" cdecl add-library ] }
} cond
>>

GIR: vocab:gstreamer/sdp/GstSdp-0.10.gir

