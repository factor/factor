! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math math.order math.matrices namespaces make sequences words io
math.vectors ui.gadgets ui.baseline-alignment columns accessors strings.tables
math.rectangles fry ;
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
    [ nip grid-child unparent ] [ drop add-gadget ] [ swapd grid@ set-nth ] 3tri ;

: grid-remove ( grid pair -- grid ) [ <gadget> ] dip grid-add ;

<PRIVATE

TUPLE: cell pref-dim baseline cap-height ;

: <cell> ( gadget -- cell )
    [ pref-dim ] [ baseline ] [ cap-height ] tri cell boa ;

M: cell baseline baseline>> ;

M: cell cap-height cap-height>> ;

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
    \ grid-layout new
        swap
        [ grid>> [ [ <cell> ] map ] map >>grid ]
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
    bi cross-zip flip ;

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
    [ [ column-widths>> ] [ row-heights>> ] bi cross-zip flip ]
    [ grid>> [ [ pref-dim>> ] map ] map ]
    if ;

: grid-layout ( children grid-layout -- )
    [ cell-locs ] [ cell-dims ] bi
    [ [ <rect> swap set-rect-bounds ] 3each ] 3each ;

M: grid layout* [ grid>> ] [ <grid-layout> ] bi grid-layout ;

M: grid children-on ( rect gadget -- seq )
    dup children>> empty? [ 2drop f ] [
        [ { 0 1 } ] dip grid>>
        [ 0 <column> fast-children-on ] keep
        <slice> concat
    ] if ;

M: grid gadget-text*
    grid>>
    [ [ gadget-text ] map ] map format-table
    [ CHAR: \n , ] [ % ] interleave ;

PRIVATE>