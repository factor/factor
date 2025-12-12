! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data alien.libraries
alien.syntax combinators gio.ffi glib.ffi gobject-introspection
gobject-introspection.standard-types kernel libc sequences
system vocabs ;
IN: gdk-pixbuf.ffi

<< "gio.ffi" require >>

LIBRARY: gdk-pixbuf

C-LIBRARY: gdk.pixbuf {
    { windows "libgdk_pixbuf-2.0-0.dll" }
    { macos "libgdk_pixbuf-2.0.dylib" }
    { unix "libgdk_pixbuf-2.0.so" }
}

GIR: vocab:gir/GdkPixbuf-2.0.gir

! <workaround incorrect return-values in gir

FORGET: gdk_pixbuf_get_pixels
FUNCTION: guint8* gdk_pixbuf_get_pixels ( GdkPixbuf* pixbuf )

FORGET: gdk_pixbuf_new_from_data
FUNCTION: GdkPixbuf* gdk_pixbuf_new_from_data ( guint8* data,
                                                GdkColorspace colorspace,
                                                gboolean has_alpha,
                                                int bits_per_sample,
                                                int width,
                                                int height,
                                                int rowstride,
                                                GdkPixbufDestroyNotify destroy_fn,
                                                gpointer destroy_fn_data )

FORGET: gdk_pixbuf_save_to_bufferv
FUNCTION: gboolean gdk_pixbuf_save_to_bufferv ( GdkPixbuf* pixbuf,
                                                guint8** data,
                                                gsize* buffer_size,
                                                c-string type,
                                                char **option_keys,
                                                char **option_values,
                                                GError **error )


! workaround>

: data>GInputStream ( data -- GInputStream )
    [ malloc-byte-array &free ] [ length ] bi
    f g_memory_input_stream_new_from_data ;

: GInputStream>GdkPixbuf ( GInputStream -- GdkPixbuf )
    f { { pointer: GError initial: f } }
    [ gdk_pixbuf_new_from_stream ] with-out-parameters
    handle-GError ;
