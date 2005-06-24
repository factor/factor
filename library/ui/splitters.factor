! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel matrices sequences ;

TUPLE: divider splitter ;

C: divider ( splitter -- divider )
    [ set-divider-splitter ] keep
    <plain-gadget> over set-delegate
    dup t reverse-video set-paint-prop ;

M: divider pref-size drop 16 16 ;

TUPLE: splitter vector first divider second split ;

M: splitter orientation splitter-vector ;

C: splitter ( first second vector -- splitter )
    <empty-gadget> over set-delegate
    [ set-splitter-vector ] keep
    [ set-splitter-second ] keep
    [ set-splitter-first ] keep
    [ dup <divider> swap set-splitter-divider ] keep
    1/2 over set-splitter-split ;

: <x-splitter> ( first second -- splitter )
    { 1 0 0 } <splitter> ;

: <y-splitter> ( first second -- splitter )
    { 0 1 0 } <splitter> ;

: splitter-pref-dims ( splitter -- dim dim dim )
    dup splitter-first pref-dim
    over splitter-divider pref-dim
    rot splitter-second pref-dim ;

M: splitter pref-size ( splitter -- w h )
    [ splitter-pref-dims 3dup vmax vmax >r v+ v+ r> ] keep
    orient 3unseq drop ;

: size-divider ( splitter -- )
    dup shape-dim over splitter-divider
    [ rot orient ] keep set-gadget-dim ;

: move-divider ( splitter -- )
    [
        dup shape-dim dup pick splitter-split v*n { 8 8 8 } v-
        rot orient
    ] keep splitter-divider set-gadget-loc ;

: layout-divider ( splitter -- )
    dup size-divider move-divider ;

M: splitter layout* ( splitter -- )
    ( layout-divider ) drop ;
