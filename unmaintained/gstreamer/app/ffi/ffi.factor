! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries combinators kernel
system
gobject-introspection glib.ffi gstreamer.ffi ;
IN: gstreamer.app.ffi

<<
"gstreamer.app" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgstapp-0.10.so" cdecl add-library ] }
} cond
>>

GIR: vocab:gstreamer/app/GstApp-0.10.gir

