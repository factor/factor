! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries combinators kernel
system vocabs.parser words
gobject-introspection gdk.ffi gdk.pixbuf.ffi gio.ffi glib.ffi
gmodule.ffi gobject.ffi pango.ffi ;
IN: gdk.gl.ffi

<<
"gdk.gl" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgdkglext-x11-1.0.so" cdecl add-library ] }
} cond
>>

<< ulong "unsigned long" current-vocab create typedef >>

GIR: vocab:gdk/gl/GdkGL-1.0.gir

