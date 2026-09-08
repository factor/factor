USING: kernel pango.ffi sequences tools.test vocabs.loader words ;
IN: pango.ffi.tests

! Callers compiled before reload must still refer to the corrected bindings.
{ t } [
    { pango_layout_line_index_to_x pango_layout_line_x_to_index }
    "pango.ffi" reload
    [ dup target-word eq? ] all?
] unit-test
