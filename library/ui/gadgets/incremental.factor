! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: generic io kernel math namespaces ;

! Incremental layout allows adding lines to panes to be O(1).
! Note that incremental packs are distinct from ordinary packs
! defined in layouts.factor, since you don't want all packs to
! be incremental. In particular, incremental packs do not
! support non-default values for pack-align, pack-fill and
! pack-gap.

! The cursor is the current size of the incremental pack.
! New gadgets are added at cursor-cursor*gadget-orientation.

TUPLE: incremental cursor ;

C: incremental ( pack -- incremental )
    [ set-gadget-delegate ] keep
    dup delegate pref-dim over set-incremental-cursor ;

M: incremental pref-dim*
    dup gadget-state [
        dup delegate pref-dim over set-incremental-cursor
    ] when incremental-cursor ;

: next-cursor ( gadget incremental -- cursor )
    [
        swap rect-dim swap incremental-cursor
        2dup v+ >r vmax r>
    ] keep  gadget-orientation set-axis ;

: update-cursor ( gadget incremental -- )
    [ next-cursor ] keep set-incremental-cursor ;

: incremental-loc ( gadget incremental -- )
    dup incremental-cursor swap gadget-orientation v*
    swap set-rect-loc ;

: prefer-incremental ( gadget -- )
    dup forget-pref-dim dup pref-dim over set-rect-dim layout ;

: add-incremental ( gadget incremental -- )
    2dup (add-gadget)
    over prefer-incremental
    2dup incremental-loc
    tuck update-cursor
    dup prefer-incremental
    gadget-parent [ invalidate* ] when* ;

: clear-incremental ( incremental -- )
    dup (clear-gadget) dup forget-pref-dim
    { 0 0 } over set-incremental-cursor
    gadget-parent [ relayout ] when* ;
