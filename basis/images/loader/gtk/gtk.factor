! Copyright (C) 2010 Philipp Brüschweiler.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.syntax arrays
assocs combinators gdk-pixbuf.ffi glib.ffi gobject.ffi
grouping images images.loader io kernel math sequences specialized-arrays
system unicode ;
IN: images.loader.gtk
SPECIALIZED-ARRAY: uchar

SINGLETON: gtk-image

os linux? [
    { "png" "tif" "tiff" "gif" "jpg" "jpeg" "bmp" "ico" }
    [ gtk-image register-image-class ] each
] when

<PRIVATE

: image-data ( GdkPixbuf -- data )
    {
        [ gdk_pixbuf_get_pixels ]
        [ gdk_pixbuf_get_width ]
        [ gdk_pixbuf_get_height ]
        [ gdk_pixbuf_get_rowstride ]
        [ gdk_pixbuf_get_n_channels ]
        [ gdk_pixbuf_get_bits_per_sample ]
    } cleave
    [let :> ( pixels w h rowstride channels bps )
        bps channels * 7 + 8 /i w * :> bytes-per-row

        bytes-per-row rowstride =
        [ pixels h rowstride * memory>byte-array ]
        [
            pixels rowstride h * uchar <c-direct-array>
            rowstride <groups>
            [ bytes-per-row head-slice ] map concat
        ] if
    ] ;

CONSTANT: bits>components {
    { 8 ubyte-components }
    { 16 ushort-components }
    { 32 uint-components }
}

: component-type ( GdkPixbuf -- component-type )
    gdk_pixbuf_get_bits_per_sample bits>components at ;

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

: image>GdkPixbuf ( image -- GdkPixbuf )
    {
        [ bitmap>> ]
        [ drop GDK_COLORSPACE_RGB ]
        [ has-alpha? ]
        [ component-type>> bytes-per-component 8 * ]
        [ dim>> first2 ]
        [ rowstride ]
    } cleave f f gdk_pixbuf_new_from_data ;

: GdkPixbuf>byte-array ( GdkPixbuf type -- byte-array )
    { void* int } [
        rot f f
        { { pointer: GError initial: f } } [
            gdk_pixbuf_save_to_bufferv drop
        ] with-out-parameters
    ] with-out-parameters rot handle-GError memory>byte-array ;

! The type parameter is almost always the same as the file extension,
! except for in the jpg -> jpeg and tif -> tiff cases.
: extension>pixbuf-type ( extension -- type )
    >lower { { "jpg" "jpeg" } { "tif" "tiff" } } ?at drop ;

: write-image ( image extension -- )
    [ image>GdkPixbuf &g_object_unref ] [ extension>pixbuf-type ] bi*
    GdkPixbuf>byte-array write ;

PRIVATE>

M: gtk-image stream>image*
    drop
    stream-contents data>GInputStream &g_object_unref
    GInputStream>GdkPixbuf &g_object_unref
    GdkPixbuf>image ;

M: gtk-image image>stream
    drop write-image ;
