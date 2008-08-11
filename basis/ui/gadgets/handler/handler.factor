
USING: kernel assocs ui.gestures ui.gadgets.wrappers accessors ;

IN: ui.gadgets.handler

TUPLE: handler < wrapper table ;

: <handler> ( child -- handler ) handler new-wrapper ;

M: handler handle-gesture* ( gadget gesture delegate -- ? )
   table>> at dup [ call f ] [ 2drop t ] if ;