! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries combinators kernel
system
gobject-introspection glib.ffi gobject.ffi gstreamer.ffi ;
IN: gstreamer.controller.ffi

<<
"gstreamer.controller" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgstcontroller-0.10.so" cdecl add-library ] }
} cond
>>

GIR: vocab:gstreamer/controller/GstController-0.10.gir

