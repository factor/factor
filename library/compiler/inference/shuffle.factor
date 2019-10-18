! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inference
USING: hashtables kernel math namespaces sequences ;

! Recursive state. An alist, mapping words to labels.
SYMBOL: recursive-state

: <computed> \ <computed> counter ;

TUPLE: value uid literal recursion ;

C: value ( obj -- value )
    <computed> over set-value-uid
    recursive-state get over set-value-recursion
    [ set-value-literal ] keep ;

M: value hashcode value-uid ;

M: value = eq? ;

M: integer value-uid ;

M: integer value-recursion drop f ;

TUPLE: shuffle in-d in-r out-d out-r ;

: load-shuffle ( d r shuffle -- )
    tuck shuffle-in-r [ set ] 2each shuffle-in-d [ set ] 2each ;

: shuffled-values ( values -- values )
    [ [ namespace hash dup ] keep ? ] map ;

: store-shuffle ( shuffle -- d r )
    dup shuffle-out-d shuffled-values
    swap shuffle-out-r shuffled-values ;

: shuffle* ( d r shuffle -- d r )
    [ [ load-shuffle ] keep store-shuffle ] with-scope ;

: split-shuffle ( d r shuffle -- d' r' d r )
    tuck shuffle-in-r length swap cut*
    >r >r shuffle-in-d length swap cut*
    r> swap r> ;

: join-shuffle ( d' r' d r -- d r )
    swapd append >r append r> ;

: shuffle ( d r shuffle -- d r )
    #! d and r lengths must be at least the required length for
    #! the shuffle.
    [ split-shuffle ] keep shuffle* join-shuffle ;

M: shuffle clone ( shuffle -- shuffle )
    [ shuffle-in-d clone ] keep
    [ shuffle-in-r clone ] keep
    [ shuffle-out-d clone ] keep
    shuffle-out-r clone
    <shuffle> ;
