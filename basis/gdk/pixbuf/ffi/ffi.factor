! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.data alien.libraries alien.syntax
combinators gio.ffi glib.ffi gobject-introspection
gobject-introspection.standard-types kernel libc
sequences system vocabs.loader ;
IN: gdk.pixbuf.ffi

<<
"gio.ffi" require
>>

LIBRARY: gdk.pixbuf

<<
"gdk.pixbuf" {
    { [ os windows? ] [ "libgdk_pixbuf-2.0-0.dll" cdecl add-library ] }
    { [ os unix? ] [ drop ] }
} cond
>>

GIR: vocab:gdk/pixbuf/GdkPixbuf-2.0.gir

! <workaround incorrect return-value in gir

FORGET: gdk_pixbuf_get_pixels
FUNCTION: guint8* gdk_pixbuf_get_pixels ( GdkPixbuf* pixbuf ) ;

! workaround>

: data>GInputStream ( data -- GInputStream )
    [ malloc-byte-array &free ] [ length ] bi
    f g_memory_input_stream_new_from_data ;

: GInputStream>GdkPixbuf ( GInputStream -- GdkPixbuf )
    f { { pointer: GError initial: f } }
    [ gdk_pixbuf_new_from_stream ] with-out-parameters
    handle-GError ;
