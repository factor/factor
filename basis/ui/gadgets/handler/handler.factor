
USING: kernel assocs ui.gestures ui.gadgets.wrappers accessors ;

IN: ui.gadgets.handler

TUPLE: handler < wrapper table ;

: <handler> ( child -- handler ) handler new-wrapper ;

M: handler handle-gesture ( gesture gadget -- ? )
   over table>> at dup [ call f ] [ 2drop t ] if ;