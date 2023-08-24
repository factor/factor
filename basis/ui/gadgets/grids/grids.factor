! Copyright (C) 2006, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel make math math.order
math.rectangles math.vectors sequences strings.tables
ui.baseline-alignment ui.gadgets ;
IN: ui.gadgets.grids

TUPLE: grid < gadget
grid
{ gap initial: { 0 0 } }
{ fill? initial: t } ;

: new-grid ( children class -- grid )
    new
        swap [ >>grid ] [ concat add-gadgets ] bi ; inline

: <grid> ( children -- grid )
    grid new-grid ;

<PRIVATE

: grid@ ( grid pair -- col# row )
    swap [ first2 ] [ grid>> ] bi* nth ;

PRIVATE>

: grid-child ( grid pair -- gadget ) grid@ nth ;

: grid-add ( grid child pair -- grid )
    [ nip grid-child unparent ]
    [ drop add-gadget ]
    [ swapd grid@ set-nth ] 3tri ;

: grid-remove ( grid pair -- grid ) [ <gadget> ] dip grid-add ;

<PRIVATE

TUPLE: grid-cell pref-dim baseline cap-height ;

: <grid-cell> ( gadget -- cell )
    [ pref-dim ] [ baseline ] [ cap-height ] tri grid-cell boa ;

M: grid-cell baseline baseline>> ;

M: grid-cell cap-height cap-height>> ;

TUPLE: grid-layout grid gap fill? row-heights column-widths ;

: iterate-cell-dims ( cells quot -- seq )
    '[ [ pref-dim>> @ ] [ max ] map-reduce ] map ; inline

: row-heights ( grid-layout -- heights )
    [ grid>> ] [ fill?>> ] bi
    [ [ second ] iterate-cell-dims ]
    [ [ dup [ pref-dim>> ] map measure-height ] map ]
    if ;

: column-widths ( grid-layout -- widths )
    grid>> flip [ first ] iterate-cell-dims ;

: <grid-layout> ( grid -- grid-layout )
    grid-layout new
        swap
        [ grid>> [ [ <grid-cell> ] map ] map >>grid ]
        [ fill?>> >>fill? ]
        [ gap>> >>gap ]
        tri
        dup row-heights >>row-heights
        dup column-widths >>column-widths ;

: accumulate-cell-dims ( seq gap -- n ns )
    dup '[ + _ + ] accumulate ;

: accumulate-cell-xs ( grid-layout -- x xs )
    [ column-widths>> ] [ gap>> first ] bi
    accumulate-cell-dims ;

: accumulate-cell-ys ( grid-layout -- y ys )
    [ row-heights>> ] [ gap>> second ] bi
    accumulate-cell-dims ;

: grid-pref-dim ( grid-layout -- dim )
    [ accumulate-cell-xs drop ]
    [ accumulate-cell-ys drop ]
    bi 2array ;

M: grid pref-dim* <grid-layout> grid-pref-dim ;

: (compute-cell-locs) ( grid-layout -- locs )
    [ accumulate-cell-xs nip ]
    [ accumulate-cell-ys nip ]
    bi cartesian-product flip ;

: adjust-for-baseline ( row-locs row-cells -- row-locs' )
    align-baselines [ 0 swap 2array v+ ] 2map ;

: cell-locs ( grid-layout -- locs )
    dup fill?>>
    [ (compute-cell-locs) ] [
        [ (compute-cell-locs) ] [ grid>> ] bi
        [ adjust-for-baseline ] 2map
    ] if ;

: cell-dims ( grid-layout -- dims )
    dup fill?>>
    [ [ column-widths>> ] [ row-heights>> ] bi cartesian-product flip ]
    [ grid>> [ [ pref-dim>> ] map ] map ]
    if ;

: layout-grid ( children grid-layout -- )
    [ cell-locs ] [ cell-dims ] bi
    [ [ <rect> swap set-rect-bounds ] 3each ] 3each ;

M: grid layout* [ grid>> ] [ <grid-layout> ] bi layout-grid ;

M: grid children-on
    dup children>> empty? [ 2drop f ] [
        [ { 0 1 } ] dip
        [ grid>> ] [ dim>> ] bi
        '[ _ [ loc>> vmin ] reduce ] fast-children-on
        concat
    ] if ;

M: grid gadget-text*
    grid>>
    [ [ gadget-text ] map ] map format-table
    [ CHAR: \n , ] [ % ] interleave ;

PRIVATE>
