! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math matrices namespaces sequences
threads vectors styles ;

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

: elevator-drag ( elevator -- )
    dup relayout
    dup drag-loc >r find-slider r> over slider-vector v.
    over screen>slider
    swap set-slider-value ;

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
    { 128 128 128 } background set-paint-prop ;

: slide-by ( amount gadget -- )
    #! The gadget can be any child of a slider.
    find-slider dup slider-elevator relayout
    [ slider-value + ] keep set-slider-value ;

: slide-by-page ( -1/1 gadget -- )
    [ slider-page * ] keep slide-by ;

: elevator-click ( elevator -- )
    dup relayout
    dup hand relative >r find-slider r>
    over slider-vector v.
    over screen>slider over slider-value - sgn
    swap slide-by-page ;

: elevator-actions ( elevator -- )
    [ elevator-click ] [ button-down 1 ] set-action ;

C: elevator ( -- elevator )
    <plain-gadget> over set-delegate
    dup elevator-theme dup elevator-actions ;

: thumb-loc ( slider -- loc )
    dup slider-value swap slider>screen ;

: thumb-dim ( slider -- h )
    dup slider-page swap slider>screen ;

: thumb-min { 12 12 0 } ;

: layout-thumb ( slider -- )
    dup thumb-loc over slider-vector n*v
    over slider-thumb set-rect-loc
    dup thumb-dim over slider-vector n*v thumb-min vmax
    swap slider-thumb set-gadget-dim ;

M: elevator layout* ( elevator -- )
    find-slider layout-thumb ;

M: elevator pref-dim drop thumb-min ;

: slide-by-line ( -1/1 slider -- ) >r 32 * r> slide-by ;

: <up-button>
    <gadget> [ -1 swap slide-by-line ] <button> ;

: add-up { 1 1 1 } over slider-vector v- 2unseq set-frame-child ;

: <down-button>
    <gadget> [ 1 swap slide-by-line ] <button> ;

: add-down { 1 1 1 } over slider-vector v+ 2unseq set-frame-child ;

: add-elevator 2dup set-slider-elevator add-center ;

: add-thumb 2dup slider-elevator add-gadget set-slider-thumb ;

C: slider ( vector -- slider )
    [ set-slider-vector ] keep
    <frame> over set-delegate
    0 over set-slider-value
    0 over set-slider-page
    0 over set-slider-max
    <elevator> over add-elevator
    <up-button> over add-up
    <down-button> over add-down
    <thumb> over add-thumb ;

: <x-slider> ( -- slider ) { 1 0 0 } <slider> ;

: <y-slider> ( -- slider ) { 0 1 0 } <slider> ;
