! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ui.gestures ui.gadgets ui.gadgets.buttons
ui.gadgets.frames ui.gadgets.grids
ui.gadgets.theme ui.render kernel math namespaces sequences
vectors models math.vectors math.functions quotations colors ;
IN: ui.gadgets.sliders

TUPLE: elevator direction ;

: find-elevator ( gadget -- elevator/f )
    [ elevator? ] find-parent ;

TUPLE: slider elevator thumb saved line ;

: find-slider ( gadget -- slider/f )
    [ slider? ] find-parent ;

: elevator-length ( slider -- n )
    dup slider-elevator rect-dim
    swap gadget-orientation v. ;

: min-thumb-dim 15 ;

: slider-value gadget-model range-value >fixnum ;

: slider-page gadget-model range-page-value ;

: slider-max gadget-model range-max-value ;

: slider-max* gadget-model range-max-value* ;

: thumb-dim ( slider -- h )
    dup slider-page over slider-max 1 max / 1 min
    over elevator-length * min-thumb-dim max
    over slider-elevator rect-dim
    rot gadget-orientation v. min ;

: slider-scale ( slider -- n )
    #! A scaling factor such that if x is a slider co-ordinate,
    #! x*n is the screen position of the thumb, and conversely
    #! for x/n. The '1 max' calls avoid division by zero.
    dup elevator-length over thumb-dim - 1 max
    swap slider-max* 1 max / ;

: slider>screen slider-scale * ;

: screen>slider slider-scale / ;

M: slider model-changed slider-elevator relayout-1 ;

TUPLE: thumb ;

: begin-drag ( thumb -- )
    find-slider dup slider-value swap set-slider-saved ;

: do-drag ( thumb -- )
    find-slider drag-loc over gadget-orientation v.
    over screen>slider swap [ slider-saved + ] keep
    gadget-model set-range-value ;

thumb H{
    { T{ button-down } [ begin-drag ] }
    { T{ button-up } [ drop ] }
    { T{ drag } [ do-drag ] }
} set-gestures

: thumb-theme ( thumb -- )
    plain-gradient over set-gadget-interior faint-boundary ;

: <thumb> ( vector -- thumb )
    thumb construct-gadget
    t over set-gadget-root?
    dup thumb-theme
    [ set-gadget-orientation ] keep ;

: slide-by ( amount slider -- )
    gadget-model move-by ;

: slide-by-page ( amount slider -- )
    gadget-model move-by-page ;

: compute-direction ( elevator -- -1/1 )
    dup find-slider swap hand-click-rel
    over gadget-orientation v.
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

: elevator-theme ( elevator -- )
    lowered-gradient swap set-gadget-interior ;

: <elevator> ( vector -- elevator )
    elevator construct-gadget
    [ set-gadget-orientation ] keep
    dup elevator-theme ;

: (layout-thumb) ( slider n -- n thumb )
    over gadget-orientation n*v swap slider-thumb ;

: thumb-loc ( slider -- loc )
    dup slider-value swap slider>screen ;

: layout-thumb-loc ( slider -- )
    dup thumb-loc (layout-thumb)
    >r [ floor ] map r> set-rect-loc ;

: layout-thumb-dim ( slider -- )
    dup dup thumb-dim (layout-thumb) >r
    >r dup rect-dim r>
    rot gadget-orientation set-axis [ ceiling ] map
    r> set-layout-dim ;

: layout-thumb ( slider -- )
    dup layout-thumb-loc layout-thumb-dim ;

M: elevator layout*
    find-slider layout-thumb ;

: slide-by-line ( amount slider -- )
    [ slider-line * ] keep slide-by ;

: <slide-button> ( vector polygon amount -- )
    >r gray swap <polygon-gadget> r>
    [ swap find-slider slide-by-line ] curry <repeat-button>
    [ set-gadget-orientation ] keep ;

: elevator, ( orientation -- )
    dup <elevator> g-> set-slider-elevator
    swap <thumb> g-> set-slider-thumb over add-gadget
    @center frame, ;

: <left-button> { 0 1 } arrow-left -1 <slide-button> ;
: <right-button> { 0 1 } arrow-right 1 <slide-button> ;

: build-x-slider ( slider -- slider )
    [
        <left-button> @left frame,
        { 0 1 } elevator,
        <right-button> @right frame,
    ] with-gadget ;

: <up-button> { 1 0 } arrow-up -1 <slide-button> ;
: <down-button> { 1 0 } arrow-down 1 <slide-button> ;

: build-y-slider ( slider -- slider )
    [
        <up-button> @top frame,
        { 1 0 } elevator,
        <down-button> @bottom frame,
    ] with-gadget ;

: <slider> ( range orientation -- slider )
    swap <frame> slider construct-control
    [ set-gadget-orientation ] keep
    32 over set-slider-line ;

: <x-slider> ( range -- slider )
    { 1 0 } <slider> dup build-x-slider ;

: <y-slider> ( range -- slider )
    { 0 1 } <slider> dup build-y-slider ;

M: slider pref-dim*
    dup delegate pref-dim*
    swap gadget-orientation [ 40 v*n ] keep
    set-axis ;
