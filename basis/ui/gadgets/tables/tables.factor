! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors fry io.styles kernel locals math
math.geometry.rect math.order math.vectors namespaces opengl
sequences ui.gadgets ui.gadgets.scrollers ui.gadgets.status-bar
ui.gadgets.worlds ui.gestures ui.render models math.ranges sequences
combinators ;
IN: ui.gadgets.tables

! Row rendererer protocol
GENERIC: row-columns ( row renderer -- columns )

SINGLETON: trivial-renderer

M: trivial-renderer row-columns drop ;

TUPLE: table < gadget
    renderer column-widths total-width
    font text-color selection-color mouse-color
    selected-index selected-value
    mouse-index
    focused? ;

: <table> ( rows -- table )
    table new-gadget
        swap >>model
        trivial-renderer >>renderer
        f <model> >>selected-value
        { "sans-serif" plain 12 } >>font
        T{ rgba f 0.8 0.8 1.0 1.0 } >>selection-color
        black >>mouse-color
        black >>text-color ;

: line-height ( table -- n )
    font>> open-font "" string-height ;

CONSTANT: table-gap 5

: table-rows ( table -- rows )
    [ control-value ] [ renderer>> ] bi '[ _ row-columns ] map ;

: column-widths ( font rows -- total widths )
    [ drop 0 { } ] [
        tuck [ length 0 <repetition> ] 2dip [
            [ string-width ] with map vmax
        ] with each
        0 [ table-gap + + ] accumulate
        [ table-gap - ] dip
    ] if-empty ;

: update-cached-widths ( table -- )
    dup
    [ font>> open-font ] [ table-rows ] bi column-widths
    [ >>total-width ] [ >>column-widths ] bi* drop ;

M: table layout* update-cached-widths ;

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

: first-visible-row ( table -- n )
    [
        [ clip get loc>> second origin get second - ] dip
        y>row
    ] keep validate-row ;

: last-visible-row ( table -- n )
    [
        [ clip get rect-extent nip second origin get second - ] dip
        y>row
    ] keep validate-row 1+ ;

: draw-row ( widths columns font -- )
    '[ [ _ ] [ 0 2array ] [ ] tri* swap draw-string ] 2each ;

: each-slice-index ( from to seq quot -- )
    [ [ <slice> ] [ drop [a,b) ] 3bi ] dip 2each ; inline

:: draw-rows ( table -- )
    table font>> :> font
    table line-height :> line-height
    table text-color>> gl-color
    table
    [ first-visible-row ]
    [ last-visible-row ]
    [ control-value ] tri [
        line-height * 0 swap 2array [
            table column-widths>>
            swap
            table renderer>> row-columns
            font draw-row
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
    dup update-cached-widths
    [ total-width>> ] [
        [ font>> open-font "" string-height ]
        [ control-value length ]
        bi *
    ] bi 2array ;

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

: click-row ( table -- )
    dup request-focus
    dup control-value empty?
    [ drop ] [ dup mouse-row (select-row) ] if ;

: select-row ( table row -- )
    [ (select-row) ] [ drop update-selected-value ] 2bi ;

: prev-row ( table -- )
    dup selected-index>> 1- select-row ;

: next-row ( table -- )
    dup selected-index>> 1+ select-row ;

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
    { T{ button-down } [ click-row ] }
    { T{ button-up } [ update-selected-value ] }
    { T{ gain-focus } [ t >>focused? drop ] }
    { T{ lose-focus } [ f >>focused? drop ] }
    { T{ drag } [ click-row ] }
    { T{ key-down f f "UP" } [ prev-row ] }
    { T{ key-down f f "DOWN" } [ next-row ] }
    { T{ key-down f f "HOME" } [ first-row ] }
    { T{ key-down f f "END" } [ last-row ] }
} set-gestures
