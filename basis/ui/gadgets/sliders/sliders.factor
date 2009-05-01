! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs kernel math namespaces sequences
vectors models models.range math.vectors math.functions quotations
colors colors.constants math.rectangles fry combinators ui.gestures
ui.pens ui.gadgets ui.gadgets.buttons ui.gadgets.tracks math.order
ui.gadgets.icons ui.pens.tile ui.pens.image ;
IN: ui.gadgets.sliders

TUPLE: slider < track elevator thumb saved line ;

: slider-value ( gadget -- n ) model>> range-value >fixnum ;
: slider-page ( gadget -- n ) model>> range-page-value ;
: slider-max ( gadget -- n ) model>> range-max-value ;
: slider-max* ( gadget -- n ) model>> range-max-value* ;

: slide-by ( amount slider -- ) model>> move-by ;
: slide-by-page ( amount slider -- ) model>> move-by-page ;

: slide-by-line ( amount slider -- ) [ line>> * ] keep slide-by ;

<PRIVATE

TUPLE: elevator < gadget direction ;

: find-elevator ( gadget -- elevator/f ) [ elevator? ] find-parent ;

: find-slider ( gadget -- slider/f ) [ slider? ] find-parent ;

CONSTANT: elevator-padding 4

: elevator-length ( slider -- n )
    [ elevator>> dim>> ] [ orientation>> ] bi v.
    elevator-padding 2 * - ;

CONSTANT: min-thumb-dim 30

: visible-portion ( slider -- n )
    [ slider-page ] [ slider-max 1 max ] bi / 1 min ;

: thumb-dim ( slider -- h )
    [
        [ visible-portion ] [ elevator-length ] bi *
        min-thumb-dim max
    ]
    [ elevator-length ] bi min ;

: slider-scale ( slider -- n )
    #! A scaling factor such that if x is a slider co-ordinate,
    #! x*n is the screen position of the thumb, and conversely
    #! for x/n. The '1 max' calls avoid division by zero.
    [ [ elevator-length ] [ thumb-dim ] bi - 1 max ]
    [ slider-max* 1 max ]
    bi / ;

: slider>screen ( m slider -- n ) slider-scale * ;
: screen>slider ( m slider -- n ) slider-scale / ;

M: slider model-changed nip elevator>> relayout-1 ;

TUPLE: thumb < track ;

: begin-drag ( thumb -- )
    find-slider dup slider-value >>saved drop ;

: do-drag ( thumb -- )
    find-slider {
        [ orientation>> drag-loc v. ]
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
    [ orientation>> v. ]
    [ screen>slider ]
    [ slider-value - sgn ]
    tri ;

: elevator-hold ( elevator -- )
    [ direction>> ] [ find-slider ] bi slide-by-page ;

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
    [ slider-value ] keep slider>screen elevator-padding + ;

: layout-thumb-loc ( thumb slider -- )
    [ thumb-loc ] [ orientation>> ] bi n*v
    [ floor ] map >>loc drop ;

: layout-thumb-dim ( thumb slider -- )
    [ dim>> ] [ thumb-dim ] [ orientation>> ] tri [ n*v ] keep set-axis
    [ ceiling ] map >>dim drop ;

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
    [ f f <tile-pen> ] bi-curry@ 2bi \ slider-pen boa ;

: slider-pen ( slider pen -- pen )
    [ slider-enabled? ] [ [ enabled>> ] [ disabled>> ] bi ] bi* ? ;

M: slider-pen draw-interior
    dupd slider-pen draw-interior ;

M: slider-pen draw-boundary
    dupd slider-pen draw-boundary ;

M: slider-pen pen-pref-dim
    enabled>> pen-pref-dim ;

M: slider pref-dim*
    [ dup interior>> pen-pref-dim ] [ drop { 100 100 } ] [ orientation>> ] tri
    set-axis ;

PRIVATE>

: <slider> ( range orientation -- slider )
    slider new-track
        swap >>model
        32 >>line
        dup orientation>> {
            [ <slider-pen> >>interior ]
            [ <thumb> >>thumb ]
            [ <elevator> >>elevator ]
            [ drop dup add-thumb-to-elevator 1 track-add ]
            [ <up-button> f track-add ]
            [ <down-button> f track-add ]
            [ drop <gadget> { 1 1 } >>dim f track-add ]
        } cleave ;