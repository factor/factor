! Copyright (C) 2010 Philipp Brüschweiler.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings
alien.syntax arrays classes.struct combinators destructors
gdk.pixbuf.ffi gio.ffi glib.ffi gobject.ffi grouping images
images.loader io io.encodings.utf8
kernel libc locals math sequences specialized-arrays ;
IN: images.gtk
SPECIALIZED-ARRAY: uchar

SINGLETON: gtk-image
"png"  gtk-image register-image-class
"tif"  gtk-image register-image-class
"tiff" gtk-image register-image-class
"gif"  gtk-image register-image-class
"jpg"  gtk-image register-image-class
"jpeg" gtk-image register-image-class
"bmp"  gtk-image register-image-class
"ico"  gtk-image register-image-class

ERROR: g-error domain code message ;

<PRIVATE

: data>GInputStream ( data -- GInputStream )
    [ malloc-byte-array &free ] [ length ] bi
    f g_memory_input_stream_new_from_data &g_object_unref ;

: GError>g-error ( GError -- g-error )
    [ domain>> g_quark_to_string utf8 alien>string ]
    [ code>> ]
    [ message>> utf8 alien>string ] tri
    \ g-error boa ;

: handle-GError ( GError/f -- )
    [
        [ GError>g-error ]
        [ g_error_free ] bi
        throw
    ] when* ;

STRUCT: GErrorPointer { to pointer: GError } ;

: GInputStream>GdkPixbuf ( GInputStream -- GdkPixbuf )
    f GErrorPointer malloc-struct &free
    [ gdk_pixbuf_new_from_stream ] keep
    to>> handle-GError &g_object_unref ;

: image-data ( GdkPixbuf -- data )
    [let
        {
            [ gdk_pixbuf_get_pixels ]
            [ gdk_pixbuf_get_width ]
            [ gdk_pixbuf_get_height ]
            [ gdk_pixbuf_get_rowstride ]
            [ gdk_pixbuf_get_n_channels ]
            [ gdk_pixbuf_get_bits_per_sample ]
        } cleave :> ( pixels w h rowstride channels bps )
        bps channels * 7 + 8 /i w * :> bytes-per-row
        pixels rowstride h * <direct-uchar-array>
        rowstride <sliced-groups>
        [ bytes-per-row head-slice ] map concat
    ] ;

: component-type ( GdkPixbuf -- component-type )
    gdk_pixbuf_get_bits_per_sample {
        {  8 [ ubyte-components ] }
        { 16 [ ushort-components ] }
        { 32 [ uint-components ] }
    } case ;

: GdkPixbuf>image ( GdkPixbuf -- image )
    [ image new ] dip
        {
            [ [ gdk_pixbuf_get_width ] [ gdk_pixbuf_get_height ] bi 2array >>dim ]
            [ image-data >>bitmap ]
            [ gdk_pixbuf_get_has_alpha RGBA RGB ? >>component-order ]
            [ component-type >>component-type ]
        } cleave
        f >>premultiplied-alpha?
        f >>upside-down? ;

PRIVATE>

M: gtk-image stream>image
    drop [
        stream-contents data>GInputStream
        GInputStream>GdkPixbuf GdkPixbuf>image
    ] with-destructors ;
