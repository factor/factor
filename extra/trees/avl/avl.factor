! Copyright (C) 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel generic math math.functions
math.parser namespaces io sequences trees shuffle
assocs parser accessors math.order prettyprint.custom ;
IN: trees.avl

TUPLE: avl < tree ;

: <avl> ( -- tree )
    avl new-tree ;

TUPLE: avl-node < node balance ;

: <avl-node> ( key value -- node )
    avl-node new-node
        0 >>balance ;

: increase-balance ( node amount -- )
    swap [ + ] change-balance drop ;

: rotate ( node -- node )
    dup node+link dup node-link pick set-node+link
    tuck set-node-link ;    

: single-rotate ( node -- node )
    0 over (>>balance) 0 over node+link 
    (>>balance) rotate ;

: pick-balances ( a node -- balance balance )
    balance>> {
        { [ dup zero? ] [ 2drop 0 0 ] }
        { [ over = ] [ neg 0 ] }
        [ 0 swap ]
    } cond ;

: double-rotate ( node -- node )
    [
        node+link [
            node-link current-side get neg
            over pick-balances rot 0 swap (>>balance)
        ] keep (>>balance)
    ] keep swap >>balance
    dup node+link [ rotate ] with-other-side
    over set-node+link rotate ;

: select-rotate ( node -- node )
    dup node+link balance>> current-side get =
    [ double-rotate ] [ single-rotate ] if ;

: balance-insert ( node -- node taller? )
    dup balance>> {
        { [ dup zero? ] [ drop f ] }
        { [ dup abs 2 = ]
          [ sgn neg [ select-rotate ] with-side f ] }
        { [ drop t ] [ t ] } ! balance is -1 or 1, tree is taller
    } cond ;

DEFER: avl-set

: avl-insert ( value key node -- node taller? )
    2dup key>> before? left right ? [
        [ node-link avl-set ] keep swap
        [ tuck set-node-link ] dip
        [ dup current-side get increase-balance balance-insert ]
        [ f ] if
    ] with-side ;

: (avl-set) ( value key node -- node taller? )
    2dup key>> = [
        -rot pick (>>key) over (>>value) f
    ] [ avl-insert ] if ;

: avl-set ( value key node -- node taller? )
    [ (avl-set) ] [ swap <avl-node> t ] if* ;

M: avl set-at ( value key node -- node )
    [ avl-set drop ] change-root drop ;

: delete-select-rotate ( node -- node shorter? )
    dup node+link balance>> zero? [
        current-side get neg over (>>balance)
        current-side get over node+link (>>balance) rotate f
    ] [
        select-rotate t
    ] if ;

: rebalance-delete ( node -- node shorter? )
    dup balance>> {
        { [ dup zero? ] [ drop t ] }
        { [ dup abs 2 = ] [ sgn neg [ delete-select-rotate ] with-side ] }
        { [ drop t ] [ f ] } ! balance is -1 or 1, tree is not shorter
    } cond ;

: balance-delete ( node -- node shorter? )
    current-side get over balance>> {
        { [ dup zero? ] [ drop neg over (>>balance) f ] }
        { [ dupd = ] [ drop 0 >>balance t ] }
        [ dupd neg increase-balance rebalance-delete ]
    } cond ;

: avl-replace-with-extremity ( to-replace node -- node shorter? )
    dup node-link [
        swapd avl-replace-with-extremity [ over set-node-link ] dip
        [ balance-delete ] [ f ] if
    ] [
        [ copy-node-contents drop ] keep node+link t
    ] if* ;

: replace-with-a-child ( node -- node shorter? )
    #! assumes that node is not a leaf, otherwise will recurse forever
    dup node-link [
        dupd [ avl-replace-with-extremity ] with-other-side
        [ over set-node-link ] dip [ balance-delete ] [ f ] if
    ] [
        [ replace-with-a-child ] with-other-side
    ] if* ;

: avl-delete-node ( node -- node shorter? )
    #! delete this node, returning its replacement, and whether this subtree is
    #! shorter as a result
    dup leaf? [
        drop f t
    ] [
        left [ replace-with-a-child ] with-side
    ] if ;

GENERIC: avl-delete ( key node -- node shorter? deleted? )

M: f avl-delete ( key f -- f f f ) nip f f ;

: (avl-delete) ( key node -- node shorter? deleted? )
    tuck node-link avl-delete [
        [ over set-node-link ] dip [ balance-delete ] [ f ] if
    ] dip ;

M: avl-node avl-delete ( key node -- node shorter? deleted? )
    2dup key>> key-side dup zero? [
        drop nip avl-delete-node t
    ] [
        [ (avl-delete) ] with-side
    ] if ;

M: avl delete-at ( key node -- )
    [ avl-delete 2drop ] change-root drop ;

M: avl new-assoc 2drop <avl> ;

: >avl ( assoc -- avl )
    T{ avl f f 0 } assoc-clone-like ;

M: avl assoc-like
    drop dup avl? [ >avl ] unless ;

SYNTAX: AVL{
    \ } [ >avl ] parse-literal ;

M: avl pprint-delims drop \ AVL{ \ } ;
