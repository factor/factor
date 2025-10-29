! Copyright (C) 2008, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors combinators
combinators.short-circuit fonts kernel math math.functions
math.order math.rectangles math.vectors models namespaces opengl
sequences splitting strings ui.commands ui.gadgets
ui.gadgets.line-support ui.gadgets.menus ui.gadgets.scrollers
ui.gadgets.status-bar ui.gadgets.worlds ui.gestures ui.images
ui.pens.solid ui.render ui.text ui.theme ;
IN: ui.gadgets.tables

! Row renderer protocol
GENERIC: prototype-row ( renderer -- columns )
GENERIC: column-alignment ( renderer -- alignment )
GENERIC: filled-column ( renderer -- n )
GENERIC: column-titles ( renderer -- strings )

GENERIC: row-columns ( row renderer -- columns )
GENERIC: row-value ( row renderer -- object )
GENERIC: row-summary ( row renderer -- object )
GENERIC: row-color ( row renderer -- color )
GENERIC: row-value? ( value row renderer -- ? )

SINGLETON: trivial-renderer

M: object prototype-row drop { "" } ;
M: object column-alignment drop f ;
M: object filled-column drop f ;
M: object column-titles drop f ;

M: trivial-renderer row-columns drop ;
M: object row-value drop ;
M: object row-summary row-value ;
M: object row-color 2drop f ;
M: object row-value? drop eq? ;

TUPLE: table < line-gadget
{ renderer initial: trivial-renderer }
{ action initial: [ drop ] }
single-click?
{ hook initial: [ drop ] }
{ gap initial: 2 }
column-widths total-width
focus-border-color
mouse-color
column-line-color
selection-required?
selection-index
selection
mouse-index
{ takes-focus? initial: t }
focused?
rows ;

: new-table ( rows renderer class -- table )
    new-line-gadget
        swap >>renderer
        swap >>model
        sans-serif-font >>font
        focus-border-color >>focus-border-color
        transparent >>column-line-color
        f <model> >>selection-index
        f <model> >>selection ;

: <table> ( rows renderer -- table ) table new-table ;

<PRIVATE

GENERIC: cell-dim ( font cell -- width height padding )
GENERIC: draw-cell ( font cell -- )

M: f cell-dim 2drop 0 0 0 ;
M: f draw-cell 2drop ;

: single-line ( str -- str' )
    dup [ "\r\n" member? ] any? [ split-lines join-words ] when ;

M: string cell-dim single-line text-dim first2 ceiling 0 ;
M: string draw-cell single-line draw-text ;

CONSTANT: image-padding 2

M: image-name cell-dim nip image-dim first2 image-padding ;
M: image-name draw-cell nip draw-image ;

: column-offsets ( widths gap -- x xs )
    [ 0 ] dip '[ _ + + ] accumulate ;

: column-title-font ( font -- font' )
    column-title-background font-with-background t >>bold? ;

: initial-widths ( table rows -- widths )
    over renderer>> column-titles dup
    [ [ drop font>> ] dip [ text-width ] with map ]
    [ drop nip first length 0 <repetition> ]
    if ;

: row-column-widths ( table row -- widths )
    [ font>> ] dip [ cell-dim nip + ] with map ;

: compute-total-width ( gap widths -- total )
    swap [ column-offsets drop ] keep - ;

GENERIC: compute-column-widths ( table -- total widths )

M: table compute-column-widths
    dup rows>> [ drop 0 { } ] [
        [ drop gap>> ] [ initial-widths ] [ ] 2tri
        [ row-column-widths vmax ] with each
        [ compute-total-width ] keep
    ] if-empty ;

: update-cached-widths ( table -- )
    dup compute-column-widths
    [ >>total-width ] [ >>column-widths ] bi*
    drop ;

: filled-column-width ( table -- n )
    [ dim>> first ] [ total-width>> ] bi [-] ;

: update-filled-column ( table -- )
    [ filled-column-width ]
    [ renderer>> filled-column ]
    [ column-widths>> ] tri
    2dup empty? not and
    [ [ + ] change-nth ] [ 3drop ] if ;

M: table layout*
    [ update-cached-widths ] [ update-filled-column ] bi ;

: row-rect ( table row -- rect )
    [ [ line-height ] dip * gl-round 0 swap 2array ]
    [ drop [ dim>> first ] [ line-height ] bi 2array ] 2bi <rect> ;

: row-bounds ( table row -- loc dim )
    row-rect rect-bounds ; inline

: draw-selected-row ( table -- )
    dup selection-index>> value>> [
        dup selection-color>> gl-color
        dup selection-index>> value>> row-bounds gl-fill-rect
    ] [ drop ] if ;

: draw-focused-row ( table -- )
    dup { [ focused?>> ] [ selection-index>> value>> ] } 1&& [
        dup focus-border-color>> gl-color
        dup selection-index>> value>> row-bounds gl-rect
    ] [ drop ] if ;

: draw-moused-row ( table -- )
    dup mouse-index>> [
        dup mouse-color>> [ text-color ] unless* gl-color
        dup mouse-index>> row-bounds gl-rect
    ] [ drop ] if ;

: column-line-offsets ( table -- xs )
    [ column-widths>> ] [ gap>> ] bi
    [ column-offsets nip [ f ] ]
    [ 2/ '[ rest-slice [ _ - ] map ] ]
    bi if-empty ;

: draw-column-lines ( table -- )
    [ column-line-color>> gl-color ]
    [
        [ column-line-offsets ] [ dim>> second ] bi
        '[ [ 0 2array ] [ _ 2array ] bi gl-line ] each
    ] bi ;

:: column-loc ( font column width align -- loc )
    font column cell-dim :> ( cell-width cell-height cell-padding )
    cell-width width swap - align *
    cell-padding 2 / 1 align - * +
    cell-height \ line-height get swap - 2 /
    [ >integer ] bi@ 2array ;

: translate-column ( width gap -- )
    + 0 2array gl-translate ;

: draw-column ( font column width align gap -- )
    [
        over [
            [ 2dup ] 2dip column-loc
            [ draw-cell ] with-translation
        ] dip
    ] dip translate-column ;

: table-column-alignment ( table -- seq )
    [ renderer>> column-alignment ]
    [ column-widths>> length 0 <repetition> ] ?unless ;

:: row-font ( row index table -- font )
    table font>> clone
    row table renderer>> row-color [ >>foreground ] when*
    index table selection-index>> value>> =
    [ table selection-color>> >>background ] when ;

: draw-columns ( columns widths alignment font gap -- )
    '[ [ _ ] 3dip _ draw-column ] 3each ;

M:: table draw-line ( row index table -- )
    row table renderer>> row-columns
    table column-widths>>
    table table-column-alignment
    row index table row-font
    table gap>>
    draw-columns ;

M: table draw-gadget*
    dup control-value empty? [ drop ] [
        dup line-height \ line-height [
            {
                [ draw-selected-row ]
                [ draw-lines ]
                [ draw-column-lines ]
                [ draw-focused-row ]
                [ draw-moused-row ]
            } cleave
        ] with-variable
    ] if ;

M: table line-height*
    [ font>> ] [ renderer>> prototype-row ] bi
    [ cell-dim + nip ] with [ max ] map-reduce ;

M: table pref-dim*
    [ compute-column-widths drop ] keep
    [ line-height ] [ control-value length ] bi * 2array ;

: nth-row ( index table -- value/f ? )
    over [ control-value nth t ] [ 2drop f f ] if ;

PRIVATE>

: (selected-row) ( table -- value/f ? )
    [ selection-index>> value>> ] keep nth-row ;

: selected-row ( table -- value/f ? )
    [ (selected-row) ] [ renderer>> ] bi
    swap [ row-value t ] [ 2drop f f ] if ;

<PRIVATE

: show-row-summary ( table n -- )
    over nth-row
    [ swap [ renderer>> row-summary ] keep show-summary ]
    [ drop hide-status ]
    if ;

: update-status ( table -- )
    dup mouse-index>>
    [ dup selection-index>> value>> ] unless*
    show-row-summary ;

: hide-mouse-help ( table -- )
    f >>mouse-index [ update-status ] [ relayout-1 ] bi ;

: select-table-row ( n table -- )
    [ selection-index>> set-model ]
    [ [ selected-row drop ] keep selection>> set-model ]
    bi ;

: update-mouse-index ( table -- )
    dup [ control-value ] [ mouse-index>> ] bi
    dup [ swap length [ drop f ] [ 1 - min ] if-zero ] [ 2drop f ] if
    >>mouse-index drop ;

: initial-selection-index ( table -- n/f )
    {
        [ control-value empty? not ]
        [ selection-required?>> ]
        [ drop 0 ]
    } 1&& ;

: find-row-index ( value table -- n/f )
    [ control-value ] [ renderer>> ] bi
    '[ _ row-value? ] with find drop ;

: update-table-rows ( table -- )
    [
        [ control-value ] [ renderer>> ] bi
        '[ _ row-columns ] map
    ]
    [ rows<< ] bi ; inline

: update-selection ( table -- )
    [
        {
            [ [ selection>> value>> ] keep find-row-index ]
            [ initial-selection-index ]
        } 1||
    ] keep
    over [ select-table-row ] [
        [ selection-index>> set-model ]
        [ selection>> set-model ]
        2bi
    ] if ;

M: table model-changed
    nip
        dup update-table-rows
        dup update-selection
        dup update-mouse-index
    [ update-status ] [ relayout ] bi ;

: thin-row-rect ( table row -- rect )
    row-rect [ { 0 1 } v* ] change-dim ;

: scroll-to-row ( table n -- )
    [ [ thin-row-rect ] keepd scroll>rect ] [ drop ] if* ;

: (select-row) ( table n -- )
    [ scroll-to-row ]
    [ swap select-table-row ]
    [ drop relayout-1 ]
    2tri ;

: mouse-row ( table -- n )
    [ hand-rel second ] keep y>line ;

: if-mouse-row ( table true: ( mouse-index table -- ) false: ( table -- ) -- )
    [ [ mouse-row ] keep 2dup valid-line? ]
    [ ] [ '[ nip @ ] ] tri* if ; inline

: table-button-down ( table -- )
    dup takes-focus?>> [ dup request-focus ] when
    [ swap [ >>mouse-index ] [ (select-row) ] bi ] [ drop ] if-mouse-row ; inline

PRIVATE>

: row-action ( table -- )
    dup selected-row [
        over action>> call( value -- )
    ] [ drop ] if dup hook>> call( table -- ) ;

: row-action? ( table -- ? )
    single-click?>> hand-click# get 2 = or ;

<PRIVATE

: table-button-up ( table -- )
    dup [ mouse-row ] keep valid-line? [
        dup row-action? [ row-action ] [ drop ] if
    ] [ drop ] if ;

PRIVATE>

: select-row ( table n -- )
    over validate-line
    [ (select-row) ] [ show-row-summary ] 2bi ;

<PRIVATE

: prev/next-row ( table n -- )
    [ dup selection-index>> value>> ] dip
    '[ _ + ] [ 0 ] if* select-row ;

: previous-row ( table -- )
    -1 prev/next-row ;

: next-row ( table -- )
    1 prev/next-row ;

: first-row ( table -- )
    0 select-row ;

: last-row ( table -- )
    dup control-value length 1 - select-row ;

: prev/next-page ( table n -- )
    over visible-lines 1 - * prev/next-row ;

: previous-page ( table -- )
    -1 prev/next-page ;

: next-page ( table -- )
    1 prev/next-page ;

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
        [ swap select-row ]
        [
            [ nth-row drop ]
            [ renderer>> row-value ]
            [ dup hook>> curry ]
            tri
        ] 2tri
        show-operations-menu
    ] [ drop ] if-mouse-row ;

: focus-table ( table -- ) t >>focused? relayout-1 ;

: unfocus-table ( table -- ) f >>focused? relayout-1 ;

table "sundry" f {
    { mouse-enter show-mouse-help }
    { mouse-leave hide-mouse-help }
    { motion show-mouse-help }
    { T{ button-up } table-button-up }
    { T{ button-up f { S+ } } table-button-up }
    { T{ button-down } table-button-down }
    { gain-focus focus-table }
    { lose-focus unfocus-table }
    { T{ drag } table-button-down }
} define-command-map

table "row" f {
    { T{ button-down f f 3 } show-table-menu }
    { T{ key-down f f "RET" } row-action }
    { T{ key-down f f "UP" } previous-row }
    { T{ key-down f { C+ } "p" } previous-row }
    { T{ key-down f f "DOWN" } next-row }
    { T{ key-down f { C+ } "n" } next-row }
    { T{ key-down f f "HOME" } first-row }
    { T{ key-down f f "END" } last-row }
    { T{ key-down f f "PAGE_UP" } previous-page }
    { T{ key-down f f "PAGE_DOWN" } next-page }
} define-command-map

TUPLE: column-headers < gadget table ;

: <column-headers> ( table -- gadget )
    column-headers new
        swap >>table
        column-title-background <solid> >>interior ;

: draw-column-titles ( table -- )
    dup font>> font-metrics height>> \ line-height [
        {
            [ renderer>> column-titles ]
            [ column-widths>> ]
            [ table-column-alignment ]
            [ font>> column-title-font ]
            [ gap>> ]
        } cleave
        draw-columns
    ] with-variable ;

M: column-headers draw-gadget*
    table>> draw-column-titles ;

M: column-headers pref-dim*
    table>> [ pref-dim first ] [ font>> "" text-height ] bi 2array ;

M: table viewport-column-header
    dup renderer>> column-titles
    [ <column-headers> ] [ drop f ] if ;

PRIVATE>
