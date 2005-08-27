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

: elevator-click ( elevator pos -- )
    2drop ;

: elevator-motion ( elevator -- )
    hand hand-click-rel elevator-click ;

: thumb-actions ( thumb -- )
    [ find-elevator elevator-motion ] [ drag 1 ] set-action ;

: <thumb> ( -- thumb )
    <gadget> [ drop ] <button>
    t over set-gadget-root?
    dup thumb-actions ;

: elevator-theme ( elevator -- )
    dup << solid f >> interior set-paint-prop
    { 128 128 128 } background set-paint-prop ;

: elevator-actions ( elevator -- )
    [ { 0 0 0 } elevator-click ] [ button-down 1 ] set-action ;

C: elevator ( -- elevator )
    <plain-gadget> over set-delegate
    dup elevator-theme dup elevator-actions ;

: >thumb ( n slider -- n )
    [ slider-max 1 max / ] keep
    dup slider-elevator rect-dim swap slider-vector v. * ;

: thumb-loc ( slider -- loc ) dup slider-value swap >thumb ;

: thumb-dim ( slider -- h ) dup slider-page swap >thumb ;

: thumb-min { 12 12 0 } ;

: layout-thumb ( slider -- )
    dup thumb-loc over slider-vector n*v
    over slider-thumb set-rect-loc
    dup thumb-dim over slider-vector n*v thumb-min vmax
    swap slider-thumb set-rect-dim ;

M: elevator layout* ( elevator -- )
    find-slider layout-thumb ;

M: elevator pref-dim drop thumb-min ;

: <up-button> <gadget> [ drop ] <button> ;

: add-up { 1 1 1 } over slider-vector v- 2unseq set-frame-child ;

: <down-button> <gadget> [ drop ] <button> ;

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
