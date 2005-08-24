! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel math ;

! Incremental layout allows adding lines to panes to be O(1).
! Note that incremental packs are distinct from ordinary packs
! defined in layouts.factor, since you don't want all packs to
! be incremental. In particular, if the children of the pack
! change size, the incremental strategy does not work.

! The cursor is the current size of the incremental pack.
! New gadgets are added at cursor-cursor*pack-vector.

TUPLE: incremental cursor ;

C: incremental ( pack -- incremental )
    [ set-delegate ] keep
    { 0 0 0 } over set-incremental-cursor ;

M: incremental pref-dim incremental-cursor ;

M: incremental layout* drop ;

: next-cursor ( gadget incremental -- cursor )
    [
        swap rect-dim swap incremental-cursor
        2dup v+ >r vmax r>
    ] keep  pack-vector set-axis ;

: update-cursor ( gadget incremental -- )
    [ next-cursor ] keep set-incremental-cursor ;

: incremental-loc ( gadget incremental -- )
    dup incremental-cursor swap pack-vector v*
    swap set-rect-loc ;

: prefer-incremental ( gadget -- )
    dup pref-dim over set-rect-dim layout ;

: add-incremental ( gadget incremental -- )
    2dup (add-gadget)
    over prefer-incremental
    2dup incremental-loc
    tuck update-cursor
    prefer-incremental ;

: clear-incremental ( incremental -- )
    dup (clear-gadget)
    { 0 0 0 } over set-incremental-cursor
    gadget-parent [ relayout ] when* ;
