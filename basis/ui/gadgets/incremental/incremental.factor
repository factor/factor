! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io kernel math namespaces math.vectors ui.gadgets
ui.gadgets.packs accessors math.geometry.rect ;
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

TUPLE: incremental < pack cursor ;

: <incremental> ( -- incremental )
    incremental new-gadget
        { 0 1 } >>orientation
        { 0 0 } >>cursor ;

M: incremental pref-dim*
    dup layout-state>> [
        dup call-next-method over (>>cursor)
    ] when cursor>> ;

: next-cursor ( gadget incremental -- cursor )
    [
        swap rect-dim swap cursor>>
        2dup v+ >r vmax r>
    ] keep orientation>> set-axis ;

: update-cursor ( gadget incremental -- )
    [ next-cursor ] keep (>>cursor) ;

: incremental-loc ( gadget incremental -- )
    [ cursor>> ] [ orientation>> ] bi v*
    >>loc drop ;

: prefer-incremental ( gadget -- )
    dup forget-pref-dim dup pref-dim >>dim drop ;

: add-incremental ( gadget incremental -- )
    not-in-layout
    2dup swap (add-gadget) drop
    over prefer-incremental
    over layout-later
    2dup incremental-loc
    tuck update-cursor
    dup prefer-incremental
    parent>> [ invalidate* ] when* ;

: clear-incremental ( incremental -- )
    not-in-layout
    dup (clear-gadget)
    dup forget-pref-dim
    { 0 0 } over (>>cursor)
    parent>> [ relayout ] when* ;
