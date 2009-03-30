! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors colors.constants fry kernel math
math.functions math.rectangles math.order math.vectors namespaces
opengl sequences ui.gadgets ui.gadgets.scrollers ui.gadgets.status-bar
ui.gadgets.worlds ui.gestures ui.render ui.pens.solid ui.text
ui.commands ui.images ui.gadgets.menus ui.gadgets.line-support
math.rectangles models math.ranges sequences combinators fonts locals
strings ;
IN: ui.gadgets.tables

! Row rendererer protocol
GENERIC: prototype-row ( renderer -- columns )
GENERIC: column-alignment ( renderer -- alignment )
GENERIC: filled-column ( renderer -- n )
GENERIC: column-titles ( renderer -- strings )

GENERIC: row-columns ( row renderer -- columns )
GENERIC: row-value ( row renderer -- object )
GENERIC: row-color ( row renderer -- color )

SINGLETON: trivial-renderer

M: object prototype-row drop { "" } ;
M: object column-alignment drop f ;
M: object filled-column drop f ;
M: object column-titles drop f ;

M: trivial-renderer row-columns drop ;
M: object row-value drop ;
M: object row-color 2drop f ;

TUPLE: table < line-gadget
{ renderer initial: trivial-renderer }
{ action initial: [ drop ] }
single-click?
{ hook initial: [ drop ] }
{ gap initial: 2 }
column-widths total-width
focus-border-color
{ mouse-color initial: COLOR: black }
column-line-color
selection-required?
selected-index selected-value
mouse-index
{ takes-focus? initial: t }
focused? ;

: <table> ( rows renderer -- table )
    table new-line-gadget
        swap >>renderer
        swap >>model
        f <model> >>selected-value
        sans-serif-font >>font
        focus-border-color >>focus-border-color
        transparent >>column-line-color ;

<PRIVATE

GENERIC: cell-width ( font cell -- x )
GENERIC: cell-height ( font cell -- y )
GENERIC: draw-cell ( font cell -- )

M: string cell-width text-width ;
M: string cell-height text-height ceiling ;
M: string draw-cell draw-text ;

M: image-name cell-width nip image-dim first ;
M: image-name cell-height nip image-dim second ;
M: image-name draw-cell nip draw-image ;

: table-rows ( table -- rows )
    [ control-value ] [ renderer>> ] bi '[ _ row-columns ] map ;

: column-offsets ( widths gap -- x xs )
    [ 0 ] dip '[ _ + + ] accumulate ;

CONSTANT: column-title-background COLOR: light-gray

: column-title-font ( font -- font' )
    column-title-background font-with-background t >>bold? ;

: initial-widths ( table rows -- widths )
    over renderer>> column-titles dup
    [ [ drop font>> ] dip [ text-width ] with map ]
    [ drop nip first length 0 <repetition> ]
    if ;

: row-column-widths ( table row -- widths )
    [ font>> ] dip [ cell-width ] with map ;

: compute-total-width ( gap widths -- total )
    swap [ column-offsets drop ] keep - ;

: compute-column-widths ( table -- total widths )
    dup table-rows [ drop 0 { } ] [
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
    [ [ line-height ] dip * 0 swap 2array ]
    [ drop [ dim>> first ] [ line-height ] bi 2array ] 2bi <rect> ;

: row-bounds ( table row -- loc dim )
    row-rect rect-bounds ; inline

: draw-selected-row ( table -- )
    {
        { [ dup selected-index>> not ] [ drop ] }
        [
            [ ] [ selected-index>> ] [ selection-color>> gl-color ] tri
            row-bounds gl-fill-rect
        ]
    } cond ;

: draw-focused-row ( table -- )
    {
        { [ dup focused?>> not ] [ drop ] }
        { [ dup selected-index>> not ] [ drop ] }
        [
            [ ] [ selected-index>> ] [ focus-border-color>> gl-color ] tri
            row-bounds gl-rect
        ]
    } cond ;

: draw-moused-row ( table -- )
    dup mouse-index>> dup [
        over mouse-color>> gl-color
        row-bounds gl-rect
    ] [ 2drop ] if ;

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

: column-loc ( font column width align -- loc )
    [ [ cell-width ] dip swap - ] dip
    * >integer 0 2array ;

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
    dup renderer>> column-alignment
    [ ] [ column-widths>> length 0 <repetition> ] ?if ;

:: row-font ( row index table -- font )
    table font>> clone
    row table renderer>> row-color [ >>foreground ] when*
    index table selected-index>> = [ table selection-color>> >>background ] when ;

: draw-columns ( columns widths alignment font gap -- )
    '[ [ _ ] 3dip _ draw-column ] 3each ;

M: table draw-line ( row index table -- )
    [
        nip
        [ renderer>> row-columns ]
        [ column-widths>> ]
        [ table-column-alignment ]
        tri
    ]
    [ row-font ]
    [ 2nip gap>> ] 3tri
    draw-columns ;

M: table draw-gadget*
    dup control-value empty? [ drop ] [
        {
            [ draw-selected-row ]
            [ draw-lines ]
            [ draw-column-lines ]
            [ draw-focused-row ]
            [ draw-moused-row ]
        } cleave
    ] if ;

M: table line-height ( table -- y )
    [ font>> ] [ renderer>> prototype-row ] bi
    [ cell-height ] with [ max ] map-reduce ;

M: table pref-dim*
    [ compute-column-widths drop ] keep
    [ line-height ] [ control-value length ] bi * 2array ;

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

: hide-mouse-help ( table -- )
    f >>mouse-index [ hide-status ] [ relayout-1 ] bi ;

M: table model-changed
    [ nip ] [ initial-selected-index ] 2bi {
        [ >>selected-index f >>mouse-index drop ]
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
    [ hand-rel second ] keep y>line ;

: table-button-down ( table -- )
    dup takes-focus?>> [ dup request-focus ] when
    dup control-value empty? [ drop ] [
        dup [ mouse-row ] keep validate-line
        [ >>mouse-index ] [ (select-row) ] bi
    ] if ;

PRIVATE>

: row-action ( table -- )
    dup selected-row
    [ swap [ action>> call( value -- ) ] [ dup hook>> call( table -- ) ] bi ]
    [ 2drop ]
    if ;

<PRIVATE

: table-button-up ( table -- )
    dup single-click?>> hand-click# get 2 = or
    [ row-action ] [ update-selected-value ] if ;

: select-row ( table n -- )
    over validate-line
    [ (select-row) ]
    [ drop update-selected-value ]
    [ show-row-summary ]
    2tri ;

: prev/next-row ( table n -- )
    [ dup selected-index>> ] dip '[ _ + ] [ 0 ] if* select-row ;
    
: previous-row ( table -- )
    -1 prev/next-row ;

: next-row ( table -- )
    1 prev/next-row ;

: first-row ( table -- )
    0 select-row ;

: last-row ( table -- )
    dup control-value length 1- select-row ;

: prev/next-page ( table n -- )
    over visible-lines 1- * prev/next-row ;

: previous-page ( table -- )
    -1 prev/next-page ;

: next-page ( table -- )
    1 prev/next-page ;

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
        [ swap select-row ]
        [
            [ nth-row drop ]
            [ renderer>> row-value ]
            [ dup hook>> curry ]
            tri
        ] 2tri
        show-operations-menu
    ] [ drop ] if-mouse-row ;

: focus-table ( table -- ) t >>focused? drop ;

: unfocus-table ( table -- ) f >>focused? drop ;

table "sundry" f {
    { mouse-enter show-mouse-help }
    { mouse-leave hide-mouse-help }
    { motion show-mouse-help }
    { T{ button-down } table-button-down }
    { T{ button-up } table-button-up }
    { gain-focus focus-table }
    { lose-focus unfocus-table }
    { T{ drag } table-button-down }
} define-command-map

table "row" f {
    { T{ button-down f f 3 } show-table-menu }
    { T{ key-down f f "RET" } row-action }
    { T{ key-down f f "UP" } previous-row }
    { T{ key-down f f "DOWN" } next-row }
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
    {
        [ renderer>> column-titles ]
        [ column-widths>> ]
        [ table-column-alignment ]
        [ font>> column-title-font ]
        [ gap>> ]
    } cleave
    draw-columns ;

M: column-headers draw-gadget*
    table>> draw-column-titles ;

M: column-headers pref-dim*
    table>> [ pref-dim first ] [ font>> "" text-height ] bi 2array ;

M: table viewport-column-header
    dup renderer>> column-titles
    [ <column-headers> ] [ drop f ] if ;

PRIVATE>