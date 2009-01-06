! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors fry io.styles kernel math
math.geometry.rect math.order math.vectors namespaces opengl
sequences ui.gadgets ui.gadgets.scrollers ui.gadgets.status-bar
ui.gadgets.worlds ui.gadgets.theme ui.gestures ui.render models
math.ranges sequences combinators ;
IN: ui.gadgets.tables

! Row rendererer protocol
GENERIC: row-columns ( row renderer -- columns )

SINGLETON: trivial-renderer

M: trivial-renderer row-columns drop ;

TUPLE: table < gadget
renderer filled-column column-alignment action
column-widths total-width
font text-color selection-color mouse-color
selected-index selected-value
mouse-index
focused? ;

: <table> ( rows -- table )
    table new-gadget
        swap >>model
        trivial-renderer >>renderer
        [ drop ] >>action
        f <model> >>selected-value
        sans-serif-font >>font
        selection-color >>selection-color
        black >>mouse-color
        black >>text-color ;

<PRIVATE

: line-height ( table -- n )
    font>> open-font "" string-height ;

CONSTANT: table-gap 5

: table-rows ( table -- rows )
    [ control-value ] [ renderer>> ] bi '[ _ row-columns ] map ;

: column-offsets ( table -- xs )
    0 [ table-gap + + ] accumulate nip ;

: (compute-column-widths) ( font rows -- total widths )
    [ drop 0 { } ] [
        tuck [ first length 0 <repetition> ] 2dip
        [ [ string-width ] with map vmax ] with each
        [ [ sum ] [ length 1 [-] table-gap * ] bi + ] keep
    ] if-empty ;

: compute-column-widths ( table -- total-width column-widths )
    [ font>> open-font ] [ table-rows ] bi (compute-column-widths) ;

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

: highlight-row ( table row color filled? -- )
    [ dup ] 2dip '[
        _ gl-color
        row-rect rect-bounds swap [
            _ [ gl-fill-rect ] [ gl-rect ] if
        ] with-translation
    ] [ 2drop ] if ;

: draw-selected ( table -- )
    {
        [ ]
        [ selected-index>> ]
        [ selection-color>> ]
        [ focused?>> ]
    } cleave
    highlight-row ;

: draw-moused ( table -- )
    [ ] [ mouse-index>> ] [ mouse-color>> ] tri f highlight-row ;

: y>row ( y table -- n )
    line-height /i ;

: validate-row ( m table -- n )
    control-value length 1- min 0 max ;

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
    [ [ [ open-font ] dip string-width ] dip swap - ] dip
    * 0 2array ;

: draw-column ( font column width align -- )
    over [
        [ 2dup ] 2dip column-loc draw-string
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
            [ draw-selected ]
            [ draw-moused ]
            [ draw-rows ]
            tri
        ] with-translation
    ] if ;

M: table pref-dim*
    [ compute-column-widths drop ] keep
    [ font>> open-font "" string-height ]
    [ control-value length ]
    bi * 2array ;

: nth-row ( row table -- value/f )
    over [ control-value nth ] [ 2drop f ] if ;

: selected-row ( table -- value/f )
    [ selected-index>> ] keep nth-row ;

: update-selected-value ( table -- )
    [ selected-row ] keep selected-value>> set-model ;

M: table model-changed
    nip
    [ f >>selected-index update-selected-value ]
    [ relayout ]
    bi ;

: thin-row-rect ( table row -- rect )
    row-rect [ { 0 1 } v* ] change-dim ;

: (select-row) ( table row -- )
    over validate-row
    [ [ thin-row-rect ] [ drop ] 2bi scroll>rect ]
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

: row-action ( table -- )
    dup selected-row dup
    [ swap action>> call ] [ 2drop ] if ;

: table-button-up ( table -- )
    hand-click# get 2 =
    [ row-action ] [ update-selected-value ] if ;

: select-row ( table row -- )
    [ (select-row) ] [ drop update-selected-value ] 2bi ;

: prev-row ( table -- )
    dup selected-index>> [ 1- ] [ 0 ] if* select-row ;

: next-row ( table -- )
    dup selected-index>> [ 1+ ] [ 0 ] if* select-row ;

: first-row ( table -- )
    0 select-row ;

: last-row ( table -- )
    dup control-value length 1- select-row ;

: hide-mouse-help ( table -- )
    f >>mouse-index [ hide-status ] [ relayout-1 ] bi ;

: show-mouse-help ( table -- )
    [ mouse-row ] keep
    2dup control-value length 1- 0 swap between? [
        [ swap >>mouse-index relayout-1 ]
        [
            [ nth-row ] keep
            over [ show-summary ] [ 2drop ] if
        ] 2bi
    ] [ nip hide-mouse-help ] if ;

table H{
    { T{ mouse-enter } [ show-mouse-help ] }
    { T{ mouse-leave } [ hide-mouse-help ] }
    { T{ motion } [ show-mouse-help ] }
    { T{ button-down } [ table-button-down ] }
    { T{ button-up } [ table-button-up ] }
    { T{ gain-focus } [ t >>focused? drop ] }
    { T{ lose-focus } [ f >>focused? drop ] }
    { T{ drag } [ table-button-down ] }
    { T{ key-down f f "ENTER" } [ row-action ] }
    { T{ key-down f f "UP" } [ prev-row ] }
    { T{ key-down f f "DOWN" } [ next-row ] }
    { T{ key-down f f "HOME" } [ first-row ] }
    { T{ key-down f f "END" } [ last-row ] }
} set-gestures

PRIVATE>