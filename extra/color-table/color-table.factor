! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors combinators.smart sorting.human
models colors.constants present sorting.slots
ui ui.gadgets.tables ui.gadgets.scrollers ;
IN: color-table

! ui.gadgets.tables demo
SINGLETON: color-renderer

M: color-renderer filled-column
    drop 0 ;

M: color-renderer column-titles
    drop { "Name" "Red" "Green" "Blue" } ;

M: color-renderer row-columns
    drop [
        dup named-color
        [ red>> present ]
        [ green>> present ]
        [ blue>> present ] tri
    ] output>array ;

M: color-renderer row-color
    drop named-color ;

M: color-renderer row-value
    drop named-color ;

: <color-table> ( -- table )
    named-colors { human<=> } sort-by <model>
    color-renderer
    <table>
        5 >>gap
        COLOR: dark-gray >>column-line-color
        10 >>min-rows
        10 >>max-rows ;

MAIN-WINDOW: color-table-demo { { title "Colors" } }
    <color-table> <scroller> >>gadgets ;
