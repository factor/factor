! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ui.gestures ui.gadgets ui.gadgets.buttons
ui.gadgets.frames ui.gadgets.grids math.order
ui.gadgets.theme ui.render kernel math namespaces sequences
vectors models models.range math.vectors math.functions
quotations colors math.geometry.rect fry ;
IN: ui.gadgets.sliders

TUPLE: elevator < gadget direction ;

: find-elevator ( gadget -- elevator/f ) [ elevator? ] find-parent ;

TUPLE: slider < frame elevator thumb saved line ;

: find-slider ( gadget -- slider/f ) [ slider? ] find-parent ;

: elevator-length ( slider -- n )
  [ elevator>> dim>> ] [ orientation>> ] bi v. ;

: min-thumb-dim 15 ;

: slider-value ( gadget -- n ) model>> range-value >fixnum ;
: slider-page  ( gadget -- n ) model>> range-page-value    ;
: slider-max   ( gadget -- n ) model>> range-max-value     ;
: slider-max*  ( gadget -- n ) model>> range-max-value*    ;

: thumb-dim ( slider -- h )
    [
        [ [ slider-page ] [ slider-max 1 max ] bi / 1 min ]
        [ elevator-length ] bi * min-thumb-dim max
    ]
    [ [ elevator>> dim>> ] [ orientation>> ] bi v. ] bi min ;

: slider-scale ( slider -- n )
    #! A scaling factor such that if x is a slider co-ordinate,
    #! x*n is the screen position of the thumb, and conversely
    #! for x/n. The '1 max' calls avoid division by zero.
    [ [ elevator-length ] [ thumb-dim ] bi - 1 max ]
    [ slider-max* 1 max ]
    bi / ;

: slider>screen ( m scale -- n ) slider-scale * ;
: screen>slider ( m scale -- n ) slider-scale / ;

M: slider model-changed nip elevator>> relayout-1 ;

TUPLE: thumb < gadget ;

: begin-drag ( thumb -- )
    find-slider dup slider-value >>saved drop ;

: do-drag ( thumb -- )
    find-slider drag-loc over orientation>> v.
    over screen>slider swap [ saved>> + ] keep
    model>> set-range-value ;

thumb H{
    { T{ button-down } [ begin-drag ] }
    { T{ button-up } [ drop ] }
    { T{ drag } [ do-drag ] }
} set-gestures

: thumb-theme ( thumb -- thumb )
    plain-gradient >>interior
    faint-boundary ; inline

: <thumb> ( vector -- thumb )
    thumb new-gadget
        swap >>orientation
        t >>root?
    thumb-theme ;

: slide-by ( amount slider -- ) model>> move-by ;

: slide-by-page ( amount slider -- ) model>> move-by-page ;

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
    elevator new-gadget
        swap >>orientation
        lowered-gradient >>interior ;

: (layout-thumb) ( slider n -- n thumb )
    over orientation>> n*v swap thumb>> ;

: thumb-loc ( slider -- loc )
    [ slider-value ] keep slider>screen ;

: layout-thumb-loc ( slider -- )
    dup thumb-loc (layout-thumb)
    [ [ floor ] map ] dip (>>loc) ;

: layout-thumb-dim ( slider -- )
    dup dup thumb-dim (layout-thumb)
    [
        [ [ dim>> ] dip ] [ drop orientation>> ] 2bi set-axis
        [ ceiling ] map
    ] dip (>>dim) ;

: layout-thumb ( slider -- )
    dup layout-thumb-loc layout-thumb-dim ;

M: elevator layout*
    find-slider layout-thumb ;

: slide-by-line ( amount slider -- ) [ line>> * ] keep slide-by ;

: <slide-button> ( vector polygon amount -- button )
    [ gray swap <polygon-gadget> ] dip
    '[ _ swap find-slider slide-by-line ] <repeat-button>
    swap >>orientation ;

: add-elevator ( gadget orientation -- gadget )
    [ <elevator> >>elevator ] [ <thumb> >>thumb ] bi
    dup [ elevator>> ] [ thumb>> ] bi add-gadget
    @center grid-add ;

: <left-button> ( -- button ) { 0 1 } arrow-left -1 <slide-button> ;
: <right-button> ( -- button ) { 0 1 } arrow-right 1 <slide-button> ;
: <up-button> ( -- button ) horizontal arrow-up -1 <slide-button> ;
: <down-button> ( -- button ) horizontal arrow-down  1 <slide-button> ;

: <slider> ( range orientation -- slider )
    slider new-frame
        swap >>orientation
        swap >>model
        32 >>line ;

: <x-slider> ( range -- slider )
    horizontal <slider>
        <left-button> @left grid-add
        vertical add-elevator
        <right-button> @right grid-add ;

: <y-slider> ( range -- slider )
    vertical <slider>
        <up-button> @top grid-add
        horizontal add-elevator
        <down-button> @bottom grid-add ;

M: slider pref-dim*
    [ call-next-method ] [ orientation>> ] bi
    [ 40 v*n ] keep
    set-axis ;
