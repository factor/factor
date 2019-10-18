
USING: kernel assocs ui.gestures ;

IN: ui.gadgets.handler

TUPLE: handler table ;

C: <handler> handler

M: handler handle-gesture* ( gadget gesture delegate -- ? )
handler-table at dup [ call f ] [ 2drop t ] if ;