USING: accessors arrays continuations gdk-pixbuf.ffi glib.ffi
gobject.ffi images images.loader images.loader.gtk images.loader.gtk.private
io io.encodings.binary io.files kernel tools.test destructors ;
IN: images.loader.gtk.tests

: open-png-image ( -- image )
    "vocab:images/testing/png/basi0g01.png" load-image ;

{ t } [
    [
        open-png-image [ dim>> ] [
            image>GdkPixbuf &g_object_unref
            [ gdk_pixbuf_get_width ] [ gdk_pixbuf_get_height ] bi 2array
        ] bi =
    ] with-destructors
] unit-test

! Exercise array returns and constructors with actual pixels, including alpha.
{ B{ 255 0 0 255 0 255 0 128 0 0 255 64 255 255 255 0 } } [
    [
        <image> { 2 2 } >>dim RGBA >>component-order
        ubyte-components >>component-type
        B{ 255 0 0 255 0 255 0 128 0 0 255 64 255 255 255 0 } >>bitmap
        image>GdkPixbuf &g_object_unref
        "png" GdkPixbuf>byte-array
        data>GInputStream &g_object_unref
        GInputStream>GdkPixbuf &g_object_unref
        GdkPixbuf>image bitmap>>
    ] with-destructors
] unit-test

! Exercise the encoded buffer and its native-size length out-parameter.
{ t } [
    [
        open-png-image [ dim>> ] [
            image>GdkPixbuf &g_object_unref
            "png" GdkPixbuf>byte-array
            data>GInputStream &g_object_unref
            GInputStream>GdkPixbuf &g_object_unref
            [ gdk_pixbuf_get_width ] [ gdk_pixbuf_get_height ] bi 2array
        ] bi =
    ] with-destructors
] unit-test

{ t } [
    [
        [
            open-png-image image>GdkPixbuf &g_object_unref
            "frob" GdkPixbuf>byte-array
        ] [ g-error? ] recover
    ] with-destructors
] unit-test
