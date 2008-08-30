! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ui.gestures ui.gadgets ui.gadgets.buttons
ui.gadgets.frames ui.gadgets.grids math.order
ui.gadgets.theme ui.render kernel math namespaces sequences
vectors models models.range math.vectors math.functions
quotations colors math.geometry.rect ;
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
    dup slider-page over slider-max 1 max / 1 min
    over elevator-length * min-thumb-dim max
    over slider-elevator rect-dim
    rot orientation>> v. min ;

: slider-scale ( slider -- n )
    #! A scaling factor such that if x is a slider co-ordinate,
    #! x*n is the screen position of the thumb, and conversely
    #! for x/n. The '1 max' calls avoid division by zero.
    dup elevator-length over thumb-dim - 1 max
    swap slider-max* 1 max / ;

: slider>screen ( m scale -- n ) slider-scale * ;
: screen>slider ( m scale -- n ) slider-scale / ;

M: slider model-changed nip slider-elevator relayout-1 ;

TUPLE: thumb < gadget ;

: begin-drag ( thumb -- )
    find-slider dup slider-value swap set-slider-saved ;

: do-drag ( thumb -- )
    find-slider drag-loc over orientation>> v.
    over screen>slider swap [ slider-saved + ] keep
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
    dup find-slider swap hand-click-rel
    over orientation>> v.
    over screen>slider
    swap slider-value - sgn ;

: elevator-hold ( elevator -- )
    dup elevator-direction swap find-slider slide-by-page ;

: elevator-click ( elevator -- )
    dup compute-direction over set-elevator-direction
    elevator-hold ;

elevator H{
    { T{ drag } [ elevator-hold ] }
    { T{ button-down } [ elevator-click ] }
} set-gestures

: <elevator> ( vector -- elevator )
  elevator new-gadget
    swap             >>orientation
    lowered-gradient >>interior ;

: (layout-thumb) ( slider n -- n thumb )
    over orientation>> n*v swap slider-thumb ;

: thumb-loc ( slider -- loc )
    dup slider-value swap slider>screen ;

: layout-thumb-loc ( slider -- )
    dup thumb-loc (layout-thumb)
    >r [ floor ] map r> set-rect-loc ;

: layout-thumb-dim ( slider -- )
    dup dup thumb-dim (layout-thumb) >r
    >r dup rect-dim r>
    rot orientation>> set-axis [ ceiling ] map
    r> (>>dim) ;

: layout-thumb ( slider -- )
    dup layout-thumb-loc layout-thumb-dim ;

M: elevator layout*
    find-slider layout-thumb ;

: slide-by-line ( amount slider -- )
    [ slider-line * ] keep slide-by ;

: <slide-button> ( vector polygon amount -- button )
    >r gray swap <polygon-gadget> r>
    [ swap find-slider slide-by-line ] curry <repeat-button>
    [ (>>orientation) ] keep ;

: elevator, ( gadget orientation -- gadget )
  tuck <elevator> >>elevator
  swap <thumb>    >>thumb
  dup elevator>> over thumb>> add-gadget
  @center grid-add ;

: <left-button>  ( -- button ) { 0 1 } arrow-left -1 <slide-button> ;
: <right-button> ( -- button ) { 0 1 } arrow-right 1 <slide-button> ;
: <up-button>    ( -- button ) { 1 0 } arrow-up   -1 <slide-button> ;
: <down-button>  ( -- button ) { 1 0 } arrow-down  1 <slide-button> ;

: <slider> ( range orientation -- slider )
    slider new-frame
        swap >>orientation
        swap >>model
        32 >>line ;

: <x-slider> ( range -- slider )
  { 1 0 } <slider>
    <left-button> @left grid-add
    { 0 1 } elevator,
    <right-button> @right grid-add ;

: <y-slider> ( range -- slider )
  { 0 1 } <slider>
    <up-button> @top grid-add
    { 1 0 } elevator,
    <down-button> @bottom grid-add ;

M: slider pref-dim*
    dup call-next-method
    swap orientation>> [ 40 v*n ] keep
    set-axis ;
