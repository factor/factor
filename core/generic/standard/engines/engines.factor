! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel kernel.private namespaces quotations
generic math sequences combinators words classes.algebra arrays
;
IN: generic.standard.engines

SYMBOL: default
SYMBOL: assumed
SYMBOL: (dispatch#)

GENERIC: engine>quot ( engine -- quot )

: engines>quots ( assoc -- assoc' )
    [ engine>quot ] assoc-map ;

: engines>quots* ( assoc -- assoc' )
    [ over assumed [ engine>quot ] with-variable ] assoc-map ;

: if-small? ( assoc true false -- )
    >r >r dup assoc-size 4 <= r> r> if ; inline

: linear-dispatch-quot ( alist -- quot )
    default get [ drop ] prepend swap
    [ >r [ dupd eq? ] curry r> \ drop prefix ] assoc-map
    alist>quot ;

: split-methods ( assoc class -- first second )
    [ [ nip class<= not ] curry assoc-filter ]
    [ [ nip class<=     ] curry assoc-filter ] 2bi ;

: convert-methods ( assoc class word -- assoc' )
    over >r >r split-methods dup assoc-empty? [
        r> r> 3drop
    ] [
        r> execute r> pick set-at
    ] if ; inline

: (picker) ( n -- quot )
    {
        { 0 [ [ dup ] ] }
        { 1 [ [ over ] ] }
        { 2 [ [ pick ] ] }
        [ 1- (picker) [ >r ] swap [ r> swap ] 3append ]
    } case ;

: picker ( -- quot ) \ (dispatch#) get (picker) ;

GENERIC: extra-values ( generic -- n )
