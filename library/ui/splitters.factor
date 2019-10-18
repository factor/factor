! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-splitters
USING: gadgets gadgets-layouts generic kernel lists math
namespaces sequences styles vectors ;

TUPLE: divider splitter ;

: divider-size { 8 8 0 } ;

M: divider pref-dim drop divider-size ;

TUPLE: splitter split ;

: hand>split ( splitter -- n )
    drag-loc divider-size 1/2 v*n v+ ;

: divider-motion ( splitter -- )
    dup hand>split
    over rect-dim { 1 1 1 } vmax v/ over pack-vector v.
    0 max 1 min over set-splitter-split relayout ;

: divider-actions ( thumb -- )
    dup [ drop ] [ button-down 1 ] set-action
    dup [ drop ] [ button-up 1 ] set-action
    [ gadget-parent divider-motion ] [ drag 1 ] set-action ;

C: divider ( -- divider )
    <plain-gadget> over set-delegate
    dup t reverse-video set-paint-prop
    dup divider-actions ;

C: splitter ( first second split vector -- splitter )
    [ >r <pack> r> set-delegate ] keep
    [ set-splitter-split ] keep
    [ >r >r <divider> r> 3vector r> add-gadgets ] keep
    1 over set-pack-fill ;

: <x-splitter> ( first second split -- splitter )
    { 0 1 0 } <splitter> ;

: <y-splitter> ( first second split -- splitter )
    { 1 0 0 } <splitter> ;

: splitter-part ( splitter -- vec )
    dup splitter-split swap rect-dim
    n*v divider-size 1/2 v*n v- ;

: splitter-layout ( splitter -- { a b c } )
    [
        dup splitter-part ,
        divider-size ,
        dup rect-dim divider-size v- swap splitter-part v- ,
    ] { } make ;

M: splitter layout* ( splitter -- )
    dup splitter-layout packed-layout ;
