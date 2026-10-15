USING: accessors alien alien.c-types alien.syntax gdk2.ffi
gobject-introspection.ffi gobject-introspection.standard-types
kernel sequences system tools.test
vocabs words ;
IN: gdk2.ffi.tests

{ f t } [
    "gdk_device_manager_get_client_pointer" "gdk2.ffi" lookup-word >boolean
    "gdk_drawable_get_size" "gdk2.ffi" lookup-word >boolean
] unit-test

{ t } [
    \ gdk_drawable_get_size def>> 3 swap nth
    { pointer: GdkDrawable pointer: gint pointer: gint } =
] unit-test

{ t } [
    GdkNativeWindow heap-size
    os windows? [ void* ] [ guint32 ] if heap-size =
] unit-test

! Sentinel pointers are recreated when called, so saved images keep them valid.
{ 2 1 } [ GDK_NO_BG alien-address GDK_PARENT_RELATIVE_BG alien-address ] unit-test

{ t } [
    \ GDK_NO_BG def>> last \ <alien> eq?
] unit-test

{ 16 } [ GdkRectangle heap-size ] unit-test
