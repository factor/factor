! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math matrices namespaces sequences
styles ;

TUPLE: divider splitter ;

: divider-size { 8 8 0 } ;

M: divider pref-dim drop divider-size ;

TUPLE: splitter vector split ;

: hand>split ( splitter -- n )
    hand relative hand hand-click-rel v- divider-size 1/2 v*n v+ ;

: divider-motion ( splitter -- )
    dup hand>split
    over shape-dim { 1 1 1 } vmax v/ over splitter-vector v.
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
    <empty-gadget> over set-delegate
    [ set-splitter-vector ] keep
    swapd
    [ add-gadget ] keep
    <divider> over add-gadget
    [ add-gadget ] keep
    1/2 over set-splitter-split ;

: <x-splitter> { 0 1 0 } <splitter> ;

: <y-splitter> { 1 0 0 } <splitter> ;

M: splitter pref-dim
    dup gadget-children swap splitter-vector
    { 0 0 0 } swap packed-pref-dim ;

: splitter-part ( splitter -- vec )
    dup splitter-split swap shape-dim n*v divider-size 1/2 v*n v- ;

: splitter-layout ( splitter -- [ a b c ] )
    [
        dup splitter-part ,
        divider-size ,
        dup shape-dim swap splitter-part v- ,
    ] make-list ;

: packed-locs ( axis sizes gadget -- )
    >r
    { 0 0 0 } [ v+ ] accumulate
    [ { 0 0 0 } swap rot set-axis ] map-with
    r> gadget-children zip [ uncons set-gadget-loc ] each ;

: packed-dims ( axis sizes gadget -- dims )
    [
        shape-dim swap [ >r 2dup r> rot set-axis ] map 2nip
    ] keep gadget-children zip [ uncons set-gadget-dim ] each ;

: layout-divider ( assoc -- )
    [ uncons set-gadget-dim ] each ;

: packed-layout ( axis sizes gadgets -- )
    3dup packed-locs packed-dims ;

M: splitter layout* ( splitter -- )
    dup splitter-vector over splitter-layout rot packed-layout ;
