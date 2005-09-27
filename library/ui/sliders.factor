! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-scrolling
USING: gadgets gadgets-buttons gadgets-layouts generic kernel
lists math namespaces sequences threads vectors styles ;

! An elevator has a thumb that may be moved up and down.
TUPLE: elevator ;

: find-elevator [ elevator? ] find-parent ;

! A slider scrolls a viewport.
TUPLE: slider vector elevator thumb value max page ;

: find-slider [ slider? ] find-parent ;

: slider-scale ( slider -- n )
    #! A scaling factor such that if x is a slider co-ordinate,
    #! x*n is the screen position of the thumb, and conversely
    #! for x/n. The '1 max' calls avoid division by zero.
    dup slider-elevator rect-dim over slider-vector v. 1 max
    swap slider-max 1 max / ;

: slider>screen slider-scale * ;

: screen>slider slider-scale / ;

: fix-slider-value ( n slider -- n )
    dup slider-max swap slider-page - min 0 max ;

: fix-slider ( slider -- )
    #! Call after changing slots, to relayout and do invariants:
    #! - max <= page
    #! - 0 <= value <= max-page
    dup slider-elevator relayout-1
    dup slider-max over slider-page max over set-slider-max
    dup slider-value over fix-slider-value swap set-slider-value ;

SYMBOL: slider-changed

: set-slider-value* ( value slider -- )
    [ set-slider-value ] keep [ fix-slider ] keep
    [ slider-changed ] swap handle-gesture drop ;

: elevator-drag ( elevator -- )
    dup drag-loc >r find-slider r> over slider-vector v.
    over screen>slider
    swap set-slider-value* ;

: thumb-actions ( thumb -- )
    dup [ drop ] [ button-up 1 ] set-action
    dup [ drop ] [ button-down 1 ] set-action
    [ find-elevator elevator-drag ] [ drag 1 ] set-action ;

: <thumb> ( -- thumb )
    <bevel-gadget> dup button-theme
    t over set-gadget-root?
    dup thumb-actions ;

: elevator-theme ( elevator -- )
    dup << solid f >> interior set-paint-prop
    light-gray background set-paint-prop ;

: slide-by ( amount gadget -- )
    #! The gadget can be any child of a slider.
    find-slider [ slider-value + ] keep set-slider-value* ;

: slide-by-page ( -1/1 gadget -- )
    [ slider-page * ] keep slide-by ;

: elevator-click ( elevator -- )
    dup hand relative >r find-slider r>
    over slider-vector v.
    over screen>slider over slider-value - sgn
    swap slide-by-page ;

: elevator-actions ( elevator -- )
    [ elevator-click ] [ button-down 1 ] set-action ;

C: elevator ( -- elevator )
    <plain-gadget> over set-delegate
    dup elevator-theme dup elevator-actions ;

: (layout-thumb) ( slider n -- n )
    over slider-vector n*v swap slider-thumb ;

: thumb-loc ( slider -- loc )
    dup slider-value swap slider>screen ;

: layout-thumb-loc ( slider -- )
    dup thumb-loc (layout-thumb) set-rect-loc ;

: thumb-dim ( slider -- h )
    dup slider-page swap slider>screen ;

: layout-thumb-dim ( slider -- )
    dup dup thumb-dim (layout-thumb)
    >r >r dup rect-dim r> rot slider-vector set-axis r>
    set-gadget-dim ;

: layout-thumb ( slider -- )
    dup layout-thumb-loc layout-thumb-dim ;

M: elevator layout* ( elevator -- )
    find-slider layout-thumb ;

: slide-by-line ( -1/1 slider -- ) >r 32 * r> slide-by ;

: slider-vertical? slider-vector @{ 0 1 0 }@ = ;

: <up-button> ( slider -- button )
    slider-vertical? arrow-up arrow-left ? <polygon-gadget>
    [ -1 swap slide-by-line ] <repeat-button> ;

: add-up @{ 1 1 1 }@ over slider-vector v- first2 frame-add ;

: <down-button> ( slider -- button )
    slider-vertical? arrow-down arrow-right ? <polygon-gadget>
    [ 1 swap slide-by-line ] <repeat-button> ;

: add-down @{ 1 1 1 }@ over slider-vector v+ first2 frame-add ;

: add-elevator 2dup set-slider-elevator @center frame-add ;

: add-thumb 2dup slider-elevator add-gadget set-slider-thumb ;

C: slider ( vector -- slider )
    [ set-slider-vector ] keep
    <frame> over set-delegate
    0 over set-slider-value
    0 over set-slider-page
    0 over set-slider-max
    <elevator> over add-elevator
    dup <up-button> over add-up
    dup <down-button> over add-down
    <thumb> over add-thumb ;

: <x-slider> ( -- slider ) @{ 1 0 0 }@ <slider> ;

: <y-slider> ( -- slider ) @{ 0 1 0 }@ <slider> ;
