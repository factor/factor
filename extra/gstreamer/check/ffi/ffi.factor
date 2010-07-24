! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries combinators kernel
system 
gobject-introspection glib.ffi gstreamer.ffi ;
FROM: unix.types => pid_t ;
IN: gstreamer.check.ffi

<<
"gstreamer.check" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgstcheck-0.10.so" cdecl add-library ] }
} cond
>>

IMPLEMENT-STRUCTS: GstCheckABIStruct ;

GIR: vocab:gstreamer/check/GstCheck-0.10.gir

