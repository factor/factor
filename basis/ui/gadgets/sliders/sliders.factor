! Copyright (C) 2005, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators fry grouping kernel literals
math math.order math.vectors models models.range sequences
ui.commands ui.gadgets ui.gadgets.buttons ui.gadgets.icons
ui.gadgets.tracks ui.gestures ui.pens ui.pens.image
ui.pens.polygon ui.pens.solid ui.pens.tile ui.theme
ui.theme.images ;
IN: ui.gadgets.sliders

TUPLE: slider < track elevator thumb saved line ;

: slider-value ( gadget -- n ) model>> range-value ;
: slider-page ( gadget -- n ) model>> range-page-value ;
: slider-min ( gadget -- n ) model>> range-min-value ;
: slider-max ( gadget -- n ) model>> range-max-value ;
: slider-max* ( gadget -- n ) model>> range-max-value* ;

: slider-length ( gadget -- n ) [ slider-max ] [ slider-min ] bi - ;
: slider-length* ( gadget -- n ) [ slider-max* ] [ slider-min ] bi - ;

: slide-by ( amount slider -- ) model>> move-by ;
: slide-by-page ( amount slider -- ) model>> move-by-page ;

: slide-by-line ( amount slider -- ) [ line>> * ] keep slide-by ;

<PRIVATE

TUPLE: elevator < gadget direction ;

: find-slider ( gadget -- slider/f ) [ slider? ] find-parent ;

CONSTANT: elevator-padding 4

: elevator-length ( slider -- n )
    [ elevator>> dim>> ] [ orientation>> ] bi vdot
    elevator-padding 2 * [-] ;

CONSTANT: min-thumb-dim 30

: visible-portion ( slider -- n )
    [ slider-page ]
    [ slider-length 1 max ]
    bi / 1 min ;

: thumb-dim ( slider -- h )
    [
        [ visible-portion ] [ elevator-length ] bi *
        min-thumb-dim max
    ]
    [ elevator-length ] bi min ;

: slider-scale ( slider -- n )
    ! A scaling factor such that if x is a slider coordinate,
    ! x*n is the screen position of the thumb, and conversely
    ! for x/n. The '1 max' calls avoid division by zero.
    [ [ elevator-length ] [ thumb-dim ] bi - 1 max ]
    [ slider-length* 1 max ]
    bi / ;

: slider>screen ( m slider -- n ) slider-scale * ;
: screen>slider ( m slider -- n ) slider-scale / ;

M: slider model-changed nip elevator>> relayout-1 ;

TUPLE: thumb < track ;

: begin-drag ( thumb -- )
    find-slider dup slider-value >>saved drop ;

: do-drag ( thumb -- )
    find-slider {
        [ orientation>> drag-loc vdot ]
        [ screen>slider ]
        [ saved>> + ]
        [ model>> set-range-value ]
    } cleave ;

thumb H{
    { T{ button-down } [ begin-drag ] }
    { T{ button-up } [ drop ] }
    { T{ drag } [ do-drag ] }
} set-gestures

CONSTANT: horizontal-thumb-tiles
    {
        { "horizontal-scroller-handle-left" f }
        { "horizontal-scroller-handle-middle" 1/2 }
        { "horizontal-scroller-handle-grip" f }
        { "horizontal-scroller-handle-middle" 1/2 }
        { "horizontal-scroller-handle-right" f }
    }

CONSTANT: vertical-thumb-tiles
    {
        { "vertical-scroller-handle-top" f }
        { "vertical-scroller-handle-middle" 1/2 }
        { "vertical-scroller-handle-grip" f }
        { "vertical-scroller-handle-middle" 1/2 }
        { "vertical-scroller-handle-bottom" f }
    }

: build-thumb ( thumb -- thumb )
    dup orientation>> {
        { horizontal [ horizontal-thumb-tiles ] }
        { vertical [ vertical-thumb-tiles ] }
    } case
    [ [ theme-image <icon> ] dip track-add ] assoc-each ;

: <thumb> ( orientation -- thumb )
    thumb new-track
        0 >>fill
        1/2 >>align
        build-thumb
        t >>root? ;

: compute-direction ( elevator -- -1/1 )
    [ hand-click-rel ] [ find-slider ] bi
    [ orientation>> vdot ]
    [ screen>slider ]
    [ slider-value - sgn ]
    tri ;

: elevator-hold ( elevator -- )
    [ direction>> ] [ find-slider ] bi '[ _ slide-by-page ] when* ;

: elevator-click ( elevator -- )
    dup compute-direction >>direction
    elevator-hold ;

elevator H{
    { T{ drag } [ elevator-hold ] }
    { T{ button-down } [ elevator-click ] }
} set-gestures

: <elevator> ( vector -- elevator )
    elevator new
        swap >>orientation ;

: thumb-loc ( slider -- loc )
    [ slider-value ]
    [ slider-min - ]
    [ slider>screen elevator-padding + ] tri ;

: layout-thumb-loc ( thumb slider -- )
    [ thumb-loc ] [ orientation>> ] bi n*v vfloor >>loc drop ;

: layout-thumb-dim ( thumb slider -- )
    [ dim>> ] [ thumb-dim ] [ orientation>> ] tri [ n*v ] keep set-axis
    vceiling >>dim drop ;

: slider-enabled? ( slider -- ? )
    visible-portion 1 = not ;

: layout-thumb ( slider -- )
    [ thumb>> ] keep
    [ slider-enabled? >>visible? drop ]
    [ layout-thumb-loc ]
    [ layout-thumb-dim ]
    2tri ;

M: elevator layout*
    find-slider layout-thumb ;

: add-thumb-to-elevator ( object -- object )
    [ elevator>> ] [ thumb>> ] bi add-gadget ;

: <slide-button-pen> ( orientation left right -- pen )
    [ horizontal = ] 2dip ?
    [ f f ] [ theme-image <image-pen> f f ] bi* <button-pen> ;

TUPLE: slide-button < repeat-button ;

: <slide-button> ( orientation amount left right -- button )
    [ swap ] 2dip
    [
        [ <gadget> ] dip
        '[ _ swap find-slider slide-by-line ]
        slide-button new-button
    ] 3dip
    <slide-button-pen> >>interior ;

M: slide-button pref-dim* dup interior>> pen-pref-dim ;

: <up-button> ( orientation -- button )
    -1
    "horizontal-scroller-leftarrow-clicked"
    "vertical-scroller-uparrow-clicked"
    <slide-button> ;

: <down-button> ( orientation -- button )
    1
    "horizontal-scroller-rightarrow-clicked"
    "vertical-scroller-downarrow-clicked"
    <slide-button> ;

TUPLE: slider-pen enabled disabled ;

: <slider-pen> ( orientation -- pen )
    {
        { horizontal [
            "horizontal-scroller-left" theme-image
            "horizontal-scroller-middle" theme-image
            "horizontal-scroller-right" theme-image
            "horizontal-scroller-right-disabled" theme-image
        ] }
        { vertical [
            "vertical-scroller-top" theme-image
            "vertical-scroller-middle" theme-image
            "vertical-scroller-bottom" theme-image
            "vertical-scroller-bottom-disabled" theme-image
        ] }
    } case
    [ f f <tile-pen> ] bi-curry@ 2bi slider-pen boa ;

: current-pen ( slider pen -- pen )
    [ slider-enabled? ] [ [ enabled>> ] [ disabled>> ] bi ] bi* ? ;

M: slider-pen draw-interior
    dupd current-pen draw-interior ;

M: slider-pen draw-boundary
    dupd current-pen draw-boundary ;

M: slider-pen pen-pref-dim
    enabled>> pen-pref-dim ;

M: slider pref-dim*
    [ dup slider-enabled? [ dup interior>> pen-pref-dim ] [ drop { 0 0 } ] if ]
    [ drop { 100 100 } ]
    [ orientation>> ] tri set-axis ;


TUPLE: drawn-slider < slider ;
TUPLE: drawn-slider-pen < slider-pen ;

CONSTANT: slider-highlight-color $ dim-color
: build-drawn-thumb ( thumb -- thumb )
    <gadget> slider-highlight-color <solid> >>interior 1/2 track-add ;

: <drawn-thumb> ( orientation -- thumb )
    thumb new-track
        1 >>fill
        1/2 >>align
        build-drawn-thumb
        t >>root? ;

: <slide-label-button-pen> ( -- pen )
    content-background <solid> dup
    toolbar-button-pressed-background <solid> dup dup
    <button-pen> ;

: <slide-label-button> ( orientation amount left right -- button )
    [ swap horizontal = ] 2dip ? swap
    '[ _ swap find-slider slide-by-line ]
    <repeat-button> { 1 1 } >>min-dim { 1 1 } >>size
    <slide-label-button-pen> >>interior ;
: <labelled-up-button> ( orientation -- button ) -1 "<" "^" <slide-label-button> ;
: <labelled-down-button> ( orientation -- button ) 1 ">" "v" <slide-label-button> ;

CONSTANT: scroll-arrow-dim 10
CONSTANT: scroll-arrow-dim/2 $[ $ scroll-arrow-dim 2 / ]
CONSTANT: up-triangle-points { { 0 $ scroll-arrow-dim } { $ scroll-arrow-dim/2 0 } { $ scroll-arrow-dim $ scroll-arrow-dim } }
CONSTANT: left-triangle-points { { 0 $ scroll-arrow-dim/2 } { $ scroll-arrow-dim  0 } { $ scroll-arrow-dim $ scroll-arrow-dim } }
CONSTANT: down-triangle-points { { 0 0  } { $ scroll-arrow-dim/2 $ scroll-arrow-dim } { $ scroll-arrow-dim 0 } }
CONSTANT: right-triangle-points { { 0 $ scroll-arrow-dim } { $ scroll-arrow-dim $ scroll-arrow-dim/2 } { 0 0 } }

: <drawn-up-button> ( orientation -- button )
    -1 left-triangle-points up-triangle-points [ slider-highlight-color swap <polygon-gadget> ] bi@ <slide-label-button> ;
: <drawn-down-button> ( orientation -- button )
    1 right-triangle-points down-triangle-points [ slider-highlight-color swap <polygon-gadget> ] bi@ <slide-label-button> ;

: <drawn-slider-pen> ( -- pen )
    content-background <solid> dim-color <solid> drawn-slider-pen boa ;

M: drawn-slider-pen pen-pref-dim 2drop { 2 2 } ;
: slider-required-width ( slider -- min-dim )
    children>> [ button? ] filter first pref-dim ;
M: drawn-slider pref-dim*
    [ dup slider-enabled? [ t >>visible? slider-required-width ] [ f >>visible? drop { 0 0 } ] if ]
    [ drop { 100 100 } ]
    [ orientation>> ] tri set-axis ;

: <drawn-slider> ( range orientation -- slider )
    drawn-slider new-track
        swap >>model
        16 >>line
        <drawn-slider-pen> >>interior
        dup orientation>> {
            [ <drawn-thumb> >>thumb ]
            [ <elevator> >>elevator ]
            [ drop dup add-thumb-to-elevator 1 track-add ]
            [ drop <gadget> { 1 1 } >>dim slider-highlight-color <solid> >>interior f track-add ]
            [ <drawn-up-button> f track-add ]
            [ drop <gadget> { 1 1 } >>dim slider-highlight-color <solid> >>interior f track-add ]
            [ <drawn-down-button> f track-add ]
            [ drop <gadget> { 1 1 } >>dim slider-highlight-color <solid> >>interior f track-add ]
        } cleave ;

: <tile-image-slider> ( range orientation -- slider )
    slider new-track
        swap >>model
        16 >>line
        dup orientation>> {
            [ <slider-pen> >>interior ]
            [ <thumb> >>thumb ]
            [ <elevator> >>elevator ]
            [ drop dup add-thumb-to-elevator 1 track-add ]
            [ <up-button> f track-add ]
            [ <down-button> f track-add ]
            [ drop <gadget> { 1 1 } >>dim f track-add ]
        } cleave ;

PRIVATE>

: <slider> ( range orientation -- slider )
    <drawn-slider> ;
