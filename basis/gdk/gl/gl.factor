! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.libraries alien.syntax combinators kernel system vocabs.parser words
gir glib gobject gio gmodule gdk gdk.ffi gdk.pixbuf ;

<<
"gdk.gl" {
    { [ os winnt? ] [ "" "cdecl" add-library ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgdkglext-x11-1.0.so" "cdecl" add-library ] }
} cond
>>

IN: gdk.gl.ffi

<< ulong "unsigned long" current-vocab create typedef >>

IN-GIR: gdk.gl vocab:gdk/gl/GdkGL-1.0.gir

