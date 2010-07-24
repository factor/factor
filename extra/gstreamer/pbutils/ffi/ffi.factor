! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries combinators kernel system
gobject-introspection glib.ffi gstreamer.ffi ;
IN: gstreamer.pbutils.ffi

<<
"gstreamer.pbutils" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgstpbutils-0.10.so" cdecl add-library ] }
} cond
>>

GIR: vocab:gstreamer/pbutils/GstPbutils-0.10.gir

