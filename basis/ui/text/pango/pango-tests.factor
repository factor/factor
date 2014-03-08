USING: accessors fonts kernel math pango.ffi sequences tools.test
ui.text.pango ;
IN: ui.text.pango.tests

: long-string ( -- str )
    3000 [ "foo" ] replicate concat ;

[ 1 ] [
    "foo" monospace-font -1 PANGO_WRAP_WORD_CHAR <PangoLayout>
    pango_layout_get_line_count
] unit-test

[ 100.0 ] [
    "foo" monospace-font 100 PANGO_WRAP_WORD_CHAR <PangoLayout>
    pango_layout_get_width pango>float
] unit-test

[ 127 500.0 ] [
    long-string monospace-font 500 PANGO_WRAP_WORD_CHAR <PangoLayout>
    [ pango_layout_get_line_count ] [ pango_layout_get_width pango>float ] bi
] unit-test

[ -1 ] [
    "foo" monospace-font -1 PANGO_WRAP_WORD_CHAR <PangoLayout>
    pango_layout_get_width
] unit-test

[ 10000.0 t ] [
    monospace-font long-string <layout>
    [ layout>> pango_layout_get_width pango>float ]
    [ logical-rect>> dim>> first 10000 < ] bi
] unit-test
