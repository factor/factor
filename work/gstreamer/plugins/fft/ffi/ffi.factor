! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries combinators kernel
system
gobject-introspection glib.ffi gstreamer.ffi ;
IN: gstreamer.fft.ffi

<<
"gstreamer.fft" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgstfft-0.10.so" cdecl add-library ] }
} cond
>>

GIR: vocab:gstreamer/fft/GstFft-0.10.gir

