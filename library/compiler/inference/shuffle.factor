! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inference
USING: hashtables kernel math namespaces sequences ;

SYMBOL: recursive-state

: <computed> \ <computed> counter ;

TUPLE: value uid literal recursion ;

C: value ( obj -- value )
    <computed> over set-value-uid
    recursive-state get over set-value-recursion
    [ set-value-literal ] keep ;

M: value hashcode value-uid ;

M: value equal? eq? ;

M: integer value-uid ;

M: integer value-recursion drop f ;

TUPLE: shuffle in out ;

: split-shuffle ( stack shuffle -- stack1 stack2 )
    shuffle-in length swap cut* ;

: load-shuffle ( stack shuffle -- )
    shuffle-in [ set ] 2each ;

: shuffled-values ( shuffle -- values )
    shuffle-out [ get ] map ;

: shuffle* ( stack shuffle -- stack )
    [ [ load-shuffle ] keep shuffled-values ] with-scope ;

: shuffle ( stack shuffle -- stack )
    [ split-shuffle ] keep shuffle* append ;

M: shuffle clone
    [ shuffle-in clone ] keep shuffle-out clone <shuffle> ;
