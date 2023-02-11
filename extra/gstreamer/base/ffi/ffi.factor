! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs ;
IN: gstreamer.base.ffi

<<
"gstreamer.ffi" require
>>

LIBRARY: gstreamer.base

<<
"gstreamer.base" {
    { [ os windows? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgstbase-0.10.so" cdecl add-library ] }
} cond
>>

GIR: GstBase-0.10.gir
