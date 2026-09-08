USING: gdk-pixbuf.ffi kernel sequences tools.test vocabs.loader words ;
IN: gdk-pixbuf.ffi.tests

! Callers compiled before reload must still refer to the corrected bindings.
{ t } [
    { gdk_pixbuf_get_pixels gdk_pixbuf_new_from_data
      gdk_pixbuf_save_to_bufferv }
    "gdk-pixbuf.ffi" reload
    [ dup target-word eq? ] all?
] unit-test
