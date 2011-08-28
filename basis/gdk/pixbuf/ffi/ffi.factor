! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.data alien.libraries alien.syntax
combinators gio.ffi glib.ffi gmodule.ffi gobject-introspection
gobject.ffi kernel libc sequences system vocabs.loader ;
EXCLUDE: alien.c-types => pointer ;
IN: gdk.pixbuf.ffi

"gio.ffi" require

LIBRARY: gdk.pixbuf

<<
"gdk.pixbuf" {
    { [ os winnt? ] [ "libgdk_pixbuf-2.0-0.dll" cdecl add-library ] }
    { [ os unix? ] [ drop ] }
} cond
>>

GIR: vocab:gdk/pixbuf/GdkPixbuf-2.0.gir

: data>GInputStream ( data -- GInputStream )
    [ malloc-byte-array &free ] [ length ] bi
    f g_memory_input_stream_new_from_data ;

: GInputStream>GdkPixbuf ( GInputStream -- GdkPixbuf )
    f { { pointer: GError initial: f } }
    [ gdk_pixbuf_new_from_stream ] with-out-parameters
    handle-GError ;
