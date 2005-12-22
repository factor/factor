! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-splitters
USING: arrays gadgets gadgets-layouts gadgets-theme generic
kernel lists math namespaces sequences styles ;

TUPLE: divider splitter ;

: divider-size { 8 8 0 } ;

M: divider pref-dim drop divider-size ;

TUPLE: splitter split ;

: hand>split ( splitter -- n )
    drag-loc divider-size 1/2 v*n v+ ;

: divider-motion ( splitter -- )
    dup hand>split
    over rect-dim { 1 1 1 } vmax v/ over gadget-orientation v.
    0 max 1 min over set-splitter-split relayout-1 ;

: divider-actions ( thumb -- )
    dup [ drop ] [ button-down ] set-action
    dup [ drop ] [ button-up ] set-action
    [ gadget-parent divider-motion ] [ drag ] set-action ;

C: divider ( -- divider )
    dup delegate>gadget
    dup reverse-video-theme
    dup divider-actions ;

C: splitter ( first second split vector -- splitter )
    [ delegate>pack ] keep
    [ set-splitter-split ] keep
    [ >r >r <divider> r> 3array r> add-gadgets ] keep
    1 over set-pack-fill ;

: <x-splitter> ( first second split -- splitter )
    { 0 1 0 } <splitter> ;

: <y-splitter> ( first second split -- splitter )
    { 1 0 0 } <splitter> ;

: splitter-part ( splitter -- vec )
    dup splitter-split swap rect-dim
    n*v [ >fixnum ] map divider-size 1/2 v*n v- ;

: splitter-layout ( splitter -- { a b c } )
    [
        dup splitter-part ,
        divider-size ,
        dup rect-dim divider-size v- swap splitter-part v- ,
    ] { } make ;

M: splitter layout* ( splitter -- )
    dup splitter-layout packed-layout ;

: find-splitter ( gadget -- splitter )
    [ splitter? ] find-parent ;
