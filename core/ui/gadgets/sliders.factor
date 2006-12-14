! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-sliders
USING: arrays gadgets gadgets-buttons
gadgets-theme generic kernel math namespaces
sequences styles threads vectors models ;

TUPLE: elevator ;

: find-elevator ( gadget -- elevator/f )
    [ elevator? ] find-parent ;

TUPLE: slider elevator thumb saved max line page ;

: find-slider ( gadget -- slider/f )
    [ slider? ] find-parent ;

: elevator-length ( slider -- n )
    dup slider-elevator rect-dim
    swap gadget-orientation v. ;

: min-thumb-dim 30 ;

: thumb-dim ( slider -- h )
    dup slider-page over slider-max 1 max / 1 min
    over elevator-length * min-thumb-dim max
    over slider-elevator rect-dim
    rot gadget-orientation v. min ;

: slider-max* dup slider-max swap slider-page [-] ;

: slider-scale ( slider -- n )
    #! A scaling factor such that if x is a slider co-ordinate,
    #! x*n is the screen position of the thumb, and conversely
    #! for x/n. The '1 max' calls avoid division by zero.
    dup elevator-length over thumb-dim - 1 max
    swap slider-max* 1 max / ;

: slider>screen slider-scale * ;

: screen>slider slider-scale / ;

: fix-slider-value ( n slider -- n )
    slider-max* min 0 max >fixnum ;

: set-slider-value ( value slider -- )
    [ fix-slider-value ] keep set-control-value ;

M: slider model-changed slider-elevator relayout-1 ;

TUPLE: thumb ;

: begin-drag ( thumb -- )
    find-slider dup control-value swap set-slider-saved ;

: do-drag ( thumb -- )
    find-slider drag-loc over gadget-orientation v.
    over screen>slider swap [ slider-saved + ] keep
    set-slider-value ;

thumb H{
    { T{ button-down } [ begin-drag ] }
    { T{ button-up } [ drop ] }
    { T{ drag } [ do-drag ] }
} set-gestures

C: thumb ( vector -- thumb )
    dup delegate>gadget
    t over set-gadget-root?
    dup thumb-theme
    [ set-gadget-orientation ] keep ;

: slide-by ( amount slider -- )
    [ control-value + ] keep set-slider-value ;

: slide-by-page ( -1/1 slider -- )
    [ slider-page * ] keep slide-by ;

: page-direction ( elevator -- -1/1 )
    dup find-slider swap hand-click-rel
    over gadget-orientation v.
    over screen>slider
    swap control-value - sgn ;

: elevator-click ( elevator -- )
    dup page-direction
    [ swap find-slider slide-by-page ] curry
    start-timer-gadget ;

elevator H{
    { T{ button-down } [ elevator-click ] }
    { T{ button-up } [ stop-timer-gadget ] }
} set-gestures

C: elevator ( vector -- elevator )
    <gadget> <timer-gadget> over set-gadget-delegate
    [ set-gadget-orientation ] keep
    dup elevator-theme ;

: (layout-thumb) ( slider n -- n thumb )
    over gadget-orientation n*v swap slider-thumb ;

: thumb-loc ( slider -- loc )
    dup control-value swap slider>screen ;

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

: slide-by-line ( -1/1 slider -- )
    [ slider-line * ] keep slide-by ;

: <slide-button> ( vector polygon amount -- )
    >r gray swap <polygon-gadget> r>
    [ swap find-slider slide-by-line ] curry <repeat-button>
    [ set-gadget-orientation ] keep ;

: <left-button> { 0 1 } arrow-left -1 <slide-button> ;
: <right-button> { 0 1 } arrow-right 1 <slide-button> ;

: build-x-slider ( slider -- slider )
    {
        { [ <left-button> ] f f @left }
        { [ { 0 1 } <elevator> ] set-slider-elevator f @center }
        { [ <right-button> ] f f @right }
    } build-grid ;

: <up-button> { 1 0 } arrow-up -1 <slide-button> ;
: <down-button> { 1 0 } arrow-down 1 <slide-button> ;

: build-y-slider ( slider -- slider )
    {
        { [ <up-button> ] f f @top }
        { [ { 1 0 } <elevator> ] set-slider-elevator f @center }
        { [ <down-button> ] f f @bottom }
    } build-grid ;

: add-thumb ( slider vector -- )
    <thumb> swap 2dup slider-elevator add-gadget
    set-slider-thumb ;

C: slider ( orientation -- slider )
    dup 0 <model> <frame> delegate>control
    [ set-gadget-orientation ] keep
    32 over set-slider-line
    0 over set-slider-page
    0 over set-slider-max ;

: <x-slider> ( -- slider )
    { 1 0 } <slider> dup build-x-slider
    dup { 0 1 } add-thumb ;

: <y-slider> ( -- slider )
    { 0 1 } <slider> dup build-y-slider
    dup { 1 0 } add-thumb ;

: set-slider ( value page max slider -- )
    [ [ gadget-orientation v. ] keep set-slider-max ] keep
    [ [ gadget-orientation v. ] keep set-slider-page ] keep
    [ gadget-orientation v. ] keep set-slider-value ;
