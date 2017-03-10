USING: specialized-arrays.instances.alien.c-types.int tools.test
ui.pixel-formats ;
IN: ui.pixel-formats.tests

CONSTANT: attrib-table {
    { windowed { 99 } }
    { double-buffered { 7 } }
}

! pixel-format-attributes>int-array
{ int-array{ 9 2 99 7 0 } } [
    { windowed double-buffered } { 9 2 } attrib-table
    pixel-format-attributes>int-array
] unit-test
