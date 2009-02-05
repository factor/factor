! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors fry kernel math
math.rectangles math.order math.vectors namespaces opengl
sequences ui.gadgets ui.gadgets.scrollers ui.gadgets.status-bar
ui.gadgets.worlds ui.gadgets.theme ui.gestures ui.render ui.text
ui.gadgets.menus math.rectangles models math.ranges sequences
combinators fonts ;
IN: ui.gadgets.tables

! Row rendererer protocol
GENERIC: row-columns ( row renderer -- columns )
GENERIC: row-value ( row renderer -- object )

SINGLETON: trivial-renderer

M: trivial-renderer row-columns drop ;
M: object row-value drop ;

TUPLE: table < gadget
renderer filled-column column-alignment action hook
column-widths total-width
font text-color selection-color focus-border-color
mouse-color column-line-color selection-required?
selected-index selected-value
mouse-index
focused? ;

: <table> ( rows -- table )
    table new-gadget
        swap >>model
        trivial-renderer >>renderer
        [ drop ] >>action
        [ ] >>hook
        f <model> >>selected-value
        sans-serif-font >>font
        selection-color >>selection-color
        focus-border-color >>focus-border-color
        dark-gray >>column-line-color
        black >>mouse-color
        black >>text-color ;

<PRIVATE

: line-height ( table -- n )
    font>> "" text-height ;

CONSTANT: table-gap 6

: table-rows ( table -- rows )
    [ control-value ] [ renderer>> ] bi '[ _ row-columns ] map ;

: (compute-column-widths) ( font rows -- total widths )
    [ drop 0 { } ] [
        [ nip first length 0 <repetition> ] 2keep
        [ [ text-width ] with map vmax ] with each
        [ [ sum ] [ length 1 [-] table-gap * ] bi + ] keep
    ] if-empty ;

: compute-column-widths ( table -- total-width column-widths )
    [ font>> ] [ table-rows ] bi (compute-column-widths) ;

: update-cached-widths ( table -- )
    dup compute-column-widths
    [ >>total-width ] [ >>column-widths ] bi*
    drop ;

: filled-column-width ( table -- n )
    [ dim>> first ] [ total-width>> ] bi [-] ;

: update-filled-column ( table -- )
    [ filled-column-width ]
    [ filled-column>> ]
    [ column-widths>> ] tri
    2dup empty? not and
    [ [ + ] change-nth ] [ 3drop ] if ;

M: table layout*
    [ update-cached-widths ] [ update-filled-column ] bi ;

: row-rect ( table row -- rect )
    [ [ line-height ] dip * 0 swap 2array ]
    [ drop [ dim>> first ] [ line-height ] bi 2array ] 2bi <rect> ;

: highlight-row ( table row color quot -- )
    [ [ row-rect rect-bounds ] dip gl-color ] dip
    '[ _ @ ] with-translation ; inline

: draw-selected-row ( table row -- )
    over selection-color>> [ gl-fill-rect ] highlight-row ;

: draw-focused-row ( table row -- )
    over focused?>> [
        over focus-border-color>> [ gl-rect ] highlight-row
    ] [ 2drop ] if ;

: draw-selected ( table -- )
    dup selected-index>> dup
    [ [ draw-selected-row ] [ draw-focused-row ] 2bi ]
    [ 2drop ]
    if ;

: draw-moused ( table -- )
    dup mouse-index>> dup [
        over mouse-color>> [ gl-rect ] highlight-row
    ] [ 2drop ] if ;

: column-offsets ( table -- xs )
    0 [ table-gap + + ] accumulate nip ;

: column-line-offsets ( table -- xs )
    column-offsets
    [ f ] [ rest-slice [ table-gap 2/ - ] map ] if-empty ;

: draw-columns ( table -- )
    [ column-line-color>> gl-color ]
    [
        [ column-widths>> column-line-offsets ] [ dim>> second ] bi
        '[ [ 0 2array ] [ _ 2array ] bi gl-line ] each
    ] bi ;

: y>row ( y table -- n )
    line-height /i ;

: validate-row ( m table -- n )
    control-value [ drop f ] [ length 1- min 0 max ] if-empty ;

: visible-row ( table quot -- n )
    '[
        [ clip get @ origin get [ second ] bi@ - ] dip
        y>row
    ] keep validate-row ; inline

: first-visible-row ( table -- n )
    [ loc>> ] visible-row ;

: last-visible-row ( table -- n )
    [ rect-extent nip ] visible-row 1+ ;

: column-loc ( font column width align -- loc )
    [ [ text-width ] dip swap - ] dip
    * 0 2array ;

: draw-column ( font column width align -- )
    over [
        [ 2dup ] 2dip column-loc draw-text
    ] dip table-gap + 0 2array gl-translate ;

: draw-row ( columns widths align font -- )
    '[ [ _ ] 3dip draw-column ] 3each ;

: each-slice-index ( from to seq quot -- )
    [ [ <slice> ] [ drop [a,b) ] 3bi ] dip 2each ; inline

: column-alignment ( table -- seq )
    dup column-alignment>>
    [ ] [ column-widths>> length 0 <repetition> ] ?if ;

: draw-rows ( table -- )
    {
        [ text-color>> gl-color ]
        [ first-visible-row ]
        [ last-visible-row ]
        [ control-value ]
        [ line-height ]
        [ renderer>> ]
        [ column-widths>> ]
        [ column-alignment ]
        [ font>> ]
    } cleave '[
        [ 0 ] dip _ * 2array [
            _ row-columns _ _ _ draw-row
        ] with-translation
    ] each-slice-index ;

M: table draw-gadget*
    dup control-value empty? [ drop ] [
        origin get [
            {
                [ draw-selected ]
                [ draw-columns ]
                [ draw-rows ]
                [ draw-moused ]
            } cleave
        ] with-translation
    ] if ;

M: table pref-dim*
    [ compute-column-widths drop ] keep
    [ font>> "" text-height ]
    [ control-value length ]
    bi * 2array ;

: nth-row ( row table -- value/f ? )
    over [ control-value nth t ] [ 2drop f f ] if ;

PRIVATE>

: (selected-row) ( table -- value/f ? )
    [ selected-index>> ] keep nth-row ;

: selected-row ( table -- value/f ? )
    [ (selected-row) ] keep
    swap [ renderer>> row-value t ] [ 2drop f f ] if ;

<PRIVATE

: update-selected-value ( table -- )
    [ selected-row drop ] [ selected-value>> ] bi set-model ;

: initial-selected-index ( model table -- n/f )
    [ value>> length 1 >= ] [ selection-required?>> ] bi* and 0 f ? ;

: show-row-summary ( table n -- )
    over nth-row
    [ swap [ renderer>> row-value ] keep show-summary ]
    [ 2drop ]
    if ;

M: table model-changed
    [ nip ] [ initial-selected-index ] 2bi {
        [ >>selected-index drop ]
        [ show-row-summary ]
        [ drop update-selected-value ]
        [ drop relayout ]
    } 2cleave ;

: thin-row-rect ( table row -- rect )
    row-rect [ { 0 1 } v* ] change-dim ;

: (select-row) ( table n -- )
    [ dup [ [ thin-row-rect ] [ drop ] 2bi scroll>rect ] [ 2drop ] if ]
    [ >>selected-index relayout-1 ]
    2bi ;

: mouse-row ( table -- n )
    [ hand-rel second ] keep y>row ;

: table-button-down ( table -- )
    dup request-focus
    dup control-value empty? [ drop ] [
        dup [ mouse-row ] keep validate-row
        [ >>mouse-index ] [ (select-row) ] bi
    ] if ;

PRIVATE>

: row-action ( table -- )
    dup selected-row [ swap action>> call ] [ 2drop ] if ;

<PRIVATE

: table-button-up ( table -- )
    hand-click# get 2 =
    [ row-action ] [ update-selected-value ] if ;

: select-row ( table n -- )
    over validate-row
    [ (select-row) ]
    [ drop update-selected-value ]
    [ show-row-summary ]
    2tri ;

: prev/next-row ( table n -- )
    [ dup selected-index>> ] dip '[ _ + ] [ 0 ] if* select-row ;
    
: prev-row ( table -- )
    -1 prev/next-row ;

: next-row ( table -- )
    1 prev/next-row ;

: first-row ( table -- )
    0 select-row ;

: last-row ( table -- )
    dup control-value length 1- select-row ;

: hide-mouse-help ( table -- )
    f >>mouse-index [ hide-status ] [ relayout-1 ] bi ;

: valid-row? ( row table -- ? )
    control-value length 1- 0 swap between? ;

: if-mouse-row ( table true false -- )
    [ [ mouse-row ] keep 2dup valid-row? ]
    [ ] [ '[ nip @ ] ] tri* if ; inline

: show-mouse-help ( table -- )
    [
        swap
        [ >>mouse-index relayout-1 ]
        [ show-row-summary ]
        2bi
    ] [ hide-mouse-help ] if-mouse-row ;

: show-table-menu ( table -- )
    [
        [ nip ]
        [ [ nth-row drop ] [ renderer>> row-value ] [ hook>> ] tri ] 2bi
        show-operations-menu
    ] [ drop ] if-mouse-row ;

table H{
    { mouse-enter [ show-mouse-help ] }
    { mouse-leave [ hide-mouse-help ] }
    { motion [ show-mouse-help ] }
    { T{ button-down } [ table-button-down ] }
    { T{ button-down f f 3 } [ show-table-menu ] }
    { T{ button-up } [ table-button-up ] }
    { gain-focus [ t >>focused? drop ] }
    { lose-focus [ f >>focused? drop ] }
    { T{ drag } [ table-button-down ] }
    { T{ key-down f f "RET" } [ row-action ] }
    { T{ key-down f f "UP" } [ prev-row ] }
    { T{ key-down f f "DOWN" } [ next-row ] }
    { T{ key-down f f "HOME" } [ first-row ] }
    { T{ key-down f f "END" } [ last-row ] }
} set-gestures

PRIVATE>