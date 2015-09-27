USING: accessors arrays continuations gdk.pixbuf.ffi glib.ffi gobject.ffi
images.loader images.loader.gtk images.loader.gtk.private io
io.encodings.binary io.files kernel tools.test ;
IN: images.loader.gtk.tests

: open-png-image ( -- image )
    "vocab:images/testing/png/basi0g01.png" load-image ;

{ t } [
    open-png-image [ dim>> ] [
        image>GdkPixbuf &g_object_unref
        [ gdk_pixbuf_get_width ] [ gdk_pixbuf_get_height ] bi 2array
    ] bi =
] unit-test

{ t } [
    [
        open-png-image image>GdkPixbuf &g_object_unref
        "frob" GdkPixbuf>byte-array
    ] [ g-error? ] recover
] unit-test
