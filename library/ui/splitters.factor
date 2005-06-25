! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists matrices namespaces sequences ;

TUPLE: divider splitter ;

C: divider ( -- divider )
    <plain-gadget> over set-delegate
    dup t reverse-video set-paint-prop ;

: divider-size { 8 8 0 } ;

M: divider pref-size drop divider-size 3unseq drop ;

TUPLE: splitter vector split ;

M: splitter orientation splitter-vector ;

C: splitter ( first second vector -- splitter )
    <empty-gadget> over set-delegate
    [ set-splitter-vector ] keep
    swapd
    [ add-gadget ] keep
    <divider> over add-gadget
    [ add-gadget ] keep
    1/2 over set-splitter-split ;

: <x-splitter> { 1 0 0 } <splitter> ;

: <y-splitter> { 0 1 0 } <splitter> ;

M: splitter pref-size
    [
        gadget-children [ pref-dim ] map
        dup { 0 0 0 } swap [ vmax ] each
        swap { 0 0 0 } swap [ v+ ] each
    ] keep orient 3unseq drop ;

: splitter-part ( splitter -- vec )
    dup splitter-split swap shape-dim n*v divider-size 1/2 v*n v- ;

: splitter-layout ( splitter -- [ a b c ] )
    [
        dup splitter-part ,
        divider-size ,
        dup shape-dim swap splitter-part v- ,
    ] make-list ;

: layout-divider ( assoc -- )
    [ uncons set-gadget-dim ] each ;

M: splitter layout* ( splitter -- )
    [
        dup splitter-layout [ nip ( { 0 0 0 } rot orient ) ] map-with
    ] keep gadget-children zip layout-divider ;
