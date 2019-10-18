! Copyright (c) 2005 Mackenzie Straight.
! See http://factor.sf.net/license.txt for BSD license.
USING: arrays kernel math namespaces sequences ;

IN: splay-trees

TUPLE: splay-tree r ;

C: splay-tree ;

IN: splay-trees-internals

TUPLE: splay-node v k l r ;

: rotate-right ( node -- node )
    dup splay-node-l
    [ splay-node-r swap set-splay-node-l ] 2keep
    [ set-splay-node-r ] keep ;
                                                        
: rotate-left ( node -- node )
    dup splay-node-r
    [ splay-node-l swap set-splay-node-r ] 2keep
    [ set-splay-node-l ] keep ;

: link-right ( left right key node -- left right key node )
    swap >r [ swap set-splay-node-l ] 2keep
    nip dup splay-node-l r> swap ;

: link-left ( left right key node -- left right key node )
    swap >r rot [ set-splay-node-r ] 2keep
    drop dup splay-node-r swapd r> swap ;

: cmp ( key node -- obj node -1/0/1 )
    2dup splay-node-k <=> ;

: lcmp ( key node -- obj node -1/0/1 ) 
    2dup splay-node-l splay-node-k <=> ;

: rcmp ( key node -- obj node -1/0/1 ) 
    2dup splay-node-r splay-node-k <=> ;

DEFER: (splay)

: splay-left ( left right key node -- left right key node )
    dup splay-node-l [
        lcmp 0 < [ rotate-right ] when
        dup splay-node-l [ link-right (splay) ] when
    ] when ;

: splay-right ( left right key node -- left right key node )
    dup splay-node-r [
        rcmp 0 > [ rotate-left ] when
        dup splay-node-r [ link-left (splay) ] when
    ] when ;

: (splay) ( left right key node -- left right key node )
    cmp dup 0 <
    [ drop splay-left ] [ 0 > [ splay-right ] when ] if ;

: assemble ( head left right node -- root )
    [ splay-node-r swap set-splay-node-l ] keep
    [ splay-node-l swap set-splay-node-r ] keep
    [ swap splay-node-l swap set-splay-node-r ] 2keep
    [ swap splay-node-r swap set-splay-node-l ] keep ;

: splay-at ( key node -- node )
    >r >r T{ splay-node } clone dup dup r> r>
    (splay) nip assemble ;

: splay ( key tree -- )
    [ splay-tree-r splay-at ] keep set-splay-tree-r ;

: splay-split ( key tree -- node node )
    2dup splay splay-tree-r cmp 0 < [
        nip dup splay-node-l swap f over set-splay-node-l
    ] [
        nip dup splay-node-r swap f over set-splay-node-r swap
    ] if ;

: (get-splay) ( key tree -- node ? )
    2dup splay splay-tree-r cmp 0 = [
        nip t
    ] [
        2drop f f
    ] if ;

: get-largest ( node -- node )
    dup [ dup splay-node-r [ nip get-largest ] when* ] when ;

: splay-largest
    dup [ dup get-largest splay-node-k swap splay-at ] when ;

: splay-join ( n2 n1 -- node )
    splay-largest [
        [ set-splay-node-r ] keep
    ] [
        drop f
    ] if* ;

: (remove-splay) ( key tree -- )
    tuck (get-splay) nip [
        dup splay-node-r swap splay-node-l splay-join
        swap set-splay-tree-r
    ] [ drop ] if* ;

: (set-splay) ( value key tree -- )
    2dup (get-splay) [ 2nip set-splay-node-v ] [
       drop 2dup splay-split rot
       >r <splay-node> r> set-splay-tree-r
    ] if ;

: new-root ( value key tree -- )
    >r f f <splay-node> r> set-splay-tree-r ;

: splay-call ( splay-node call -- )
    >r [ splay-node-k ] keep splay-node-v r> call ; inline
    
: (splay-tree-traverse) ( splay-node quot -- )
    over [
        [ >r splay-node-l r> (splay-tree-traverse) ] 2keep
        [ splay-call ] 2keep
        >r splay-node-r r> (splay-tree-traverse)
    ] [
        2drop
    ] if ;

IN: splay-trees

: splay-tree-traverse ( splay-tree quot -- )
    #! quot: ( k v -- )
    #! Not tail recursive so will fail on large splay trees.
    >r splay-tree-r r> (splay-tree-traverse) ;

: set-splay ( value key tree -- )
    dup splay-tree-r [ (set-splay) ] [ new-root ] if ;

: get-splay* ( key tree -- value ? )
    dup splay-tree-r [
        (get-splay) >r dup [ splay-node-v ] when r>
    ] [
        2drop f f
    ] if ;
    
: get-splay ( key tree -- value ) get-splay* drop ;

: splay? ( key tree -- ? ) get-splay* nip ;

: remove-splay ( key tree -- )
    dup splay-tree-r [ (remove-splay) ] [ 2drop ] if ;

: splay-values ( tree -- seq )
    [ [ nip , ] splay-tree-traverse ] { } make ;

: splay-keys ( tree -- seq )
    [ [ drop , ] splay-tree-traverse ] { } make ;

: splay>assoc ( tree -- seq )
    [ [ 2array , ] splay-tree-traverse ] { } make ;

: assoc>splay ( assoc -- tree )
    >r <splay-tree> r> [ first2 swap pick set-splay ] each ;
