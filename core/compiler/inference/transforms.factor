! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inference
USING: arrays kernel words sequences generic math namespaces ;

: pop-literals ( n -- rstate seq )
    [ ensure-values ] keep
    [ d-tail ] keep
    (consume-values)
    [ first value-recursion ] keep
    [ value-literal ] map ;

: transform-quot ( quot n -- newquot )
    [
        , \ pop-literals , [ [ ] each ] % % \ infer-quot-value ,
    ] [ ] make ;

: define-transform ( word n quot -- )
    swap transform-quot "infer" set-word-prop ;

\ cond 1 [
    <reversed> [ no-cond ] swap alist>quot
] define-transform

\ case 1 [
    [ first2 >r [ dupd = ] curry r> \ drop add* 2array ] map
    { [ t ] [ no-case ] } add
    [ cond ] curry
] define-transform

GENERIC: (bitfield-quot) ( spec -- quot )

M: integer (bitfield-quot) ( spec -- quot )
    [ swapd shift bitor ] curry ;

M: pair (bitfield-quot) ( spec -- quot )
    first2 over word? [ >r swapd execute r> ] [ ] ?
    [ shift bitor ] append curry curry ;

: bitfield-quot ( spec -- quot )
    [ (bitfield-quot) ] map [ 0 ] add* concat ;

\ bitfield 1 [ bitfield-quot ] define-transform
