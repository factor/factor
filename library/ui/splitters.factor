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

TUPLE: splitter vector first divider second ;

C: splitter ( first second vector -- )
    [ set-splitter-vector ] keep
    [ set-splitter-second ] keep
    [ set-splitter-first ] keep
    [ dup <divider> swap set-splitter-divider ] keep ;

: splitter-pref-dims ( splitter -- dim dim dim )
    dup splitter-first pref-dim
    over splitter-divider pref-dim
    rot splitter-second pref-dim ;

: set-axis ( x y axis -- v )
    2dup v* >r >r drop dup r> v* v- r> v+ ;

M: splitter pref-size ( splitter -- w h )
    [ splitter-pref-dims 3dup vmax vmax >r v+ v+ r> ] keep
    splitter-vector set-axis 3unseq drop ;

M: splitter layout* ( splitter -- )
    
    ;
