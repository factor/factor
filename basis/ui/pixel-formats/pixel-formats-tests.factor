USING: alien.c-types literals specialized-arrays tools.test
ui.pixel-formats ;
SPECIALIZED-ARRAY: int
IN: ui.pixel-formats.tests

CONSTANT: attrib-table {
    { windowed { 99 } }
    { double-buffered { 7 } }
    { samples { 100001 } }
}

SYMBOL: garbageword
CONSTANT: garbageint 234

! pixel-format-attributes>int-array
! it should ignore garbage, even the color-bits because it's not
! in the table
{ int-array{ 9 2 99 7 100001 2 0 } } [
    {
        windowed "garbage" $ garbageint double-buffered
        garbageword T{ samples f 2 } T{ color-bits f 24 }
    } { 9 2 } attrib-table
    pixel-format-attributes>int-array
] unit-test
