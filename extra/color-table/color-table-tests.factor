USING: accessors color-table colors kernel sequences tools.test
ui.gadgets.tables ;
IN: color-table.tests

! Color names and numeric values stay legible; only the swatch is colored.
{ t "blue" f } [
    "blue" color-renderer row-columns
    [ first color>> COLOR: blue color= ] [ second ] bi
    "blue" color-renderer row-color
] unit-test
