! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries combinators kernel
system
gobject-introspection glib.ffi gobject.ffi gstreamer.ffi ;
IN: gstreamer.video.ffi

<<
"gstreamer.video" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgstvideo-0.10.so" cdecl add-library ] }
} cond
>>

IMPLEMENT-STRUCTS: GstVideoRectangle ;

GIR: vocab:gstreamer/video/GstVideo-0.10.gir

