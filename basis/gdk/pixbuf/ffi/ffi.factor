! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs.loader ;
IN: gdk.pixbuf.ffi

<<
"gio.ffi" require
>>

LIBRARY: gdk.pixbuf

<<
"gdk.pixbuf" {
    { [ os winnt? ] [ "libgdk_pixbuf-2.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgdk_pixbuf-2.0.so" cdecl add-library ] }
} cond
>>

GIR: vocab:gdk/pixbuf/GdkPixbuf-2.0.gir
