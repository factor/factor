! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs.loader ;
IN: gstreamer.controller.ffi

<<
"gstreamer.ffi" require
>>

LIBRARY: gstreamer.controller

<<
"gstreamer.controller" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgstcontroller-0.10.so" cdecl add-library ] }
} cond
>>

GIR: GstController-0.10.gir

