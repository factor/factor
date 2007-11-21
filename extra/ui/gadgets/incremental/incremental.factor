! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io kernel math namespaces math.vectors ui.gadgets
dlists ;
IN: ui.gadgets.incremental

! Incremental layout allows adding lines to panes to be O(1).
! Note that incremental packs are distinct from ordinary packs
! defined in layouts.factor, since you don't want all packs to
! be incremental. In particular, incremental packs do not
! support non-default values for pack-align, pack-fill and
! pack-gap.

! The cursor is the current size of the incremental pack.
! New gadgets are added at
!   incremental-cursor gadget-orientation v*

TUPLE: incremental cursor queue ;

: <incremental> ( pack -- incremental )
    dup pref-dim <dlist> {
        set-gadget-delegate
        set-incremental-cursor
        set-incremental-queue
    } incremental construct ;

M: incremental pref-dim*
    dup gadget-layout-state [
        dup delegate pref-dim over set-incremental-cursor
    ] when incremental-cursor ;

: next-cursor ( gadget incremental -- cursor )
    [
        swap rect-dim swap incremental-cursor
        2dup v+ >r vmax r>
    ] keep gadget-orientation set-axis ;

: update-cursor ( gadget incremental -- )
    [ next-cursor ] keep set-incremental-cursor ;

: incremental-loc ( gadget incremental -- )
    dup incremental-cursor swap gadget-orientation v*
    swap set-rect-loc ;

: prefer-incremental ( gadget -- )
    dup forget-pref-dim dup pref-dim swap set-rect-dim ;

: add-incremental ( gadget incremental -- )
    not-in-layout
    2dup incremental-queue push-front
    add-gadget ;

: (add-incremental) ( gadget incremental -- )
    2dup incremental-loc
    tuck update-cursor
    prefer-incremental ;

: clear-incremental ( incremental -- )
    not-in-layout
    dup (clear-gadget)
    dup forget-pref-dim
    { 0 0 } over set-incremental-cursor
    gadget-parent [ relayout ] when* ;
