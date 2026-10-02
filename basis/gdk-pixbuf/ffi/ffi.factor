! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data alien.libraries
alien.syntax combinators gio.ffi glib.ffi gobject-introspection
gobject-introspection.standard-types kernel libc sequences
system vocabs ;
IN: gdk-pixbuf.ffi

<< "gio.ffi" require >>

LIBRARY: gdk-pixbuf

C-LIBRARY: gdk-pixbuf {
    { windows "libgdk_pixbuf-2.0-0.dll" }
    { macos "libgdk_pixbuf-2.0.dylib" }
    { linux "libgdk_pixbuf-2.0.so.0" }
    { unix "libgdk_pixbuf-2.0.so" }
}

GIR: vocab:gir/GdkPixbuf-2.0.gir

: data>GInputStream ( data -- GInputStream )
    [ malloc-byte-array &free ] [ length ] bi
    f g_memory_input_stream_new_from_data ;

: GInputStream>GdkPixbuf ( GInputStream -- GdkPixbuf )
    f { { pointer: GError initial: f } }
    [ gdk_pixbuf_new_from_stream ] with-out-parameters
    handle-GError ;
