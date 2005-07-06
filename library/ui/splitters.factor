! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math matrices namespaces sequences
styles ;

TUPLE: divider splitter ;

: divider-size { 8 8 0 } ;

M: divider pref-dim drop divider-size ;

TUPLE: splitter split ;

: hand>split ( splitter -- n )
    hand relative hand hand-click-rel v- divider-size 1/2 v*n v+ ;

: divider-motion ( splitter -- )
    dup hand>split
    over shape-dim { 1 1 1 } vmax v/ over pack-vector v.
    0 max 1 min over set-splitter-split relayout ;

: divider-actions ( thumb -- )
    dup [ drop ] [ button-down 1 ] set-action
    dup [ drop ] [ button-up 1 ] set-action
    [ gadget-parent divider-motion ] [ drag 1 ] set-action ;

C: divider ( -- divider )
    <plain-gadget> over set-delegate
    dup t reverse-video set-paint-prop
    dup divider-actions ;

C: splitter ( first second vector -- splitter )
    [ >r 0 1 rot <pack> r> set-delegate ] keep
    swapd
    [ add-gadget ] keep
    <divider> over add-gadget
    [ add-gadget ] keep
    1/2 over set-splitter-split ;

: <x-splitter> { 0 1 0 } <splitter> ;

: <y-splitter> { 1 0 0 } <splitter> ;

: splitter-part ( splitter -- vec )
    dup splitter-split swap shape-dim n*v divider-size 1/2 v*n v- ;

: splitter-layout ( splitter -- [ a b c ] )
    [
        dup splitter-part ,
        divider-size ,
        dup shape-dim swap splitter-part v- ,
    ] make-list ;

M: splitter layout* ( splitter -- )
    dup splitter-layout packed-layout ;
