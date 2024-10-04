! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors colors combinators combinators.smart formatting
kernel literals math math.functions models sorting.human strings
ui ui.gadgets.scrollers ui.gadgets.search-tables
ui.gadgets.tables ;
IN: color-table

! ui.gadgets.tables demo
SINGLETON: color-renderer

<PRIVATE

CONSTANT: full-block-string $[ 10 CHAR: full-block <string> ]

PRIVATE>

M: color-renderer filled-column
    drop 0 ;

M: color-renderer column-titles
    drop { "Color" "Name" "Red" "Green" "Blue" "Hex" } ;

M: color-renderer row-columns
    drop [
        full-block-string swap
        dup named-color {
            [ red>> "%.5f" sprintf ]
            [ green>> "%.5f" sprintf ]
            [ blue>> "%.5f" sprintf ]
            [ color>hex ]
        } cleave
    ] output>array ;

M: color-renderer row-color
    drop named-color ;

M: color-renderer row-value
    drop named-color ;

: <color-table> ( -- table )
    named-colors humani-sort <model>
    color-renderer
    [ ] <search-table> dup table>>
        5 >>gap
        COLOR: dark-gray >>column-line-color
        10 >>min-rows
        10 >>max-rows drop ;

MAIN-WINDOW: color-table-demo { { title "Colors" } { pref-dim { 500 300 } } }
    <color-table> >>gadgets ;
