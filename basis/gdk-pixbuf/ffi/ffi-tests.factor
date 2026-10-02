USING: accessors alien.c-types alien.syntax gdk-pixbuf.ffi glib.ffi
gobject-introspection.standard-types kernel sequences tools.test
vocabs.loader words ;
IN: gdk-pixbuf.ffi.tests

! Callers compiled before reload must still refer to the corrected bindings.
{ t } [
    { gdk_pixbuf_get_pixels gdk_pixbuf_new_from_data
      gdk_pixbuf_save_to_bufferv }
    "gdk-pixbuf.ffi" reload
    [ dup target-word eq? ] all?
] unit-test

! These bindings must come from GIR, including array returns and error outputs.
{ t } [
    \ gdk_pixbuf_get_pixels def>> first guint8 <pointer> =
] unit-test

{ t } [
    \ gdk_pixbuf_new_from_data def>> first GdkPixbuf <pointer> =
] unit-test

{ t } [
    \ gdk_pixbuf_save_to_bufferv def>> 3 swap nth
    {
        pointer: GdkPixbuf pointer: pointer: guint8 pointer: gsize
        pointer: gchar pointer: pointer: gchar pointer: pointer: gchar
        pointer: pointer: GError
    } =
] unit-test
