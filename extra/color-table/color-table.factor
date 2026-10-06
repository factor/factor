! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors colors combinators combinators.smart formatting
kernel literals math math.functions models sequences sorting.human strings
ui ui.gadgets.scrollers ui.gadgets.search-tables
ui.gadgets.tables ui.gadgets.tables.private ui.render ui.text ui.theme opengl ;
IN: color-table

! ui.gadgets.tables demo
SINGLETON: color-renderer

<PRIVATE

CONSTANT: full-block-string $[ 10 CHAR: full-block <string> ]

PRIVATE>

! Only the swatch uses the named color. Keep the values in the theme font.
TUPLE: color-swatch color ;

M: color-swatch cell-dim drop full-block-string text-dim first2 0 ;

M: color-swatch draw-cell
    [ full-block-string text-dim ] [ color>> gl-color ] bi*
    { 0 0 } swap gl-fill-rect ;

M: color-renderer filled-column
    drop 0 ;

M: color-renderer column-titles
    drop { "Color" "Name" "Red" "Green" "Blue" "Hex" } ;

M: color-renderer row-columns
    drop [
        dup named-color color-swatch boa swap
        dup named-color {
            [ red>> "%.5f" sprintf ]
            [ green>> "%.5f" sprintf ]
            [ blue>> "%.5f" sprintf ]
            [ color>hex ]
        } cleave
    ] output>array ;

M: color-renderer row-color
    2drop f ;

M: color-renderer row-value
    drop named-color ;

: <color-table> ( -- table )
    named-colors humani-sort <model>
    color-renderer
    [ ] <search-table> dup table>>
        5 >>gap
        line-color >>column-line-color
        10 >>min-rows
        10 >>max-rows drop ;

MAIN-WINDOW: color-table-demo { { title "Colors" } { pref-dim { 500 300 } } }
    <color-table> >>gadgets ;
