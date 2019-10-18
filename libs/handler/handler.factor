
USING: kernel hashtables gadgets ;

IN: handler

TUPLE: handler table ;

M: handler handle-gesture* ( gadget gesture delegate -- ? )
handler-table hash dup [ call f ] [ 2drop t ] if ;