! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors colors.constants fry kernel math
math.functions math.ranges math.rectangles math.order math.vectors models.arrow
namespaces opengl sequences ui.gadgets ui.gadgets.scrollers
ui.gadgets.status-bar ui.gadgets.worlds ui.gestures ui.render ui.pens.solid
ui.text ui.commands ui.images ui.gadgets.menus ui.gadgets.line-support
math.rectangles models math.ranges sequences combinators
combinators.short-circuit fonts locals strings vectors tools.annotations ;
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
selected-indices selected-values
mouse-index
{ takes-focus? initial: t }
focused?
multiple-selection? ;

IN: accessors
GENERIC: selected-value>> ( table -- n )
GENERIC: selected-index>> ( table -- n )
GENERIC: (>>selected-index) ( n table -- )
GENERIC: (>>selected-value) ( val table -- )
: >>selected-index ( table n -- table ) over (>>selected-index) ;
: >>selected-value ( table val -- table ) over (>>selected-value) ;

M: table selected-value>> selected-values>> [ [ f ] [ peek ] if-empty ] <arrow> ;
M: table (>>selected-value) [ [ 1vector ] <arrow> ] dip (>>selected-values) ;
M: table selected-index>> selected-indices>> [ f ] [ peek ] if-empty ;
M: table (>>selected-index) [ 1vector ] dip (>>selected-indices) ;

IN: ui.gadgets.tables
: push-selected-index ( table n -- table ) 2dup swap selected-indices>> index [ drop ] [ over selected-indices>> push ] if ;

: new-table ( rows renderer class -- table )
    new-line-gadget
        swap >>renderer
        swap >>model
        V{ } clone <model> >>selected-values
        sans-serif-font >>font
        focus-border-color >>focus-border-color
        transparent >>column-line-color ; inline

: <table> ( rows renderer -- table ) table new-table ;

<PRIVATE

GENERIC: cell-width ( font cell -- x )
GENERIC: cell-height ( font cell -- y )
GENERIC: cell-padding ( cell -- y )
GENERIC: draw-cell ( font cell -- )

M: string cell-width text-width ;
M: string cell-height text-height ceiling ;
M: string cell-padding drop 0 ;
M: string draw-cell draw-text ;

CONSTANT: image-padding 2

M: image-name cell-width nip image-dim first ;
M: image-name cell-height nip image-dim second ;
M: image-name cell-padding drop image-padding ;
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
    [ font>> ] dip [ [ cell-width ] [ cell-padding ] bi + ] with map ;

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

: draw-selected-rows ( table -- )
    {
        { [ dup selected-indices>> empty? ] [ drop ] }
        [
            [ selected-indices>> ] [ selection-color>> gl-color ] [ ] tri
            [ swap row-bounds gl-fill-rect ] curry each
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

:: column-loc ( font column width align -- loc )
    font column cell-width width swap - align * column cell-padding 2 / 1 align - * +
    font column cell-height \ line-height get swap - 2 /
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
    dup renderer>> column-alignment
    [ ] [ column-widths>> length 0 <repetition> ] ?if ;

:: row-font ( row ind table -- font )
    table font>> clone
    row table renderer>> row-color [ >>foreground ] when*
    ind table selected-indices>> index [ table selection-color>> >>background ] when ;

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
        dup line-height \ line-height [
            {
                [ draw-selected-rows ]
                [ draw-lines ]
                [ draw-column-lines ]
                [ draw-focused-row ]
                [ draw-moused-row ]
            } cleave
        ] with-variable
    ] if ;

M: table line-height ( table -- y )
    [ font>> ] [ renderer>> prototype-row ] bi
    [ [ cell-height ] [ cell-padding ] bi + ] with
    [ max ] map-reduce ;

M: table pref-dim*
    [ compute-column-widths drop ] keep
    [ line-height ] [ control-value length ] bi * 2array ;

: nth-row ( row table -- value/f ? )
    over [ control-value nth t ] [ 2drop f f ] if ;

PRIVATE>

: (selected-rows) ( table -- {row} )
    [ selected-indices>> ] keep
    [ nth-row [ 1array ] [ drop { } ] if ] curry map concat ;

: selected-rows ( table -- {value} )
    [ (selected-rows) ] [ renderer>> ] bi [ row-value ] curry map ;

: multiple>single ( values -- value/f ? ) [ f f ] [ peek t ] if-empty ;
: (selected-row) ( table -- value/f ? ) (selected-rows) multiple>single ;
: selected-row ( table -- value/f ? ) selected-rows multiple>single ;

<PRIVATE

: update-selected-values ( table -- )
    [ selected-rows ] [ selected-values>> ] bi set-model ;

: show-row-summary ( table n -- )
    over nth-row
    [ swap [ renderer>> row-value ] keep show-summary ]
    [ 2drop ]
    if ;

: hide-mouse-help ( table -- )
    f >>mouse-index [ hide-status ] [ relayout-1 ] bi ;

: find-row-index ( value table -- n/f )
    [ model>> value>> ] [ renderer>> '[ _ row-value ] map index ] bi ;

: initial-selected-indices ( table -- {n}/f )
    {
        [ model>> value>> empty? not ]
        [ selection-required?>> ]
        [ drop V{ 0 } clone ]
    } 1&& ;

: (update-selected-indices) ( table -- {n}/f )
    [ selected-values>> value>> ] keep
    [ find-row-index ] curry map [ ] filter [ f ] when-empty ;

: update-selected-indices ( table -- {n}/f )
    {
        [ (update-selected-indices) ]
        [ initial-selected-indices ]
    } 1|| ;

M: table model-changed
    nip dup update-selected-indices [ V{ } clone ] unless* {
        [ >>selected-indices f >>mouse-index drop ]
        [ [ f ] [ peek ] if-empty show-row-summary ]
        [ drop update-selected-values ]
        [ drop relayout ]
    } 2cleave ;

: thin-row-rect ( table row -- rect )
    row-rect [ { 0 1 } v* ] change-dim ;

: scroll-to-row ( table n -- )
    dup [ [ thin-row-rect ] [ drop ] 2bi scroll>rect ] [ 2drop ] if ;

: add-selected-row ( table n -- )
    [ scroll-to-row ]
    [ push-selected-index relayout-1 ] 2bi ;

: (select-row) ( table n -- )
    [ scroll-to-row ]
    [ >>selected-index relayout-1 ]
    2bi ;

: mouse-row ( table -- n )
    [ hand-rel second ] keep y>line ;

: if-mouse-row ( table true: ( mouse-index table -- ) false: ( table -- ) -- )
    [ [ mouse-row ] keep 2dup valid-line? ]
    [ ] [ '[ nip @ ] ] tri* if ; inline

: (table-button-down) ( quot table -- )
    dup takes-focus?>> [ dup request-focus ] when swap
   '[ swap [ >>mouse-index ] _ bi ] [ drop ] if-mouse-row ; inline

: table-button-down ( table -- ) [ (select-row) ] swap (table-button-down) ;
: continued-button-down ( table -- ) dup multiple-selection?>> [ [ add-selected-row ] swap (table-button-down) ] [ table-button-down ] if ;
: thru-button-down ( table -- ) dup multiple-selection?>> [
    [ 2dup over selected-index>> (a,b) swap
      [ swap push-selected-index drop ] curry each add-selected-row ]
    swap (table-button-down) ] [ table-button-down ] if ;

PRIVATE>

: row-action ( table -- )
    dup selected-row
    [ swap [ action>> call( value -- ) ] [ dup hook>> call( table -- ) ] bi ]
    [ 2drop ]
    if ;

: row-action? ( table -- ? )
    [ [ mouse-row ] keep valid-line? ]
    [ single-click?>> hand-click# get 2 = or ] bi and ;

<PRIVATE

: table-button-up ( table -- )
    dup row-action? [ row-action ] [ update-selected-values ] if ;

PRIVATE>

: select-row ( table n -- )
    over validate-line
    [ (select-row) ]
    [ drop update-selected-values ]
    [ show-row-summary ]
    2tri ;

<PRIVATE

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
    { T{ button-down f { S+ } 1 } thru-button-down }
    { T{ button-down f { A+ } 1 } continued-button-down }
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