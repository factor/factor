! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math math.order namespaces make sequences words io
math.vectors ui.gadgets columns accessors strings.tables
math.geometry.rect locals fry ;
IN: ui.gadgets.grids

TUPLE: grid < gadget
grid
{ gap initial: { 0 0 } }
{ fill? initial: t } ;

: new-grid ( children class -- grid )
    new-gadget
        swap [ >>grid ] [ concat add-gadgets ] bi ; inline

: <grid> ( children -- grid )
    grid new-grid ;

:: grid-child ( grid i j -- gadget ) i j grid grid>> nth nth ;

:: grid-add ( grid child i j -- grid )
    grid i j grid-child unparent
    grid child add-gadget
    child i j grid grid>> nth set-nth ;

: grid-remove ( grid i j -- grid ) [ <gadget> ] 2dip grid-add ;

<PRIVATE

: cross-zip ( seq1 seq2 -- seq1xseq2 )
    [ [ 2array ] with map ] curry map ;

TUPLE: cell pref-dim baseline ;

: <cell> ( gadget -- cell ) [ pref-dim ] [ baseline ] bi cell boa ;

M: cell baseline baseline>> ;

TUPLE: grid-layout grid gap fill? row-heights column-widths ;

: iterate-cell-dims ( cells quot -- seq )
    '[ [ pref-dim>> @ ] [ max ] map-reduce ] map ; inline

: row-heights ( grid-layout -- heights )
    [ grid>> ] [ fill?>> ] bi
    [ [ second ] iterate-cell-dims ]
    [ [ dup [ pref-dim>> ] map baseline-metrics + ] map ]
    if ;

: column-widths ( grid-layout -- widths )
    grid>> flip [ first ] iterate-cell-dims ;

: <grid-layout> ( grid -- grid-layout )
    grid-layout new
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

M: grid pref-dim*
    <grid-layout>
    [ accumulate-cell-xs drop ]
    [ accumulate-cell-ys drop ]
    bi 2array ;

: (compute-cell-locs) ( grid-layout -- locs )
    [ accumulate-cell-xs nip ]
    [ accumulate-cell-ys nip ]
    bi cross-zip flip ;

: adjust-for-baseline ( row-locs row-cells -- row-locs' )
    baseline-align [ 0 swap 2array v+ ] 2map ;

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

M: grid layout*
    [ grid>> ] [ <grid-layout> [ cell-locs ] [ cell-dims ] bi ] bi
    [ [ [ >>loc ] [ >>dim ] bi* drop ] 3each ] 3each ;

M: grid children-on ( rect gadget -- seq )
    dup children>> empty? [ 2drop f ] [
        { 0 1 } swap grid>>
        [ 0 <column> fast-children-on ] keep
        <slice> concat
    ] if ;

M: grid gadget-text*
    grid>>
    [ [ gadget-text ] map ] map format-table
    [ CHAR: \n , ] [ % ] interleave ;

PRIVATE>