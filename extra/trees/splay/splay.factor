! Copyright (c) 2005 Mackenzie Straight.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math namespaces sequences assocs parser
trees generic math.order accessors prettyprint.custom shuffle ;
IN: trees.splay

TUPLE: splay < tree ;

: <splay> ( -- tree )
    \ splay new-tree ;

: rotate-right ( node -- node )
    dup left>>
    [ right>> swap (>>left) ] 2keep
    [ (>>right) ] keep ;
                                                        
: rotate-left ( node -- node )
    dup right>>
    [ left>> swap (>>right) ] 2keep
    [ (>>left) ] keep ;

: link-right ( left right key node -- left right key node )
    swap [ [ swap (>>left) ] 2keep
    nip dup left>> ] dip swap ;

: link-left ( left right key node -- left right key node )
    swap [ rot [ (>>right) ] 2keep
    drop dup right>> swapd ] dip swap ;

: cmp ( key node -- obj node -1/0/1 )
    2dup key>> key-side ;

: lcmp ( key node -- obj node -1/0/1 ) 
    2dup left>> key>> key-side ;

: rcmp ( key node -- obj node -1/0/1 ) 
    2dup right>> key>> key-side ;

DEFER: (splay)

: splay-left ( left right key node -- left right key node )
    dup left>> [
        lcmp 0 < [ rotate-right ] when
        dup left>> [ link-right (splay) ] when
    ] when ;

: splay-right ( left right key node -- left right key node )
    dup right>> [
        rcmp 0 > [ rotate-left ] when
        dup right>> [ link-left (splay) ] when
    ] when ;

: (splay) ( left right key node -- left right key node )
    cmp dup 0 <
    [ drop splay-left ] [ 0 > [ splay-right ] when ] if ;

: assemble ( head left right node -- root )
    [ right>> swap (>>left) ] keep
    [ left>> swap (>>right) ] keep
    [ swap left>> swap (>>right) ] 2keep
    [ swap right>> swap (>>left) ] keep ;

: splay-at ( key node -- node )
    [ T{ node } clone dup dup ] 2dip
    (splay) nip assemble ;

: splay ( key tree -- )
    [ root>> splay-at ] keep (>>root) ;

: splay-split ( key tree -- node node )
    2dup splay root>> cmp 0 < [
        nip dup left>> swap f over (>>left)
    ] [
        nip dup right>> swap f over (>>right) swap
    ] if ;

: get-splay ( key tree -- node ? )
    2dup splay root>> cmp 0 = [
        nip t
    ] [
        2drop f f
    ] if ;

: get-largest ( node -- node )
    dup [ dup right>> [ nip get-largest ] when* ] when ;

: splay-largest ( node -- node )
    dup [ dup get-largest key>> swap splay-at ] when ;

: splay-join ( n2 n1 -- node )
    splay-largest [
        [ (>>right) ] keep
    ] [
        drop f
    ] if* ;

: remove-splay ( key tree -- )
    tuck get-splay nip [
        dup dec-count
        dup right>> swap left>> splay-join
        swap (>>root)
    ] [ drop ] if* ;

: set-splay ( value key tree -- )
    2dup get-splay [ 2nip (>>value) ] [
       drop dup inc-count
       2dup splay-split rot
       [ [ swapd ] dip node boa ] dip (>>root)
    ] if ;

: new-root ( value key tree -- )
    1 >>count
    [ swap <node> ] dip (>>root) ;

M: splay set-at ( value key tree -- )
    dup root>> [ set-splay ] [ new-root ] if ;

M: splay at* ( key tree -- value ? )
    dup root>> [
        get-splay [ dup [ value>> ] when ] dip
    ] [
        2drop f f
    ] if ;

M: splay delete-at ( key tree -- )
    dup root>> [ remove-splay ] [ 2drop ] if ;

M: splay new-assoc
    2drop <splay> ;

: >splay ( assoc -- tree )
    T{ splay f f 0 } assoc-clone-like ;

SYNTAX: SPLAY{
    \ } [ >splay ] parse-literal ;

M: splay assoc-like
    drop dup splay? [ >splay ] unless ;

M: splay pprint-delims drop \ SPLAY{ \ } ;
